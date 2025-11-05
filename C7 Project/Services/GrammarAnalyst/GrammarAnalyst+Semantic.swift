//
//  GrammarAnalyst+Semantic.swift
//  C7 Project
//
//  Created by Savio Enoson on 05/11/25.
//

import Foundation
import FoundationModels

// MARK: - Stage 2 & 3: Zipped Semantic Analysis
extension GrammarAnalyst {
    
    /// This is the "Stage 2 & 3 combined" function.
    /// It runs the full flagging and validation pipeline in parallel for all 3 categories.
    func runSemanticAnalysis(on text: String) async throws -> [ErrorFlag] {
        print("\n--- Analyst Stage 2+3: Zipped Flagging & Validation ---")

        // 1. Run all 3 categories in parallel.
        // Each function "zips" the flagging and validation process together.
        async let calqueFlags = flagAndValidateCategory(
            flaggingSession: calqueFlaggingSession,
            validatorSession: calqueValidatorSession,
            prompt: flagCalqueErrors(forTask: text),
            errorType: .Calque
        )
        
        async let collocationFlags = flagAndValidateCategory(
            flaggingSession: collocationFlaggingSession,
            validatorSession: collocationValidatorSession,
            prompt: flagCollocationErrors(forTask: text),
            errorType: .CollocationError
        )
        
        async let misselectionFlags = flagAndValidateCategory(
            flaggingSession: misselectionFlaggingSession,
            validatorSession: misselectionValidatorSession,
            prompt: flagMisselectionErrors(forTask: text),
            errorType: .Misselection
        )
        
        // 2. Await and pool all results
        let (calques, colls, misselections) = try await (calqueFlags, collocationFlags, misselectionFlags)
        
        let allValidFlags = calques + colls + misselections
        print("\nValidation Complete. Confirmed \(allValidFlags.count) total valid flags.")
        
        for flag in allValidFlags {
            print("\nFINAL VALID FLAG:\n\(flag)\n")
        }
        return allValidFlags
    }
    
    /// This function "zips" the flagging and validation process for a single category.
    /// It gets the *full* list of flags, *then* validates them sequentially.
    private func flagAndValidateCategory(
        flaggingSession: LanguageModelSession,
        validatorSession: LanguageModelSession,
        prompt: String,
        errorType: SemanticErrorType
    ) async throws -> [ErrorFlag] {

        print("[+] Starting Analysis for \(errorType.rawValue)")
        var validatedFlags: [ErrorFlag] = []

        // 1. Get the *full* array of flags. (Reverted from streamResponse)
        
        // STABILITY CHECK: Wait for the flagging session to be ready
        while flaggingSession.isResponding {
            print("    Flagging session for \(errorType.rawValue) is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100))
        }
        
        print("    Flagging \(errorType.rawValue)...")
        // Session is now guaranteed to be ready
        let allFlags = try await flaggingSession.respond(
            to: prompt,
            generating: [ErrorFlag].self, // We get a complete array
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        ).content
        
        print("    ...Flagging \(errorType.rawValue) complete. Found \(allFlags.count) potential flags. Now validating...")

        // 2. Process each new flag serially with the validator
        for flag in allFlags {
            
            // This 'await' ensures we process one flag at a time,
            // waiting for the validator to finish before starting the next.
            let isValid = try await validateFlag(flag, using: validatorSession)
            
            if isValid {
                print("    [VALID] \(errorType.rawValue): \(flag.sectionText)")
                validatedFlags.append(flag)
            } else {
                 print("    [INVALID] \(errorType.rawValue): \(flag.sectionText)")
            }
        }
        
        print("[-] Finished Analysis for \(errorType.rawValue). Found \(validatedFlags.count) valid flags.")
        return validatedFlags
    }
    
    /// Helper function to validate a single flag with the requested `isResponding` check.
    private func validateFlag(_ flag: ErrorFlag, using validatorSession: LanguageModelSession) async throws -> Bool {
        
        // 1. Fast exit for stylistic/identical flags
        guard flag.sectionText.lowercased() != flag.correctedSectionText.lowercased() else {
            print("        Validator: Skipping identical flag (no change).")
            return false
        }

        // 2. STABILITY CHECK: Explicitly wait for the session to be available
        // Corrected from isAvailable to isResponding
        while validatorSession.isResponding {
            print("        Validator: Session for \(flag.errorType.rawValue) is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100)) // Wait 100ms
        }
        
        // 3. Session is now available, proceed with validation
        print("        Validator: Session is available. Validating '\(flag.sectionText)'...")
        let response = try await validatorSession.respond(
            to: validateFlagPrompt(flag: flag),
            generating: ValidatorResponse.self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        )
        
        // Log the validator's reasoning
        print("        Validator Rationale: \(response.content.rationale)")
        
        return response.content.isValid
    }
}
