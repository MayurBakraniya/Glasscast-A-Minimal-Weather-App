//
//  AppColors.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct AppColors {
    // Background Gradients - More vibrant colors
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.08, blue: 0.18),
                Color(red: 0.15, green: 0.10, blue: 0.25),
                Color(red: 0.20, green: 0.12, blue: 0.30)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.5, blue: 0.9),
                Color(red: 0.5, green: 0.3, blue: 0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Glass effect colors
    static var glassBackground: some View {
        ZStack {
            Color.white.opacity(0.15)
            Color.blue.opacity(0.05)
        }
    }
    
    // Text colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.8)
    static let tertiaryText = Color.white.opacity(0.6)
}
