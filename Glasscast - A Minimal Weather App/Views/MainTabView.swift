//
//  MainTabView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI
import Combine
import CoreLocation

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var citiesViewModel = CitiesViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab = 0
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = UIColor.clear
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(weatherViewModel)
                    .environmentObject(settingsViewModel)
                    .environmentObject(citiesViewModel)
                    .tabItem {
                        Label("Weather", systemImage: "cloud.sun.fill")
                    }
                    .tag(0)
                
                CitySearchView(selectedTab: $selectedTab)
                    .environmentObject(citiesViewModel)
                    .environmentObject(weatherViewModel)
                    .environmentObject(settingsViewModel)
                    .tabItem {
                        Label("Cities", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                
                SettingsView()
                    .environmentObject(settingsViewModel)
                    .environmentObject(authViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .background(AppColors.backgroundGradient.ignoresSafeArea())
            .onAppear {
                // Ensure background is set immediately
                UITabBar.appearance().backgroundColor = UIColor.clear
            }
            .onChange(of: weatherViewModel.currentWeather) { oldValue, newWeather in
                // Switch to Weather tab when weather is loaded from search
                if newWeather != nil && selectedTab == 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedTab = 0
                    }
                }
            }
        }
        .task {
            // Request location permission and get location
            LocationService.shared.requestLocationPermission()
            LocationService.shared.getCurrentLocation()
            
            // Load favorite cities
            await citiesViewModel.loadFavoriteCities()
            
            // Wait a moment for location to be retrieved
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Try to load weather from current location first
            if let location = LocationService.shared.currentLocation {
                weatherViewModel.loadWeatherFromLocation(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
            } else if let firstCity = citiesViewModel.favoriteCities.first {
                // If no location, use first favorite city
                weatherViewModel.loadWeather(for: firstCity)
            } else {
                // Default to London if no location and no favorites
                weatherViewModel.loadWeatherFromLocation(lat: 51.5074, lon: -0.1278) // London
            }
        }
        .onReceive(LocationService.shared.$currentLocation) { location in
            // When location is received, load weather if we don't have a selected city
            if let location = location, weatherViewModel.selectedCity == nil {
                weatherViewModel.loadWeatherFromLocation(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude
                )
            }
        }
    }
}
