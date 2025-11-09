//
//  GrammarTestViewModel.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation
import Observation

@Observable
class GrammarTestViewModel {
    
    // --- Network State ---
    var serverStatus: String = "Idle"
    private var networkManager: NetworkManager
    
    // --- On-Device Grammar State ---
    var inputText: String = """
    My new colleague's name is Budi. He is a smart man and also very friendly. He always helps me when I have problems with my computer. He speaks English very well, so we can communicate easily. I think he is a nice person and easy to work with. Everybody in the office likes him because he always smiles.
    """
    var correctedText: String = ""
    var validatedFlags: [ErrorFlag] = []
    var isCheckingGrammar: Bool = false
    private let grammarAnalyst: GrammarAnalyst
    
    // --- API Flagging State ---
    var flagApiResponse: String = ""
    var isFlaggingApi: Bool = false
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        self.grammarAnalyst = GrammarAnalyst()
    }
    
    // --- Network Functions ---
    @MainActor
    func checkServerHealth() async {
        serverStatus = "Checking..."
        do {
            let isOnline = try await networkManager.checkHealth()
            if isOnline {
                serverStatus = "Server is Online 🟢"
            }
        } catch {
            serverStatus = "Server is Offline 🔴: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func runApiFlagErrors() async {
        guard !isFlaggingApi else { return }
        
        isFlaggingApi = true
        flagApiResponse = "Flagging errors via API..."
        do {
            // This now uses the *final corrected text* from the full analysis
            let response = try await networkManager.flagErrors(
                original: inputText,
                corrected: correctedText
            )
            flagApiResponse = response
        } catch {
            flagApiResponse = "API Flagging Error: \(error.localizedDescription)"
        }
        isFlaggingApi = false
    }
    
    // --- On-Device Grammar Function (UPDATED) ---
    @MainActor
    func runFullAnalysis() async {
        isCheckingGrammar = true
        correctedText = "Checking..."
        validatedFlags = [] // Clear old flags
        flagApiResponse = "" // Clear old API response
        
        do {
            // Call the main function on the analyst
            let (finalCorrectedText, flags) = try await grammarAnalyst.runFullAnalysis(text: inputText)
            
            // Store both results
            correctedText = finalCorrectedText
            validatedFlags = flags
            
        } catch {
            correctedText = "Error during analysis: \(error.localizedDescription)"
        }
        isCheckingGrammar = false
    }
}
