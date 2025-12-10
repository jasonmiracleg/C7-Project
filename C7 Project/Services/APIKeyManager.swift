//
//  APIKeyManager.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation

struct APIKeyManager {
    /// Safely retrieves the API_KEY from the app's Info.plist
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist. Have you configured the Keys.xcconfig file?")
        }
        
        if key == "YOUR_API_KEY_GOES_HERE" {
             fatalError("Please update API_KEY in Keys.xcconfig with your actual API key.")
        }
        
        return key
    }
}
