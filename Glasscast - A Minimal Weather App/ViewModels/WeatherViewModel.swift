//
//  WeatherViewModel.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import WidgetKit

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: [ForecastDay] = []
    @Published var hourlyForecast: [ForecastItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCity: FavoriteCity?
    
    private let weatherService = WeatherService.shared
    
    func loadWeather(for city: FavoriteCity) {
        selectedCity = city
        Task {
            await fetchWeatherData(lat: city.lat, lon: city.lon)
        }
    }
    
    func loadWeatherFromSearch(weatherResponse: WeatherResponse) {
        // Create a temporary FavoriteCity from search result
        let tempCity = FavoriteCity(
            id: nil,
            userId: "",
            cityName: weatherResponse.name,
            lat: weatherResponse.coord.lat,
            lon: weatherResponse.coord.lon,
            createdAt: nil
        )
        selectedCity = tempCity
        Task {
            await fetchWeatherData(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon)
        }
    }
    
    func loadWeatherFromLocation(lat: Double, lon: Double) {
        selectedCity = nil
        Task {
            await fetchWeatherData(lat: lat, lon: lon)
        }
    }
    
    func refreshWeather() async {
        if let city = selectedCity {
            await fetchWeatherData(lat: city.lat, lon: city.lon)
        } else if let location = LocationService.shared.currentLocation {
            await fetchWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    private func fetchWeatherData(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let currentWeatherTask = weatherService.fetchCurrentWeather(lat: lat, lon: lon)
            async let forecastTask = weatherService.fetchForecast(lat: lat, lon: lon)
            
            let (weatherResponse, forecastResponse) = try await (currentWeatherTask, forecastTask)
            
            // Process current weather
            let weather = weatherResponse.weather.first
            currentWeather = CurrentWeather(
                cityName: weatherResponse.name,
                country: weatherResponse.sys.country,
                temperature: weatherResponse.main.temp,
                condition: weather?.main ?? "Unknown",
                description: weather?.description.capitalized ?? "",
                icon: weather?.icon ?? "",
                high: weatherResponse.main.tempMax,
                low: weatherResponse.main.tempMin,
                humidity: weatherResponse.main.humidity,
                coordinates: weatherResponse.coord
            )
            
            // Save snapshot for the widget (App Group shared storage)
            if let current = currentWeather {
                WidgetWeatherStore.save(from: current)
                WidgetCenter.shared.reloadTimelines(ofKind: "GlasscastWidget")
            }
            
            // Process forecast - group by day and get daily high/low
            let calendar = Calendar.current
            var dailyForecasts: [Date: [ForecastItem]] = [:]
            
            for item in forecastResponse.list {
                let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                let dayStart = calendar.startOfDay(for: date)
                dailyForecasts[dayStart, default: []].append(item)
            }
            
            // Process hourly forecast (next 24 hours)
            let now = Date()
            hourlyForecast = forecastResponse.list
                .filter { item in
                    let itemDate = Date(timeIntervalSince1970: TimeInterval(item.dt))
                    return itemDate >= now && itemDate <= now.addingTimeInterval(24 * 60 * 60)
                }
                .prefix(24)
                .map { $0 }
            
            // Process daily forecast
            forecast = dailyForecasts.compactMap { date, items in
                guard let firstItem = items.first else { return nil }
                let highs = items.map { $0.main.tempMax }
                let lows = items.map { $0.main.tempMin }
                let weather = firstItem.weather.first
                
                return ForecastDay(
                    date: date,
                    high: highs.max() ?? firstItem.main.tempMax,
                    low: lows.min() ?? firstItem.main.tempMin,
                    condition: weather?.main ?? "Unknown",
                    icon: weather?.icon ?? ""
                )
            }.sorted { $0.date < $1.date }
            .prefix(10)
            .map { $0 }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func formatTemperature(_ temp: Double, unit: TemperatureUnit) -> String {
        let converted = unit == .fahrenheit ? (temp * 9/5) + 32 : temp
        return String(format: "%.0f°", converted)
    }
}

enum TemperatureUnit: String, CaseIterable {
    case celsius = "°C"
    case fahrenheit = "°F"
}
