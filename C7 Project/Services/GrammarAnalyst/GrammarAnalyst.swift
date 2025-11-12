import Foundation
import FoundationModels


class GrammarAnalyst {
    static let shared = GrammarAnalyst()
    
    let networkManager = NetworkManager.shared
    var grammarCheckSession: LanguageModelSession
    var rationaleGenerationSession: LanguageModelSession
    
    private init() {
        (self.grammarCheckSession, self.rationaleGenerationSession) = Self.refreshModelSessions()
    }
    
    private static func refreshModelSessions() -> (LanguageModelSession, LanguageModelSession) {
        let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        let gcSession = LanguageModelSession(model: model, instructions: grammarCheckSystemPrompt)
        let crSession = LanguageModelSession(model: model, instructions: correctionRationaleSystemPrompt)
        return (gcSession, crSession)
    }
    
    private static func refreshGrammarCheckModel() -> LanguageModelSession {
        let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        return LanguageModelSession(model: model, instructions: grammarCheckSystemPrompt)
    }
    
    private static func refreshRationaleGenerationModel() -> LanguageModelSession {
        let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        return LanguageModelSession(model: model, instructions: correctionRationaleSystemPrompt)
    }
    
    // MARK: - Syntactic Check
    
    /// Runs the initial grammar correction on the text.
    func runSyntacticCheck(on text: String) async throws -> String {
        // Wait for model session to be ready.
        while grammarCheckSession.isResponding {
            try await Task.sleep(for: .milliseconds(100))
        }
        
        do {
            let correctedText = try await correctSyntacticErrors(text: text)
            return correctedText
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("Warning: Exceeded context window size. Context: \(context).")
            print("Re-initializing grammar check session and retrying...")
            
            // Re-initialize the session
            (self.grammarCheckSession, self.rationaleGenerationSession) = Self.refreshModelSessions()
            
            // Retry the request once with the new session
            let correctedText = try await correctSyntacticErrors(text: text)
            return correctedText
            
        } catch {
            // Handle all other potential errors
            print("An unexpected error occurred during grammar check: \(error)")
            throw error // Re-throw the error so the caller can handle it
        }
    }
    
    private func correctSyntacticErrors(text: String) async throws -> String {
        while grammarCheckSession.isResponding {
            try await Task.sleep(for: .milliseconds(100))
        }
        
        // Debug: reset session every time
        self.grammarCheckSession = Self.refreshGrammarCheckModel()
        let prompt = checkAllCategories(forTask: text)
        let correctedGrammarText: String
        
        do {
            correctedGrammarText = try await grammarCheckSession.respond(
                to: prompt,
                generating: TextBlock.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content.correctedText
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("Warning: Exceeded context window size. Context: \(context).")
            print("Re-initializing grammar check session and retrying...")
            
            self.grammarCheckSession = Self.refreshGrammarCheckModel()
            
            correctedGrammarText = try await grammarCheckSession.respond(
                to: prompt,
                generating: TextBlock.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content.correctedText
            
        } catch {
            print("An unexpected error occurred during syntactic check: \(error)")
            throw error
            
        }
        
        print("Corrected Text: \n\(correctedGrammarText)")
        return correctedGrammarText
    }
    
    // MARK: - Rationale Generation
    
    /// Runs the initial grammar correction on the text.
    func generateEvaluation(for text: String, speechPrompt: String) async throws -> GrammarEvaluationDetail {
        let correctedText = try await correctSyntacticErrors(text: text)
        let errorFlags = try await networkManager.flagErrors(
            original: text,
            corrected: correctedText
        )
        var evalDetail = GrammarEvaluationDetail(promptText: speechPrompt, originalText: text, correctedText: correctedText, errors: errorFlags)
        evalDetail.errors = try await sequentiallyGenerateCorrectionRationales(for: evalDetail)
//        evalDetail.errors = try await generateCorrectionRationales(for: evalDetail)
        return evalDetail
    }
    
    private func generateOneCorrectionRationale(eval: GrammarEvaluationDetail, error: GrammarError) async throws -> CorrectionRationale {
        while rationaleGenerationSession.isResponding {
            try await Task.sleep(for: .milliseconds(100))
        }
        // Test: Reset session every time
        self.rationaleGenerationSession = Self.refreshRationaleGenerationModel()
        let correctionRationale: CorrectionRationale
        let prompt = sequentiallyCreateRationale(error: error, jsonString: eval.formatInputForError(error: error)!)
        
        do {
            correctionRationale = try await rationaleGenerationSession.respond(
                to: prompt,
                generating: CorrectionRationale.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("Warning: Exceeded context window size. Context: \(context).")
            print("Re-initializing rationale generation session and retrying...")
            
            self.rationaleGenerationSession = Self.refreshRationaleGenerationModel()
            
            correctionRationale = try await rationaleGenerationSession.respond(
                to: prompt,
                generating: CorrectionRationale.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content
            
        } catch {
            print("An unexpected error occurred during syntactic check: \(error)")
            throw error
        }
        
        print("[\(correctionRationale.errorID) / \(eval.totalErrorCount)]")
        return correctionRationale
    }
    
    private func sequentiallyGenerateCorrectionRationales(for eval: GrammarEvaluationDetail) async throws -> [SyntacticErrorType: [GrammarError]] {
        var correctionRationales: [CorrectionRationale] = []

        let allErrors = eval.errors.values.flatMap { $0 }
        let sortedErrors = allErrors.sorted { $0.originalStartChar < $1.originalStartChar }

        for error in sortedErrors {
            if eval.formatInputForError(error: error) != nil {
                let rationale = try await generateOneCorrectionRationale(
                    eval: eval,
                    error: error
                )
                correctionRationales.append(rationale)
                
            } else {
                print("Warning: Could not format error with ID \(error.id)")
            }
        }
        
        var rationaleMap = [String: String]()
        print("Rationales for Eval Item: \(eval.promptText)")
        for (index, error) in sortedErrors.enumerated() {
            rationaleMap[error.id] = correctionRationales[index].rationale
            print("""
            Error ID: \(correctionRationales[index].errorID)
            "\(correctionRationales[index].rationale)"
            
            """)
        }
        
        // Build the new dictionary
        var newErrors = eval.errors // Start with a copy of the old errors
        for (type, errorList) in newErrors {
            var newErrorList = [GrammarError]()
            for var error in errorList {
                if let newRationale = rationaleMap[error.id] {
                    error.correctionRationale = newRationale
                }
                newErrorList.append(error)
            }
            newErrors[type] = newErrorList
        }
        
        return newErrors
    }
    
    private func batchGenerateCorrectionRationales(for eval: GrammarEvaluationDetail) async throws -> [SyntacticErrorType: [GrammarError]] {
        while rationaleGenerationSession.isResponding {
            try await Task.sleep(for: .milliseconds(100))
        }
        
        numberOfErrors = eval.totalErrorCount
        
        let prompt = batchCreateRationale(forTask: eval)
        print("Input for Generation:\n \(eval)")
        
        let correctionRationales: [CorrectionRationale]
        
        do {
            correctionRationales = try await rationaleGenerationSession.respond(
                to: prompt,
                generating: CorrectionResponse.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content.errorRationales
            
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            print("Warning: Exceeded context window size. Context: \(context).")
            print("Re-initializing grammar check session and retrying...")
            
            self.rationaleGenerationSession = Self.refreshRationaleGenerationModel()
            
            correctionRationales = try await rationaleGenerationSession.respond(
                to: prompt,
                generating: CorrectionResponse.self,
                options: GenerationOptions(sampling: .greedy, temperature: 0.5)
            ).content.errorRationales
            
        } catch {
            print("An unexpected error occurred during syntactic check: \(error)")
            throw error
        }
        
        let sortedErrors = eval.errors.values.flatMap { $0 }.sorted { $0.originalStartChar < $1.originalStartChar }
        
        var rationaleMap = [String: String]()
        print("Rationales for Eval Item: \(eval.promptText)")
        for (index, error) in sortedErrors.enumerated() {
            rationaleMap[error.id] = correctionRationales[index].rationale
            print("""
            Error ID: \(correctionRationales[index].errorID)
            "\(correctionRationales[index].rationale)"
            
            """)
        }
        
        // Build the new dictionary
        var newErrors = eval.errors // Start with a copy of the old errors
        for (type, errorList) in newErrors {
            var newErrorList = [GrammarError]()
            for var error in errorList {
                if let newRationale = rationaleMap[error.id] {
                    error.correctionRationale = newRationale
                }
                newErrorList.append(error)
            }
            newErrors[type] = newErrorList
        }
        
        return newErrors
    }
    
}
