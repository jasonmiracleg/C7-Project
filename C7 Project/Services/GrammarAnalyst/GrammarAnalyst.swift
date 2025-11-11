import Foundation
import FoundationModels

// Your enum for grouping errors
enum SyntacticErrorType: Hashable, Codable {
    case VerbTenses
    case SubjectVerbAgreement
    case ArticleOmission
    case PluralNounSuffix
    case CopulaOmission
    case WordOrder
    case WordFormation
    case IncorrectPreposition
    case NounPossesiveError
    case Unknown(String) // Catches any new or unexpected error types

    /// This initializer maps the JSON string keys (like "Verb Tenses")
    /// to your enum cases (like .VerbTenses).
    init(jsonKey: String) {
        switch jsonKey {
        case "Verb Tenses":
            self = .VerbTenses
        case "Subject-Verb Agreement":
            self = .SubjectVerbAgreement
        case "Article Omission":
            self = .ArticleOmission
        case "Plural Noun Suffix":
            self = .PluralNounSuffix
        case "Copula Omission":
            self = .CopulaOmission
        case "Word Order":
            self = .WordOrder
        case "Word Formation":
            self = .WordFormation
        case "Incorrect Preposition Choice":
            self = .IncorrectPreposition
        case "Noun Possessive Error":
            self = .NounPossesiveError
        default:
            self = .Unknown(jsonKey)
        }
    }
}

struct GrammarError: Codable, Hashable, Identifiable {
    // Create a stable ID based on the error's absolute position and type.
    var id: String { "\(originalStartChar)-\(originalEndChar)-\(type)" }
    
    let type: String
    let fullErrantType: String
    let originalText: String
    // REMOVED: originalStartToken, originalEndToken
    let originalStartChar: Int
    let originalEndChar: Int
    
    let correctedText: String
    // REMOVED: correctedStartToken, correctedEndToken
    let correctedStartChar: Int
    let correctedEndChar: Int
    
    var correctionRationale: String = "Standard English requires this correction to match accepted grammatical usage patterns."
    
    // Custom coding keys to include the new field optionally
    enum CodingKeys: String, CodingKey {
        case type, fullErrantType, originalText, correctedText
        case originalStartChar, originalEndChar, correctedStartChar, correctedEndChar
        case correctionRationale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        fullErrantType = try container.decode(String.self, forKey: .fullErrantType)
        originalText = try container.decode(String.self, forKey: .originalText)
        // REMOVED token decoding
        originalStartChar = try container.decode(Int.self, forKey: .originalStartChar)
        originalEndChar = try container.decode(Int.self, forKey: .originalEndChar)
        
        correctedText = try container.decode(String.self, forKey: .correctedText)
        // REMOVED token decoding
        correctedStartChar = try container.decode(Int.self, forKey: .correctedStartChar)
        correctedEndChar = try container.decode(Int.self, forKey: .correctedEndChar)
        
        correctionRationale = try container.decodeIfPresent(String.self, forKey: .correctionRationale) ?? "Standard English requires this correction to match accepted grammatical usage patterns."
    }
    
    // Updated memberwise init for previews and testing
    init(type: String, fullErrantType: String, originalText: String, originalStartChar: Int, originalEndChar: Int, correctedText: String, correctedStartChar: Int, correctedEndChar: Int, correctionRationale: String? = nil) {
        self.type = type
        self.fullErrantType = fullErrantType
        self.originalText = originalText
        self.originalStartChar = originalStartChar
        self.originalEndChar = originalEndChar
        self.correctedText = correctedText
        self.correctedStartChar = correctedStartChar
        self.correctedEndChar = correctedEndChar
        if let rationale = correctionRationale {
            self.correctionRationale = rationale
        }
    }
}

@Generable
// Generable guide for the syntactic grammar-check model
struct TextBlock {
    @Guide(description: "Populate this field with the **original**, unedited input text.")
    let originalText: String
    
    @Guide(description: "Populate this field with the **corrected** version of the input text.")
    var correctedText: String = ""
}

// MARK: - Grammar Analyst Actor
actor GrammarAnalyst {
    // This allows the session to be re-initialized if the context window is exceeded.
    var grammarCheckSession: LanguageModelSession
    
    init() {
        // Initialize the syntactic-checker model session
        self.grammarCheckSession = Self.createNewSession()
    }
    
    private static func createNewSession() -> LanguageModelSession {
        let model = SystemLanguageModel(useCase: .general, guardrails: .permissiveContentTransformations)
        return LanguageModelSession(model: model, instructions: grammarCheckSystemPrompt)
    }
    
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
            self.grammarCheckSession = Self.createNewSession()
            
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
        let prompt = checkAllCategories(forTask: text)
        let correctedGrammarText = try await grammarCheckSession.respond(
            to: prompt,
            generating: TextBlock.self,
            options: GenerationOptions(sampling: .greedy, temperature: 0.5)
        ).content.correctedText
        
        print("Corrected Text: \n\(correctedGrammarText)")
        return correctedGrammarText
    }
    
}
