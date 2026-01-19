//
//  CitiesViewModel.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class CitiesViewModel: ObservableObject {
    @Published var favoriteCities: [FavoriteCity] = []
    @Published var searchResults: [WeatherResponse] = []
    @Published var recentSearches: [WeatherResponse] = []
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var searchQuery = "" {
        didSet {
            if searchQuery.isEmpty {
                searchResults = []
            }
        }
    }
    
    private let supabase = SupabaseManager.shared.supabase
    private let weatherService = WeatherService.shared
    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10
    private var suggestionTask: Task<Void, Never>?
    
    init() {
        loadRecentSearches()
    }
    
    func loadFavoriteCities() async {
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            let cities: [FavoriteCity] = try await supabase
                .from("favorite_cities")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                favoriteCities = cities
                isLoading = false
                print("✅ Loaded \(cities.count) favorite cities")
            }
        } catch {
            let errorMsg = error.localizedDescription
            await MainActor.run {
                // Don't show error if table doesn't exist - just log it
                if errorMsg.contains("Could not find the table") || errorMsg.contains("does not exist") {
                    print("⚠️ Table 'favorite_cities' doesn't exist yet. Please create it in Supabase.")
                    print("📝 See CREATE_TABLE_STEP_BY_STEP.md for instructions")
                    errorMessage = nil // Don't show error to user, just empty list
                    favoriteCities = [] // Ensure empty list
                } else {
                    errorMessage = "Failed to load favorites: \(errorMsg)"
                    print("❌ Error loading favorites: \(errorMsg)")
                }
                isLoading = false
            }
        }
    }
    
    func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: recentSearchesKey),
           let decoded = try? JSONDecoder().decode([WeatherResponse].self, from: data) {
            recentSearches = decoded
        }
    }
    
    func saveRecentSearches() {
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encoded, forKey: recentSearchesKey)
        }
    }
    
    func addToRecentSearches(_ weatherResponse: WeatherResponse) {
        // Remove if already exists
        recentSearches.removeAll { $0.coord.lat == weatherResponse.coord.lat && $0.coord.lon == weatherResponse.coord.lon }
        
        // Add to beginning
        recentSearches.insert(weatherResponse, at: 0)
        
        // Keep only max recent searches
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
    
    func searchCities(query overrideQuery: String? = nil) async {
        let effectiveQuery = (overrideQuery ?? searchQuery).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !effectiveQuery.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            let results = try await weatherService.searchCities(query: effectiveQuery)
            searchResults = results
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            searchResults = []
        }
        
        isSearching = false
    }

    func handleQueryChange() async {
        // Cancel any in-flight suggestion task
        suggestionTask?.cancel()
        
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            await MainActor.run {
                isSearching = false
                searchResults = []
            }
            return
        }
        
        // Indicate we are fetching suggestions
        await MainActor.run {
            isSearching = true
        }
        
        suggestionTask = Task { [self] in
            // Debounce to reduce API calls while typing
            try? await Task.sleep(nanoseconds: 350_000_000) // 0.35s
            if Task.isCancelled { return }
            await searchCities(query: trimmed)
        }
    }
    
    // Toggle favorite status - adds if not favorite, removes if already favorite
    func toggleFavoriteCity(_ weatherResponse: WeatherResponse) async {
        // Check if already favorite
        if let existingCity = findFavoriteCity(for: weatherResponse) {
            // Remove from favorites
            await removeFavoriteCity(existingCity)
        } else {
            // Add to favorites
            await addFavoriteCity(weatherResponse)
        }
    }
    
    // Add a city to favorites
    func addFavoriteCity(_ weatherResponse: WeatherResponse) async {
        do {
            // Check authentication
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            
            // Check if city already exists (double-check)
            if findFavoriteCity(for: weatherResponse) != nil {
                await MainActor.run {
                    errorMessage = "City already in favorites"
                    print("City already in favorites: \(weatherResponse.name)")
                }
                return
            }
            
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            
            // Insert using dictionary to avoid schema cache issues
            let cityData: [String: AnyJSON] = [
                "user_id": .string(userId),
                "city_name": .string(weatherResponse.name),
                "lat": .double(weatherResponse.coord.lat),
                "lon": .double(weatherResponse.coord.lon)
            ]
            
            // Insert into Supabase using dictionary
            let inserted: FavoriteCity = try await supabase
                .from("favorite_cities")
                .insert(cityData)
                .select()
                .single()
                .execute()
                .value
            
            // Update local state immediately
            await MainActor.run {
                favoriteCities.insert(inserted, at: 0)
                isLoading = false
                errorMessage = nil
                print("✅ Added favorite: \(weatherResponse.name) (ID: \(inserted.id.map(String.init) ?? "nil"))")
            }
            
        } catch {
            await MainActor.run {
                let errorMsg = error.localizedDescription
                errorMessage = "Failed to add city: \(errorMsg)"
                isLoading = false
                print("❌ Add favorite failed: \(errorMsg)")
            }
        }
    }
    
    // Remove a city from favorites
    func removeFavoriteCity(_ city: FavoriteCity) async {
        guard let cityId = city.id else {
            await MainActor.run {
                errorMessage = "Cannot remove: City ID is missing"
                print("❌ Cannot remove favorite: City ID is nil")
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Delete from Supabase (convert Int64 to String for PostgrestFilterValue)
            try await supabase
                .from("favorite_cities")
                .delete()
                .eq("id", value: String(cityId))
                .execute()
            
            // Update local state immediately
            await MainActor.run {
                favoriteCities.removeAll { $0.id == cityId }
                isLoading = false
                errorMessage = nil
                print("✅ Removed favorite: \(city.cityName) (ID: \(cityId))")
            }
            
        } catch {
            await MainActor.run {
                let errorMsg = error.localizedDescription
                errorMessage = "Failed to remove city: \(errorMsg)"
                isLoading = false
                print("❌ Remove favorite failed: \(errorMsg)")
            }
        }
    }
    
    // Find favorite city by weather response coordinates
    func findFavoriteCity(for weatherResponse: WeatherResponse) -> FavoriteCity? {
        return favoriteCities.first { city in
            abs(city.lat - weatherResponse.coord.lat) < 0.01 &&
            abs(city.lon - weatherResponse.coord.lon) < 0.01
        }
    }
    
    // Check if a city is already in favorites
    func isCityFavorite(_ weatherResponse: WeatherResponse) -> Bool {
        return findFavoriteCity(for: weatherResponse) != nil
    }
}
