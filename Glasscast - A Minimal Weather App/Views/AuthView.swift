//
//  AuthView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showForgotPassword = false
    @State private var appear = false
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 0) {
                    // App Title Section
                    VStack(spacing: 12) {
                        Image(systemName: "cloud.sun.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(AppColors.accentGradient)
                            .scaleEffect(appear ? 1.0 : 0.5)
                            .rotationEffect(.degrees(appear ? 0 : -180))
                            .padding(.top, 60)
                        
                        Text("Glasscast")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                        
                        Text("Minimal Weather")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                    }
                    .padding(.bottom, 50)
                    
                    // Auth Form with Glass Effect
                    VStack(spacing: 24) {
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 30)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(GlassTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                SecureField("Enter your password", text: $password)
                                    .textFieldStyle(GlassTextFieldStyle())
                                    .textContentType(isSignUp ? .newPassword : .password)
                            }
                            
                            // Forgot Password (only for Sign In)
                            if !isSignUp {
                                HStack {
                                    Spacer()
                                    Button {
                                        showForgotPassword = true
                                    } label: {
                                        Text("Forgot Password?")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color(red: 0.4, green: 0.6, blue: 1.0))
                                    }
                                }
                            }
                            
                            // Error Message
                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.red.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }
                            
                            // Submit Button
                            Button {
                                Task {
                                    if isSignUp {
                                        await authViewModel.signUp(email: email, password: password)
                                    } else {
                                        await authViewModel.signIn(email: email, password: password)
                                    }
                                }
                            } label: {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(isSignUp ? "Sign Up" : "Sign In")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                            }
                            .buttonStyle(GlassButtonStyle())
                            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                            
                            // Toggle Sign Up/Sign In
                            HStack(spacing: 4) {
                                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                Button {
                                    withAnimation {
                                        isSignUp.toggle()
                                        authViewModel.errorMessage = nil
                                        email = ""
                                        password = ""
                                    }
                                } label: {
                                    Text(isSignUp ? "Sign In" : "Sign Up")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.4, green: 0.6, blue: 1.0))
                                }
                            }
                        }
                    }
                    .padding(28)
                    .glassEffect()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authViewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appear = true
            }
        }
    }
}

// MARK: - Glass Effect Styles
struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundStyle(.white)
    }
}

struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [
                        .white.opacity(0.25),
                        .white.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Glass Effect Modifier
extension View {
    @ViewBuilder
    func glassEffect() -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26 Liquid Glass native support
            self
                .glassEffect(in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        } else {
            // Fallback for iOS 17+
            self
                .background(.ultraThinMaterial.opacity(0.3))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}
