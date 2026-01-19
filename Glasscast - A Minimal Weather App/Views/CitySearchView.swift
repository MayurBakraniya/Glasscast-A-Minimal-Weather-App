//
//  CitySearchView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct CitySearchView: View {
    @EnvironmentObject var citiesViewModel: CitiesViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @FocusState private var isSearchFocused: Bool
    @Binding var selectedTab: Int
    
    @State private var appear = false
    
    init(selectedTab: Binding<Int> = .constant(1)) {
        _selectedTab = selectedTab
    }
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 24)
                    
                    TextField("Search for a city...", text: $citiesViewModel.searchQuery)
                        .focused($isSearchFocused)
                        .foregroundStyle(.white)
                        .font(.system(size: 16))
                        .submitLabel(.search)
                        .onSubmit {
                            Task {
                                await citiesViewModel.searchCities()
                            }
                        }
                        .onChange(of: citiesViewModel.searchQuery) { _, _ in
                            Task {
                                await citiesViewModel.handleQueryChange()
                            }
                        }
                    
                    if !citiesViewModel.searchQuery.isEmpty {
                        Button {
                            citiesViewModel.searchQuery = ""
                            citiesViewModel.searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white.opacity(0.1))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Inline error (favorites/save/search)
                if let error = citiesViewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 6)
                        .transition(.opacity)
                }
                
                // Content Area
                if citiesViewModel.isSearching {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.white)
                        Text("Searching...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Search Results Section (if available)
                            if !citiesViewModel.searchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Results header
                                    HStack {
                                        Text("Search Results")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("\(citiesViewModel.searchResults.count) found")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(Array(citiesViewModel.searchResults.enumerated()), id: \.element.coord.lat) { index, result in
                                            SearchResultRow(weatherResponse: result, selectedTab: $selectedTab)
                                                .opacity(appear ? 1 : 0)
                                                .offset(x: appear ? 0 : 50)
                                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: appear)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 8)
                            }
                            
                            // No results found (when search query exists but no results)
                            if !citiesViewModel.searchQuery.isEmpty && citiesViewModel.searchResults.isEmpty && !citiesViewModel.isSearching {
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white.opacity(0.6))
                                    
                                    Text("No Results Found")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                    
                                    Text("Try searching for a different city")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                                .glassEffect()
                                .padding(.horizontal, 30)
                            }
                            
                            // Favorite Cities Section (always show if available)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Favorite Cities")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(citiesViewModel.favoriteCities.count)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                .padding(.horizontal, 20)
                                
                                if !citiesViewModel.favoriteCities.isEmpty {
                                    VStack(spacing: 12) {
                                        ForEach(Array(citiesViewModel.favoriteCities.enumerated()), id: \.element.id) { index, city in
                                            FavoriteCityRow(city: city, selectedTab: $selectedTab)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                } else {
                                    // Empty state for favorites
                                    VStack(spacing: 12) {
                                        Text("No favorite cities yet")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white.opacity(0.6))
                                            .padding(.vertical, 20)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.top, citiesViewModel.searchResults.isEmpty ? 0 : 20)
                            
                            // Recent Searches (show when no search results and search query is empty)
                            if citiesViewModel.searchResults.isEmpty && citiesViewModel.searchQuery.isEmpty && !citiesViewModel.recentSearches.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Recent Searches")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Button {
                                            citiesViewModel.clearRecentSearches()
                                        } label: {
                                            Text("Clear")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    
                                    VStack(spacing: 12) {
                                        ForEach(Array(citiesViewModel.recentSearches.enumerated()), id: \.element.coord.lat) { index, result in
                                            RecentSearchRow(weatherResponse: result, selectedTab: $selectedTab)
                                                .opacity(appear ? 1 : 0)
                                                .offset(x: appear ? 0 : -50)
                                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: appear)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, 8)
                            }
                            
                            // Empty State (only if everything is empty)
                            if citiesViewModel.searchResults.isEmpty && citiesViewModel.favoriteCities.isEmpty && citiesViewModel.recentSearches.isEmpty && citiesViewModel.searchQuery.isEmpty {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "map")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .scaleEffect(appear ? 1.0 : 0.5)
                                    
                                    Text("No Cities Yet")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .opacity(appear ? 1 : 0)
                                    
                                    Text("Search for a city to add it to your favorites")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .opacity(appear ? 1 : 0)
                                }
                                .padding(40)
                                .glassEffect()
                                .padding(.horizontal, 30)
                                Spacer()
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .onAppear {
                        appear = false
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            appear = true
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            citiesViewModel.loadRecentSearches()
            // Load favorite cities when view appears
            Task {
                await citiesViewModel.loadFavoriteCities()
                // Force UI update after loading
                await MainActor.run {
                    // Trigger view update
                }
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
        }
        .onChange(of: citiesViewModel.favoriteCities.count) { oldValue, newValue in
            // Force refresh when favorites count changes
            print("Favorites count changed: \(oldValue) -> \(newValue)")
        }
    }
}

struct SearchResultRow: View {
    let weatherResponse: WeatherResponse
    @EnvironmentObject var citiesViewModel: CitiesViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Tappable city name area
            Button {
                // Show weather for this city
                weatherViewModel.loadWeatherFromSearch(weatherResponse: weatherResponse)
                citiesViewModel.addToRecentSearches(weatherResponse)
                // Switch to Weather tab after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selectedTab = 0
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weatherResponse.name)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    Text(weatherResponse.sys.country)
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Toggle favorites button
            Button {
                Task {
                    await citiesViewModel.toggleFavoriteCity(weatherResponse)
                }
            } label: {
                Image(systemName: citiesViewModel.isCityFavorite(weatherResponse) ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        citiesViewModel.isCityFavorite(weatherResponse) 
                            ? Color.red.opacity(0.9)
                            : Color.white.opacity(0.7)
                    )
            }
            .disabled(citiesViewModel.isLoading)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: citiesViewModel.isCityFavorite(weatherResponse))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassEffect()
    }
}

struct FavoriteCityRow: View {
    let city: FavoriteCity
    @EnvironmentObject var citiesViewModel: CitiesViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @Binding var selectedTab: Int
    
    init(city: FavoriteCity, selectedTab: Binding<Int> = .constant(0)) {
        self.city = city
        _selectedTab = selectedTab
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                weatherViewModel.loadWeather(for: city)
                selectedTab = 0
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(city.cityName)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    Text("\(String(format: "%.2f", city.lat))°, \(String(format: "%.2f", city.lon))°")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Button {
                Task {
                    await citiesViewModel.removeFavoriteCity(city)
                }
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.red.opacity(0.9))
                    .frame(width: 36, height: 36)
            }
            .disabled(citiesViewModel.isLoading)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: citiesViewModel.favoriteCities.count)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassEffect()
    }
}

struct RecentSearchRow: View {
    let weatherResponse: WeatherResponse
    @EnvironmentObject var citiesViewModel: CitiesViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Weather Icon
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherResponse.weather.first?.icon ?? "01d")@2x.png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(width: 50, height: 50)
            
            // Tappable city name area
            Button {
                // Show weather for this city
                weatherViewModel.loadWeatherFromSearch(weatherResponse: weatherResponse)
                citiesViewModel.addToRecentSearches(weatherResponse)
                // Switch to Weather tab after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    selectedTab = 0
                }
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weatherResponse.name)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(weatherResponse.sys.country)
                            .font(.system(size: 15))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        if let weather = weatherResponse.weather.first {
                            Text("• \(weather.description.capitalized)")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Toggle favorites button
            Button {
                Task {
                    await citiesViewModel.toggleFavoriteCity(weatherResponse)
                }
            } label: {
                Image(systemName: citiesViewModel.isCityFavorite(weatherResponse) ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        citiesViewModel.isCityFavorite(weatherResponse) 
                            ? Color.red.opacity(0.9)
                            : Color.white.opacity(0.7)
                    )
            }
            .disabled(citiesViewModel.isLoading)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: citiesViewModel.isCityFavorite(weatherResponse))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .glassEffect()
    }
}
