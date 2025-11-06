//
//  GrammarAnalyst+Semantic.swift
//  C7 Project
//
//  Created by Savio Enoson on 05/11/25.
//

import Foundation
import FoundationModels

extension GrammarAnalyst {
    // MARK: - Stage 2+3: Flag and Validate
    
    /// Runs the full semantic analysis pipeline: flags in parallel, then validates each flag.
    func runSemanticAnalysis(on text: String) async throws -> [ErrorFlag] {
        print("\n--- Analyst Stage 2+3: Running Full Semantic Analysis ---")
        
        // Run all 3 categories in parallel.
        // Each function flags AND validates its own category.
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
        
        // Await and pool the results
        let allValidatedFlags = try await (calqueFlags + collocationFlags + misselectionFlags)
        
        print("--- Semantic Analysis Complete. Total Valid Flags: \(allValidatedFlags.count) ---")
        return allValidatedFlags
    }
    
    /// Helper: Flags all errors for a category, then validates them one by one.
    func flagAndValidateCategory(
        flaggingSession: LanguageModelSession,
        validatorSession: LanguageModelSession,
        prompt: String,
        errorType: SemanticErrorType
    ) async throws -> [ErrorFlag] {

//        print("[+] Starting Analysis for \(errorType.rawValue)")
        var validatedFlags: [ErrorFlag] = []

        // Delay operation if associated model is busy
        while flaggingSession.isResponding {
//            print("    FlaggingSession \(errorType.rawValue) is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100))
        }
        
        // 1. Get the full, unfiltered array of error flags
//        print("    Flagging \(errorType.rawValue)...")
        let allFlags = try await flaggingSession.respond(
            to: prompt,
            generating: [ErrorFlag].self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        ).content
        
//        print("    ...Flagging \(errorType.rawValue) complete. Found \(allFlags.count) potential flags. Now validating...")

        // 2. Process each new flag serially with the validator
        for flag in allFlags {
            let isValid = try await validateFlag(flag, using: validatorSession)
            
            // Print validator verdict
            if isValid {
//                print("    [VALID] \(errorType.rawValue): \(flag.sectionText)")
                validatedFlags.append(flag)
            } else {
//                 print("    [INVALID] \(errorType.rawValue): \(flag.sectionText)")
            }
        }
        
//        print("[-] Finished Analysis for \(errorType.rawValue). Found \(validatedFlags.count) valid flags.")
        return validatedFlags
    }

    /// Helper: Validates a single flag using its dedicated session.
    private func validateFlag(_ flag: ErrorFlag, using validatorSession: LanguageModelSession) async throws -> Bool {
        // Delay operation if associated model is busy
        while validatorSession.isResponding {
//            print("    ValidatorSession for \(flag.errorType.rawValue) is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100))
        }

        let response = try await validatorSession.respond(
            to: validateFlagPrompt(flag: flag),
            generating: ValidatorResponse.self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        )
        
        print("""
        Error Flag:
        \(flag)
        ----------
        Validation Verict:
        \(response.content)
        """)
        
        return response.content.isValid
    }
    
    
    // MARK: - DEBUG METHOD FOR FINE-TUNING

    /// Runs *only* the semantic flagging stage, skipping validation.
    func runSemanticFlaggingOnly(on text: String) async throws -> [ErrorFlag] {
        print("\n--- Analyst Stage 2 (Tuning): Running Semantic Flagging ONLY ---")
        
        // Run all 3 categories in parallel.
        async let calqueFlags = flagCategory(
            flaggingSession: calqueFlaggingSession,
            prompt: flagCalqueErrors(forTask: text),
            errorType: .Calque
        )
        
        async let collocationFlags = flagCategory(
            flaggingSession: collocationFlaggingSession,
            prompt: flagCollocationErrors(forTask: text),
            errorType: .CollocationError
        )
        
        async let misselectionFlags = flagCategory(
            flaggingSession: misselectionFlaggingSession,
            prompt: flagMisselectionErrors(forTask: text),
            errorType: .Misselection
        )
        
        // Await and pool the results
        let allFlags = try await (calqueFlags + collocationFlags + misselectionFlags)
        
        print("--- Semantic Flagging Complete. Total Flags Found: \(allFlags.count) ---")
        return allFlags
    }
    
    /// Helper: Flags all errors for a category (no validation).
    func flagCategory(
        flaggingSession: LanguageModelSession,
        prompt: String,
        errorType: SemanticErrorType
    ) async throws -> [ErrorFlag] {

        print("[+] Starting Flagging for \(errorType.rawValue)")

        // --- STABILITY CHECK ---
        while flaggingSession.isResponding {
            print("    FlaggingSession \(errorType.rawValue) is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100))
        }
        
        let allFlags = try await flaggingSession.respond(
            to: prompt,
            generating: [ErrorFlag].self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        ).content
        
        print("[-] Finished Flagging for \(errorType.rawValue). Found \(allFlags.count) flags.")
        return allFlags
    }
}
