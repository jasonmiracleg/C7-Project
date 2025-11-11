//
//  GrammarEvaluationViewModel.swift
//  C7 Project
//
//  Created by [Your Name] on 10/11/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class GrammarEvaluationViewModel {
    var evaluationDetails: [GrammarEvaluationDetail] = []
    
    var selectedDetail: GrammarEvaluationDetail?
    var selectedSentenceIndex: Int?
    var isShowingDetailPopup: Bool = false
    
    // Dependencies
    private let analyst = GrammarAnalyst()
    private let networkManager = NetworkManager.shared
    
    var totalSentences: Int {
        var total = 0
        for detail in evaluationDetails {
            let text = detail.originalText
            text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { _, _, _, _ in
                total += 1
            }
        }
        return total
    }
    
    var totalErrors: Int {
        evaluationDetails.reduce(0) { total, detail in
            total + detail.errors.values.reduce(0) { $0 + $1.count }
        }
    }
    
    var incorrectSentences: Int {
        var total = 0
        for detail in evaluationDetails {
            let text = detail.originalText
            text.enumerateSubstrings(in: text.startIndex..<text.endIndex, options: .bySentences) { _, range, _, _ in
                if !detail.errors(in: range).isEmpty {
                    total += 1
                }
            }
        }
        return total
    }
    
    func loadData() async {
        do {
            let sample1 = try await analyst.generateEvaluation(for: "I visit a cafe new last weekend with my friends. The place very nice and have many decoration beautiful. I see two cat sleeping near the window, and they so cute. The coffee good, but the cake a little too sweet for me. I think it is good place to relax with some friend on Saturday.", speechPrompt: "Tell me about your weekend.")
            
            let sample2 = try await analyst.generateEvaluation(for: "I read interesting article today about modern technology. It say that many young person now prefer to communicate using their phone instead of talking. They feel it is more easy than meeting face to face. The article also mention that this can make problem for their social skill in the future. For example, they might find it difficult to do a conversation with new people. I think this is true because I see this happen with my own two eye. We must be more awareness about this important issue.", speechPrompt: "What was the last thing you read?")

            self.evaluationDetails = [sample1, sample2]
        } catch {
            print("Failed to load grammar evaluations: \(error)")
            self.evaluationDetails = []
        }
    }
    
    func type(for error: GrammarError) -> SyntacticErrorType {
        for detail in evaluationDetails {
            for (type, errors) in detail.errors {
                if errors.contains(error) {
                    return type
                }
            }
        }
        return .Unknown("Unknown")
    }
}
