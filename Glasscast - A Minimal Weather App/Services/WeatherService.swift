//
//  WeatherService.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from weather API"
        case .decodingError:
            return "Failed to decode weather data"
        case .apiError(let message):
            return message
        }
    }
}

class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String else {
            fatalError("Weather API key not found. Please configure in Info.plist")
        }
        return key
    }
    
    private init() {}
    
    // MARK: - Current Weather
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        return try await performRequest(urlString: urlString)
    }
    
    func fetchCurrentWeather(cityName: String) async throws -> WeatherResponse {
        let encodedCity = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cityName
        let urlString = "\(baseURL)/weather?q=\(encodedCity)&appid=\(apiKey)&units=metric"
        return try await performRequest(urlString: urlString)
    }
    
    // MARK: - Forecast
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        return try await performRequest(urlString: urlString)
    }
    
    // MARK: - City Search
    func searchCities(query: String) async throws -> [WeatherResponse] {
        // OpenWeatherMap doesn't have a direct city search, so we'll try to fetch weather for the query
        // In a production app, you might use a geocoding API
        do {
            let weather = try await fetchCurrentWeather(cityName: query)
            return [weather]
        } catch {
            return []
        }
    }
    
    // MARK: - Helper
    private func performRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            if let errorData = try? JSONDecoder().decode([String: String].self, from: data),
               let message = errorData["message"] {
                throw WeatherServiceError.apiError(message)
            }
            throw WeatherServiceError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw WeatherServiceError.decodingError
        }
    }
}
