//
//  ForgotPasswordView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var isSent = false
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
                .zIndex(0)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Icon
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundStyle(AppColors.accentGradient)
                            .padding(.top, 40)
                        
                        // Title
                        VStack(spacing: 12) {
                            Text("Forgot Password?")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text(isSent ? "Check your email for password reset instructions" : "Enter your email address and we'll send you a link to reset your password")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        if !isSent {
                            // Email Field
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                TextField("Enter your email", text: $email)
                                    .textFieldStyle(GlassTextFieldStyle())
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.emailAddress)
                            }
                            .padding(.horizontal, 24)
                            
                            // Error Message
                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.red.opacity(0.9))
                                    .padding(.horizontal, 24)
                            }
                            
                            // Send Button
                            Button {
                                Task {
                                    await authViewModel.resetPassword(email: email)
                                    if authViewModel.errorMessage == nil {
                                        isSent = true
                                    }
                                }
                            } label: {
                                Text("Send Reset Link")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                            .buttonStyle(GlassButtonStyle())
                            .disabled(authViewModel.isLoading || email.isEmpty)
                            .padding(.horizontal, 24)
                        } else {
                            // Success State
                            Button {
                                dismiss()
                            } label: {
                                Text("Back to Sign In")
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                            .buttonStyle(GlassButtonStyle())
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}
