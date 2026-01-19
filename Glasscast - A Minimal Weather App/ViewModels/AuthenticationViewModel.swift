//
//  AuthenticationViewModel.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let supabase = SupabaseManager.shared.supabase
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                isAuthenticated = true
                currentUser = session.user
            } catch {
                // If no session exists, user is not authenticated
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate email format
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Validate password
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        do {
            let response = try await supabase.auth.signUp(
                email: trimmedEmail,
                password: password
            )
            
            // If we got a session, user is automatically signed in
            if let session = response.session {
                currentUser = session.user
                isAuthenticated = true
            } else {
                // If no session, try to sign in immediately
                do {
                    let signInResponse = try await supabase.auth.signIn(
                        email: trimmedEmail,
                        password: password
                    )
                    currentUser = signInResponse.user
                    isAuthenticated = true
                } catch {
                    // If sign in fails, still set user from sign up response
                    currentUser = response.user
                    isAuthenticated = true
                }
            }
        } catch {
            let errorString = error.localizedDescription
            if errorString.contains("already registered") || errorString.contains("already exists") {
                errorMessage = "An account with this email already exists. Please sign in instead."
            } else if errorString.contains("network") || errorString.contains("connection") {
                errorMessage = "Network error. Please check your connection."
            } else {
                errorMessage = "Failed to create account: \(error.localizedDescription)"
            }
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate email format
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@") && trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        // Validate password
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        do {
            let response = try await supabase.auth.signIn(
                email: trimmedEmail,
                password: password
            )
            currentUser = response.user
            isAuthenticated = true
        } catch {
            // Better error messages
            let errorString = error.localizedDescription.lowercased()
            
            if errorString.contains("invalid login credentials") || 
               errorString.contains("invalid") ||
               errorString.contains("email not found") ||
               errorString.contains("user not found") {
                errorMessage = "Invalid email or password. Please check your credentials and try again."
            } else if errorString.contains("network") || errorString.contains("connection") {
                errorMessage = "Network error. Please check your connection."
            } else {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate email format
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        do {
            try await supabase.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "glasscast://reset-password")
            )
            // Success - no error message
        } catch {
            let errorString = error.localizedDescription
            if errorString.contains("network") || errorString.contains("connection") {
                errorMessage = "Network error. Please check your connection."
            } else {
                errorMessage = "Failed to send reset email. Please try again."
            }
        }
        
        isLoading = false
    }
}
