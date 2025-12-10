//
//  NetworkManager.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation

// Define a custom error for bad server responses
enum NetworkError: Error, LocalizedError {
    case serverError(statusCode: Int)
    case unknownError
    case invalidRequest
    case dataToStringError
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .serverError(let statusCode):
            return "Server returned an error: \(statusCode)"
        case .invalidRequest:
            return "Invalid Request Structure."
        case .unknownError:
            return "An unknown network error occurred."
        case .dataToStringError:
            return "Failed to decode the server response."
        case .decodingError(let error):
            return "Failed to decode JSON: \(error.localizedDescription)"
        }
    }
}

class NetworkManager {
    
    // A shared instance for easy access (Singleton)
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0 // 10 seconds timeout for each attempt
        config.timeoutIntervalForResource = 60.0
        
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Checks the health of the API server.
    func checkHealth(for model: APIRouter) async throws -> Bool {
        let request: URLRequest
        switch model {
        case .grammarModelHealth:
            request = try APIRouter.grammarModelHealth.asURLRequest()
        case .pronunciationModelHealth:
            request = try APIRouter.pronunciationModelHealth.asURLRequest()
        default:
            throw NetworkError.invalidRequest
        }
        
        let (_, response) = try await performRetryableRequest(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return true
    }
    
    /// Sends the original and corrected text to the /flag endpoint
    /// and returns a dictionary of grouped errors.
    func flagErrors(original: String, corrected: String) async throws -> [SyntacticErrorType: [GrammarError]] {
        
        let request = try APIRouter.flagErrors(original: original, corrected: corrected).asURLRequest()
        
        let (data, response) = try await performRetryableRequest(request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Decode the JSON response into [String: [GrammarError]]
        let decodedResponse: [String: [GrammarError]]
        do {
            decodedResponse = try decoder.decode([String: [GrammarError]].self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
        
        // Transform the dictionary to use your SyntacticErrorType enum
        var groupedErrors = [SyntacticErrorType: [GrammarError]]()
        
        for (key, value) in decodedResponse {
            let errorType = SyntacticErrorType(jsonKey: key)
            groupedErrors[errorType] = value
        }
        
        return groupedErrors
    }
    
    // MARK: - Retry Logic Helper
    
    /// Executes a URLRequest with automatic retries for specific network errors (timeouts, connection lost).
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - maxRetries: Maximum number of retry attempts (default 2, meaning 3 total attempts).
    ///   - initialDelay: Delay in seconds before the first retry (doubles for subsequent retries).
    private func performRetryableRequest(
        _ request: URLRequest,
        maxRetries: Int = 2,
        initialDelay: TimeInterval = 1.0
    ) async throws -> (Data, URLResponse) {
        
        var attempts = 0
        var currentDelay = initialDelay
        
        while true {
            do {
                attempts += 1
                return try await session.data(for: request)
            } catch let error as URLError {
                // Check if we have retries left AND if the error is one we should retry
                guard attempts <= maxRetries && isRetriable(error) else {
                    throw error // Exhausted retries or non-retriable error
                }
                
                print("⚠️ Network request failed (Attempt \(attempts)). Retrying in \(currentDelay)s... Error: \(error.localizedDescription)")
                
                // Wait before retrying
                try await Task.sleep(nanoseconds: UInt64(currentDelay * 1_000_000_000))
                
                // Exponential backoff: double the delay for the next attempt
                currentDelay *= 2
            }
        }
    }
    
    /// Determines if a network error is worth retrying.
    private func isRetriable(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut,
             .networkConnectionLost,
             .notConnectedToInternet,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
}
