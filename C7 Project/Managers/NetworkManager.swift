//
//  NetworkManager.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation

// Error message for bad API responses
enum NetworkError: Error, LocalizedError {
    case serverError(statusCode: Int)
    case unknownError
    case dataToStringError
    
    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode):
            return "Server returned an error: \(statusCode)"
        case .unknownError:
            return "An unknown network error occurred."
        case .dataToStringError:
            return "Failed to decode the server response."
        }
    }
}


// Singleton for accessing external APIs
class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        self.session = URLSession.shared
    }
    
    /// Checks the health of the API server.
    /// Returns `true` if the server returns HTTP 200, otherwise throws an error.
    func checkHealth() async throws -> Bool {
        let request = try APIRouter.grammarModelHealth.asURLRequest()
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return true
    }
    
    /// Sends the original and corrected text to the /flag endpoint.
    /// Returns the raw JSON string response.
    /// TODO: Parse properly into individual enums for classification or tagging
    func flagErrors(original: String, corrected: String) async throws -> String {
        let request = try APIRouter.flagErrors(original: original, corrected: corrected).asURLRequest()
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Convert the raw Data to a String
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NetworkError.dataToStringError
        }
        
        return jsonString
    }
}
