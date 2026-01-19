//
//  WidgetShared.swift
//  Glasscast - A Minimal Weather App
//
//  Shared helpers for the app and the widget extension.
//

import Foundation

// TODO: Replace with your actual App Group identifier configured in both targets.
let glasscastAppGroupID = "group.com.yourcompany.glasscast"

struct WidgetWeatherSnapshot: Codable {
    let city: String
    let temp: Double
    let conditionIcon: String
    let timestamp: Date
}

enum WidgetWeatherStore {
    private static let key = "widgetWeather"

    static func save(from weather: CurrentWeather) {
        let snapshot = WidgetWeatherSnapshot(
            city: weather.cityName,
            temp: weather.temperature,
            conditionIcon: weather.icon,
            timestamp: Date()
        )

        guard
            let data = try? JSONEncoder().encode(snapshot),
            let defaults = UserDefaults(suiteName: glasscastAppGroupID)
        else { return }

        defaults.set(data, forKey: key)

        #if DEBUG
        print("📦 [WidgetWeatherStore] Saved snapshot for widget:", snapshot.city, snapshot.temp)
        #endif
    }

    static func load() -> WidgetWeatherSnapshot? {
        guard
            let defaults = UserDefaults(suiteName: glasscastAppGroupID),
            let data = defaults.data(forKey: key),
            let snapshot = try? JSONDecoder().decode(WidgetWeatherSnapshot.self, from: data)
        else { return nil }

        #if DEBUG
        print("📦 [WidgetWeatherStore] Loaded snapshot in app:", snapshot.city, snapshot.temp)
        #endif

        return snapshot
    }
}
