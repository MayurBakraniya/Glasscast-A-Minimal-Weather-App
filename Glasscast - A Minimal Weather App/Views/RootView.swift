//
//  RootView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            if showSplash {
                SplashView(isActive: $showSplash)
                    .transition(.opacity)
                    .zIndex(2)
            } else {
                Group {
                    if authViewModel.isAuthenticated {
                        MainTabView()
                            .environmentObject(authViewModel)
                            .transition(.opacity)
                    } else {
                        AuthView()
                            .transition(.opacity)
                    }
                }
                .zIndex(1)
                .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
            }
        }
        .task {
            authViewModel.checkAuthStatus()
        }
    }
}
