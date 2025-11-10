//
//  GrammarAnalyst.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

import Foundation
import NaturalLanguage
import FoundationModels

// MARK: - Generable Data Structures

@Generable
// Generable guide for the syntactic grammar-check model
struct TextBlock {
    @Guide(description: "Populate this field with the **original**, unedited input text.")
    let originalText: String
    
    @Guide(description: "Populate this field with the **corrected** version of the input text.")
    var correctedText: String = ""
}

// Lexical-semantic error types
@Generable(description: """
    Classifies the *type* of objective semantic error found.
    - Use **Calque** for structurally broken or un-English phrases.
    - Use **CollocationError** for unnatural, established word partnerships.
    - Use **Misselection** for a word that is the wrong *concept* for its context.
""")
enum SemanticErrorType: String, Decodable, CaseIterable {
    case Calque
    case CollocationError
    case Misselection
}

// Generable struct for the semantic grammar-check model
@Generable
struct ErrorFlag: CustomStringConvertible, Sendable, Hashable {
    @Guide(description: "Populate this field with the sentence within the paragraph where the error occurred. Keep this short but try to capture the necessary context.")
    let sectionText: String
    
    @Guide(description: "Populate this field with the identified error type (Calque, CollocationError, or Misselection).")
    let errorType: SemanticErrorType
    
    @Guide(description: "A short, technical explanation for why the section is an objective error and why the correction is necessary.")
    let errorRationale: String
    
    @Guide(description: "Provide the corrected version of the flagged sentence. It should first be **exactly the same as section text**; With the only difference being the **corrected part** of the sentence.")
    let correctedSectionText: String
    
    var description: String {
        return """
        Flag: \(self.errorType.rawValue)
        Section: \(self.sectionText)
        Correction: \(self.correctedSectionText)
        Rationale:
        \(self.errorRationale)
        """
    }
}

// Generable struct for the semantic-validator model
@Generable
struct ValidatorResponse: CustomStringConvertible, Sendable {
    @Guide(description: "A short, technical explanation for your decision, stating *why* the original text was (or was not) already correct in its context.")
    let rationale: String
    
    @Guide(description: "Populate this field with True (VALID flag) or False (INVALID flag).")
    let isValid: Bool
    
    var description: String {
        return """
        Verdict: \(self.isValid ? "VALID" : "INVALID")
        Rationale:
        \(self.rationale)
        """
    }
}


// MARK: - Grammar Analyst Actor
actor GrammarAnalyst {
    // --- Model Sessions ---
    let grammarCheckSession: LanguageModelSession
    
    let calqueFlaggingSession: LanguageModelSession
    let collocationFlaggingSession: LanguageModelSession
    let misselectionFlaggingSession: LanguageModelSession
    
    let calqueValidatorSession: LanguageModelSession
    let collocationValidatorSession: LanguageModelSession
    let misselectionValidatorSession: LanguageModelSession
    
    
    init() {
        // Initialize all 7 model sessions
        let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        
        self.grammarCheckSession = LanguageModelSession(model: model, instructions: grammarCheckSystemPrompt)
        
        self.calqueFlaggingSession = LanguageModelSession(model: model, instructions: calqueDetectionSystemPrompt)
        self.collocationFlaggingSession = LanguageModelSession(model: model, instructions: collocationDetectionSystemPrompt)
        self.misselectionFlaggingSession = LanguageModelSession(model: model, instructions: misselectionDetectionSystemPrompt)
        
        self.calqueValidatorSession = LanguageModelSession(model: model, instructions: validationModelSystemPrompt(errorType: .Calque))
        self.collocationValidatorSession = LanguageModelSession(model: model, instructions: validationModelSystemPrompt(errorType: .CollocationError))
        self.misselectionValidatorSession = LanguageModelSession(model: model, instructions: validationModelSystemPrompt(errorType: .Misselection))
    }
    
    /// Runs the full, multi-step analysis on a block of text.
    func runFullAnalysis(text: String) async throws -> (correctedText: String, validatedFlags: [ErrorFlag]) {
        
        // --- Stage 1: Initial Grammar Correction ---
        let correctedGrammarText = try await runSyntacticCheck(on: text)

        // --- Stage 2+3: Semantic Analysis ---
        let validatedFlags = try await runSemanticAnalysis(on: correctedGrammarText)
        
        // --- NEW: Stage 4: Apply Semantic Corrections ---
        let finalCorrectedText = applySemanticCorrections(on: correctedGrammarText, with: validatedFlags)
        
        return (correctedText: finalCorrectedText, validatedFlags: validatedFlags)
    }
    
    
    // MARK: - Stage 1: Syntactic (Grammar) Check
    
    /// Runs the initial grammar correction on the text.
    func runSyntacticCheck(on text: String) async throws -> String {
        print("--- Analyst Stage 1: Running Grammar Check ---")
        
        // STABILITY CHECK: Wait for the session to be ready
        while grammarCheckSession.isResponding {
            print("    GrammarCheckSession is busy. Waiting...")
            try await Task.sleep(for: .milliseconds(100))
        }
        
        print("    GrammarCheckSession is ready. Checking...")
        let prompt = checkAllCategories(forTask: text)
        
        // Session is now guaranteed to be ready
        let correctedGrammarText = try await grammarCheckSession.respond(
            to: prompt,
            generating: TextBlock.self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        ).content.correctedText
        
        print("Grammar Check Complete. Result: \(correctedGrammarText)")
        return correctedGrammarText
    }
    
    // MARK: - NEW: Stage 4: Apply Semantic Corrections
    
    /// Finds the differing phrases by trimming matching words from start and end.
    private func findReplacementPhrases(original: String, corrected: String) -> (String, String)? {
        let originalWords = original.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let correctedWords = corrected.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

        if originalWords.isEmpty || correctedWords.isEmpty {
            return nil
        }

        var startOffset = 0
        // Find matching prefix
        while startOffset < originalWords.count && startOffset < correctedWords.count && originalWords[startOffset] == correctedWords[startOffset] {
            startOffset += 1
        }

        var endOffsetOrig = originalWords.count
        var endOffsetCorr = correctedWords.count
        // Find matching suffix
        while endOffsetOrig > startOffset && endOffsetCorr > startOffset && originalWords[endOffsetOrig - 1] == correctedWords[endOffsetCorr - 1] {
            endOffsetOrig -= 1
            endOffsetCorr -= 1
        }
        
        // If the whole string was identical, no changes needed.
        if startOffset >= endOffsetOrig && startOffset >= endOffsetCorr {
             return nil
        }

        let originalPhrase = originalWords[startOffset..<endOffsetOrig].joined(separator: " ")
        let correctedPhrase = correctedWords[startOffset..<endOffsetCorr].joined(separator: " ")
        
        // Ensure we're not just getting empty strings
        if originalPhrase.isEmpty && correctedPhrase.isEmpty {
            return nil
        }

        return (originalPhrase, correctedPhrase)
    }
    
    /// Applies the validated semantic corrections to the text.
    private func applySemanticCorrections(on text: String, with flags: [ErrorFlag]) -> String {
//        print("\n--- Analyst Stage 4: Applying Semantic Corrections ---")
        var currentText = text
        
        if flags.isEmpty {
//            print("    No semantic flags to apply. Returning text from Stage 1.")
            return currentText
        }
        
        for flag in flags.reversed() {
//            print("    Applying \(flag.errorType.rawValue) flag...")
    
            if let (originalPhrase, correctedPhrase) = findReplacementPhrases(original: flag.sectionText, corrected: flag.correctedSectionText) {
                let punctuationToTrim = CharacterSet.punctuationCharacters
                let cleanedOriginalPhrase = originalPhrase.trimmingCharacters(in: punctuationToTrim)
                let cleanedCorrectedPhrase = correctedPhrase.trimmingCharacters(in: punctuationToTrim)

//                print("    - Diff found. Replacing first occurrence of: \"\(cleanedOriginalPhrase)\"")
//                print("    - With: \"\(cleanedCorrectedPhrase)\"")
                
                // Find the range of the *last* occurrence (since we're reversed), case-insensitively.
                // We search for the *cleaned* phrase.
                if let range = currentText.range(of: cleanedOriginalPhrase, options: [.caseInsensitive, .diacriticInsensitive, .backwards]) {
                    // We replace with the *cleaned* correction.
                    currentText.replaceSubrange(range, with: cleanedCorrectedPhrase)
//                    print("    - Replacement successful.")
                } else {
//                    print("    - **WARNING**: Could not find \"\(cleanedOriginalPhrase)\" in text. Trying full sentence fallback...")
                    tryFallbackReplacement(for: flag)
                }
            } else {
                // FALLBACK: If no word-diff, perform the simple replacement
                tryFallbackReplacement(for: flag)
            }
        }
        
        /// Fallback replacement in case logic fails
        func tryFallbackReplacement(for flag: ErrorFlag) {
            let punctuationToTrim = CharacterSet.punctuationCharacters
            let cleanedSectionText = flag.sectionText.trimmingCharacters(in: punctuationToTrim)
            let cleanedCorrectionText = flag.correctedSectionText.trimmingCharacters(in: punctuationToTrim)
            
//            print("    - FALLBACK: Replacing: \"\(cleanedSectionText)\"")
            
            // Search from the end (.backwards) for the *cleaned* text
            if let range = currentText.range(of: cleanedSectionText, options: [.caseInsensitive, .diacriticInsensitive, .backwards]) {
                // Replace with the *cleaned* correction
                currentText.replaceSubrange(range, with: cleanedCorrectionText)
//                print("    - Fallback successful.")
            } else {
//                print("    - **FATAL**: Fallback replacement failed. Skipping flag.")
            }
        }
        
//        print("--- Semantic Corrections Applied. Final Text: \(currentText) ---")
        return currentText
    }
    
    // MARK: - DEBUG FUNCTION TO FINETUNE SYSTEM PROMPTS
    /// Runs the analysis for a *single semantic category*, with an option to validate.
    /// This is useful for fine-tuning a specific model.
    func runAnalysisForTuning(on text: String, category: SemanticErrorType, doValidation: Bool) async throws -> (correctedText: String, flags: [ErrorFlag]) {
        
        // --- Stage 1: Initial Grammar Correction ---
        let correctedGrammarText = try await runSyntacticCheck(on: text)
//        let correctedGrammarText  = text

        // --- Stage 2 (and optional 3): Semantic Flagging ---
        let flags: [ErrorFlag]
        
        // Select the correct sessions and prompt based on the category
        let (flaggingSession, validatorSession, prompt): (LanguageModelSession, LanguageModelSession, String) = {
            switch category {
            case .Calque:
                return (calqueFlaggingSession, calqueValidatorSession, flagCalqueErrors(forTask: correctedGrammarText))
            case .CollocationError:
                return (collocationFlaggingSession, collocationValidatorSession, flagCollocationErrors(forTask: correctedGrammarText))
            case .Misselection:
                return (misselectionFlaggingSession, misselectionValidatorSession, flagMisselectionErrors(forTask: correctedGrammarText))
            }
        }()
        
        if doValidation {
            // Run Stage 2 + 3 (Flag and Validate)
            print("\n--- Analyst Tuning: Running Flag & Validate for \(category.rawValue) ---")
            flags = try await flagAndValidateCategory(
                flaggingSession: flaggingSession,
                validatorSession: validatorSession,
                prompt: prompt,
                errorType: category
            )
        } else {
            // Run Stage 2 ONLY (Flag)
            print("\n--- Analyst Tuning: Running Flag-Only for \(category.rawValue) ---")
            flags = try await flagCategory(
                flaggingSession: flaggingSession,
                prompt: prompt,
                errorType: category
            )
        }
        
        // --- Stage 4: Apply Semantic Corrections ---
        // We apply the resulting flags (either validated or raw)
        let finalCorrectedText = applySemanticCorrections(on: correctedGrammarText, with: flags)
        
        return (correctedText: finalCorrectedText, flags: flags)
    }
}
