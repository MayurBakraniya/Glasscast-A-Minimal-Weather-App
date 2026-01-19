//
//  SettingsView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI
import Supabase

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showSignOutAlert = false
    
    @State private var appear = false
    @State private var iconRotation: Double = 0
    @State private var iconPulse: Bool = false
    @State private var iconGlow: Double = 0.5
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // App Info with enhanced animations
                    VStack(spacing: 16) {
                        ZStack {
                            // Glowing background circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.6, blue: 1.0).opacity(iconGlow * 0.3),
                                            Color(red: 0.6, green: 0.4, blue: 1.0).opacity(iconGlow * 0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .blur(radius: 15)
                            
                            // App Icon
                            Image(systemName: "cloud.sun.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(AppColors.accentGradient)
                                .scaleEffect(iconPulse ? 1.1 : 1.0)
//                                .rotationEffect(.degrees(iconRotation))
                                .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.5), radius: 15, x: 0, y: 5)
                        }
                        .scaleEffect(appear ? 1.0 : 0.3)
                        .opacity(appear ? 1 : 0)
                        
                        VStack(spacing: 8) {
                            Text("Glasscast")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                            
                            Text("Minimal Weather App")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // User Info Section (if available)
                    if let user = authViewModel.currentUser {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3),
                                                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.4, green: 0.6, blue: 1.0),
                                                Color(red: 0.6, green: 0.4, blue: 1.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(userEmail(user))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.green.opacity(0.8))
                                        .frame(width: 8, height: 8)
                                    
                                    Text("Signed in")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .glassEffect()
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 30)
                        .scaleEffect(appear ? 1.0 : 0.95)
                    }
                    
                    // Settings Section
                    VStack(spacing: 24) {
                        // Temperature Unit
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2),
                                                    Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "thermometer")
                                        .font(.system(size: 20))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.6, blue: 1.0),
                                                    Color(red: 0.6, green: 0.4, blue: 1.0)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                                Text("Temperature Unit")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                ForEach(Array(TemperatureUnit.allCases.enumerated()), id: \.element) { index, unit in
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            settingsViewModel.setTemperatureUnit(unit)
                                        }
                                    } label: {
                                        Text(unit.rawValue)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(
                                                settingsViewModel.temperatureUnit == unit ? .white : .white.opacity(0.6)
                                            )
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(
                                                Group {
                                                    if settingsViewModel.temperatureUnit == unit {
                                                        LinearGradient(
                                                            colors: [
                                                                Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3),
                                                                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2)
                                                            ],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    } else {
                                                        Color.white.opacity(0.05)
                                                    }
                                                }
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        settingsViewModel.temperatureUnit == unit
                                                            ? LinearGradient(
                                                                colors: [
                                                                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.6),
                                                                    Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.4)
                                                                ],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                            : LinearGradient(
                                                                colors: [.white.opacity(0.1)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                        lineWidth: settingsViewModel.temperatureUnit == unit ? 2 : 1
                                                    )
                                            )
                                            .scaleEffect(settingsViewModel.temperatureUnit == unit ? 1.05 : 1.0)
                                            .shadow(
                                                color: settingsViewModel.temperatureUnit == unit
                                                    ? Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3)
                                                    : Color.clear,
                                                radius: settingsViewModel.temperatureUnit == unit ? 8 : 0
                                            )
                                    }
                                    .opacity(appear ? 1 : 0)
                                    .offset(x: appear ? 0 : (index == 0 ? -30 : 30))
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.1),
                                        value: appear
                                    )
                                }
                            }
                        }
                        .padding(24)
                        .glassEffect()
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 30)
                        .scaleEffect(appear ? 1.0 : 0.95)
                        
                        // Sign Out
                        Button {
                            showSignOutAlert = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "arrow.right.square.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.red.opacity(0.9))
                                }
                                
                                Text("Sign Out")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(0.2),
                                        Color.red.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.red.opacity(0.5),
                                                Color.red.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .red.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        .opacity(appear ? 1 : 0)
//                        .offset(y: appear ? 0 : 30)
                        .scaleEffect(appear ? 1.0 : 0.95)
                    }
                    .padding(.top, 20)
                    
                    // Version Info
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12))
                            Text("Version 1.0.0")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.6))
                        
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12))
                            Text("Built with AI assistance")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                }
                .padding(.horizontal, 20) // global leading/trailing spacing
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
            
            // Start icon animations
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                iconRotation = 360
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                iconPulse = true
            }
            
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                iconGlow = 1.0
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authViewModel.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // Helper function to safely access user email
    private func userEmail(_ user: User) -> String {
        // Try to access email from user metadata
        // userMetadata is a dictionary [String : AnyJSON]
        if let emailValue = user.userMetadata["email"] {
            // Convert AnyJSON to String
            switch emailValue {
            case .string(let emailString):
                return emailString
            default:
                break
            }
        }
        // Fallback: return generic user text
        return "User"
    }
}
