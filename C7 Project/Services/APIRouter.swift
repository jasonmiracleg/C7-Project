//
//  APIRouter.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation

// Data structure to store flagging requests
struct FlagRequest: Codable {
    let original_text: String
    let corrected_text: String
}

enum APIRouter {
    // Base URL TODO: Change to actual REST API URL later
    private var baseURL: String {
        return "https://c7m1-rest-api.my.id"
    }
    
    case grammarModelHealth
    case flagErrors(original: String, corrected: String)
    case pronunciationModelHealth
    case scorePronunciation(targetText: String, audioFile: FileWrapper) // Replace with actual file type

    private var path: String {
        switch self {
        case .grammarModelHealth:
            return "/grammar/health"
        case .flagErrors:
            return "/grammar/flag/"
            
        case .pronunciationModelHealth:
            return "/pronunciation/health"
        case .scorePronunciation:
            return "/pronunciation/score/"
        }
    }
    
    // Returns the HTTP method
    private var method: String {
        switch self {
        case .grammarModelHealth:
            return "GET"
        case .flagErrors:
            return "POST"
        case .pronunciationModelHealth:
            return "GET"
        case .scorePronunciation(targetText: let targetText, audioFile: let audioFile):
            return "POST"
        }
    }
    
    // Builds a URLRequest object
    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // --- Add Headers ---
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // --- FIX: Match the API documentation's Authorization header ---
        // The curl example uses: -H "Authorization: Api-Key <YOUR_API_KEY>"
        request.setValue("Api-Key \(APIKeyManager.apiKey)", forHTTPHeaderField: "Authorization")

        
        // --- Add Body for POST/PUT requests ---
        switch self {
        case .flagErrors(let original, let corrected):
            let body = FlagRequest(original_text: original, corrected_text: corrected)
            let data = try JSONEncoder().encode(body)
            request.httpBody = data
        default:
            // No body for .healthCheck
            break
        }
        
        return request
    }
}
