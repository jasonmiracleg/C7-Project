//
//  SyntacticErrorType.swift
//  C7 Project
//
//  Created by Savio Enoson on 11/11/25.
//

import Foundation
import SwiftUI

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
    
    var color: Color {
        switch self {
        // Using slightly darker/richer shades for better contrast on both light/dark modes
        case .VerbTenses: return Color(red: 0.8, green: 0.1, blue: 0.1)         // Darker Red
        case .SubjectVerbAgreement: return Color(red: 0.85, green: 0.45, blue: 0.0) // Darker Orange
        case .ArticleOmission: return Color(red: 0.0, green: 0.4, blue: 0.8)      // Darker Blue
        case .PluralNounSuffix: return Color(red: 0.6, green: 0.1, blue: 0.6)     // Darker Purple
        case .CopulaOmission: return Color(red: 0.85, green: 0.1, blue: 0.5)      // Darker Pink
        case .WordOrder: return Color(red: 0.8, green: 0.65, blue: 0.0)           // Gold (Darker Yellow)
        case .WordFormation: return Color(red: 0.0, green: 0.6, blue: 0.2)        // Darker Green
        case .IncorrectPreposition: return Color(red: 0.0, green: 0.6, blue: 0.7) // Teal (Darker Cyan)
        case .NounPossesiveError: return Color(red: 0.6, green: 0.4, blue: 0.2)   // Brown
        case .Unknown: return Color.gray
        }
    }
    
    var title: String {
        switch self {
        case .VerbTenses: return "Verb Tense"
        case .SubjectVerbAgreement: return "Subject-Verb Agreement"
        case .ArticleOmission: return "Article Omission"
        case .PluralNounSuffix: return "Plural Noun Suffix"
        case .CopulaOmission: return "Copula Omission"
        case .WordOrder: return "Word Order"
        case .WordFormation: return "Word Formation"
        case .IncorrectPreposition: return "Incorrect Preposition"
        case .NounPossesiveError: return "Noun Possessive Error"
        case .Unknown: return "Other Error Type"
        }
    }
    
    var shortDescription: String {
        switch self {
            case .VerbTenses: return "Forgetting to change the verb's form to show a past, present, or future time."
            case .SubjectVerbAgreement: return "Forgetting to add '-s' or '-es' to a present tense verb for a singular subject (he, she, it)."
            case .ArticleOmission: return "Missing the words 'a', 'an', or 'the' before nouns where they are required."
            case .PluralNounSuffix: return "Forgetting to add '-s' or '-es' to a noun to indicate plurality."
            case .CopulaOmission: return "Missing the linking verb ('is', 'am', 'are') in sentences that describe a state, quality, or location."
            case .WordOrder: return "Placing the decriptors in an incorrect order."
            case .WordFormation: return "Using the correct root word but in the wrong form, such as using a noun instead of an adjective."
            case .IncorrectPreposition: return "Choosing the wrong preposition (e.g., 'at', 'in', 'on') for the context."
            case .NounPossesiveError: return "Forgetting to use the apostrophe + 's' ('s) to show ownership."
            case .Unknown: return "Some other error we don't currently have a category for."
        }
    }
}
