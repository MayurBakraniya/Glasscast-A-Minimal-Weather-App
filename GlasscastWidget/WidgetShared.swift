//
//  WidgetShared.swift
//  GlasscastWidget
//
//  Shared helpers for the widget extension.
//

import Foundation

// Must match the App Group configured for both app and widget.
let glasscastAppGroupID = "group.com.Glasscast.GlasscastWidget"

struct WidgetWeatherSnapshot: Codable {
    let city: String
    let temp: Double
    let conditionIcon: String
    let timestamp: Date
}

enum WidgetWeatherStore {
    private static let key = "widgetWeather"

    static func load() -> WidgetWeatherSnapshot? {
        print("🔍 [Widget] Attempting to load snapshot from App Group: \(glasscastAppGroupID)")
        
        guard let defaults = UserDefaults(suiteName: glasscastAppGroupID) else {
            print("❌ [Widget] Failed to access UserDefaults with App Group: \(glasscastAppGroupID)")
            return nil
        }
        
        guard let data = defaults.data(forKey: key) else {
            print("❌ [Widget] No data found for key: \(key)")
            return nil
        }
        
        print("✅ [Widget] Found data, size: \(data.count) bytes")
        
        guard let snapshot = try? JSONDecoder().decode(WidgetWeatherSnapshot.self, from: data) else {
            print("❌ [Widget] Failed to decode snapshot data")
            return nil
        }

        print("✅ [Widget] Successfully loaded snapshot: \(snapshot.city) \(snapshot.temp)°")
        return snapshot
    }
}
