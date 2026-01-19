//
//  WeatherModels.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation

// MARK: - Weather Response Models
struct WeatherResponse: Codable {
    let coord: Coordinates
    let weather: [Weather]
    let main: MainWeather
    let name: String
    let sys: SystemInfo
}

struct Coordinates: Codable, Equatable {
    let lat: Double
    let lon: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct SystemInfo: Codable {
    let country: String
    let sunrise: Int?
    let sunset: Int?
}

// MARK: - Forecast Response Models
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: ForecastCity
}

struct ForecastItem: Codable, Identifiable {
    let id = UUID()
    let dt: Int
    let main: ForecastMain
    let weather: [Weather]
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather
        case dtTxt = "dt_txt"
    }
}

struct ForecastMain: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct ForecastCity: Codable {
    let name: String
    let country: String
    let coord: Coordinates
}

// MARK: - App Models
struct FavoriteCity: Codable, Identifiable {
    // Supabase table uses BIGINT for id in your project, so we decode as Int64.
    // (If you later migrate the DB to UUID, you can switch this back.)
    let id: Int64?
    let userId: String
    let cityName: String
    let lat: Double
    let lon: Double
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cityName = "city_name"
        case lat, lon
        case createdAt = "created_at"
    }
}

struct CurrentWeather: Identifiable, Equatable {
    let id = UUID()
    let cityName: String
    let country: String
    let temperature: Double
    let condition: String
    let description: String
    let icon: String
    let high: Double
    let low: Double
    let humidity: Int
    let coordinates: Coordinates
    
    static func == (lhs: CurrentWeather, rhs: CurrentWeather) -> Bool {
        lhs.cityName == rhs.cityName &&
        lhs.country == rhs.country &&
        lhs.temperature == rhs.temperature &&
        lhs.condition == rhs.condition &&
        lhs.coordinates.lat == rhs.coordinates.lat &&
        lhs.coordinates.lon == rhs.coordinates.lon
    }
}

struct ForecastDay: Identifiable {
    let id = UUID()
    let date: Date
    let high: Double
    let low: Double
    let condition: String
    let icon: String
}
