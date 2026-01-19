//
//  SupabaseManager.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private var client: SupabaseClient?
    
    private init() {}
    
    func configure() {
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            print("⚠️ Supabase credentials not found. Please configure in Info.plist")
            return
        }
        
        client = SupabaseClient(supabaseURL: URL(string: supabaseURL)!, supabaseKey: supabaseKey)
    }
    
    var supabase: SupabaseClient {
        guard let client = client else {
            fatalError("Supabase client not configured. Please check your credentials.")
        }
        return client
    }
}
