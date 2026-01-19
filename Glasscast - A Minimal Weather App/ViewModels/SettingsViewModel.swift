//
//  SettingsViewModel.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var temperatureUnit: TemperatureUnit = .celsius
    
    private let userDefaults = UserDefaults.standard
    private let temperatureUnitKey = "temperatureUnit"
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let unitString = userDefaults.string(forKey: temperatureUnitKey),
           let unit = TemperatureUnit(rawValue: unitString) {
            temperatureUnit = unit
        }
    }
    
    func setTemperatureUnit(_ unit: TemperatureUnit) {
        temperatureUnit = unit
        userDefaults.set(unit.rawValue, forKey: temperatureUnitKey)
    }
}
