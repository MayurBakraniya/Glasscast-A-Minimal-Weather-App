//
//  WeatherBackground.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct WeatherBackground {
    // Apple Weather-style background colors based on weather condition
    static func backgroundGradient(for condition: String, icon: String) -> LinearGradient {
        let conditionLower = condition.lowercased()
        
        // Clear/Sunny - Blue gradient (like Apple Weather)
        if conditionLower.contains("clear") || icon.contains("01") {
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),  // Light blue
                    Color(red: 0.3, green: 0.6, blue: 0.95), // Medium blue
                    Color(red: 0.4, green: 0.7, blue: 1.0)   // Bright blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        // Rain - Dark blue/gray
        else if conditionLower.contains("rain") || icon.contains("09") || icon.contains("10") {
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.5),  // Dark blue-gray
                    Color(red: 0.25, green: 0.35, blue: 0.55),
                    Color(red: 0.3, green: 0.4, blue: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        // Snow - Light blue/white
        else if conditionLower.contains("snow") || icon.contains("13") {
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.5, blue: 0.7),  // Light blue-gray
                    Color(red: 0.45, green: 0.55, blue: 0.75),
                    Color(red: 0.5, green: 0.6, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        // Thunderstorm - Dark purple/blue
        else if conditionLower.contains("thunder") || icon.contains("11") {
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.3),  // Dark purple-blue
                    Color(red: 0.2, green: 0.2, blue: 0.35),
                    Color(red: 0.25, green: 0.25, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        // Cloudy/Fog - Gray
        else if conditionLower.contains("cloud") || conditionLower.contains("fog") || icon.contains("50") {
            return LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.35, blue: 0.4),  // Gray
                    Color(red: 0.35, green: 0.4, blue: 0.45),
                    Color(red: 0.4, green: 0.45, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        // Default - Blue gradient
        else {
            return LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.5, blue: 0.85),
                    Color(red: 0.3, green: 0.55, blue: 0.9),
                    Color(red: 0.35, green: 0.6, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
