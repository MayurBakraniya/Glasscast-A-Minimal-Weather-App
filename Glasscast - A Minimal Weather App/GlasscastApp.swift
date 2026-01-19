//
//  GlasscastApp.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI
import Supabase

@main
struct GlasscastApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        // Initialize Supabase client
        SupabaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .preferredColorScheme(.dark) // Force dark mode to prevent white flashes
        }
    }
}
