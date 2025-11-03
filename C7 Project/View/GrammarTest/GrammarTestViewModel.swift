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
    var flaggingResponse: String = ""
    var isFlagging: Bool = false
    
    // --- On-Device Grammar State ---
    var inputText: String = """
        I visit a cafe new last weekend with my friends. The place very nice and have many decoration beautiful. I see two cat sleeping near the window, and they so cute. The coffee good, but the cake a little too sweet for me. I think it is good place to relax with some friend on Saturday.
    """
    var correctedText: String = ""
    var isCheckingGrammar: Bool = false
    private let grammarAnalyst: GrammarAnalyst // Instance of the actor
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        self.grammarAnalyst = GrammarAnalyst() // Initialize the analyst
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
    func runFlagErrors() async {
        guard !isCheckingGrammar, !correctedText.isEmpty else { return }
        
        isFlagging = true
        flaggingResponse = "Flagging errors..."
        do {
            let response = try await networkManager.flagErrors(original: inputText, corrected: correctedText)
            flaggingResponse = response
        } catch {
            flaggingResponse = "Error flagging errors: \(error.localizedDescription)"
        }
        isFlagging = false
    }

    // --- On-Device Grammar Function ---
    @MainActor
    func runGrammarCheck() async {
        isCheckingGrammar = true
        correctedText = "Checking..."
        flaggingResponse = "" // Clear previous flag response
        do {
            // Call the actor's correctGrammar function
            let result = try await grammarAnalyst.correctGrammar(text: inputText)
            correctedText = result
        } catch {
            correctedText = "Error correcting grammar: \(error.localizedDescription)"
        }
        isCheckingGrammar = false
    }
}
