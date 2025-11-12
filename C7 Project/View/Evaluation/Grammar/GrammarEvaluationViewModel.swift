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
    
    init() {
        // Initialize with the 2 sample details, but empty corrected text and errors
        self.evaluationDetails = [
            GrammarEvaluationDetail(
                promptText: "Tell me about your weekend.",
                originalText: "I visit a cafe new last weekend with my friends. The place very nice and have many decoration beautiful. I see two cat sleeping near the window, and they so cute. The coffee good, but the cake a little too sweet for me. I think it is good place to relax with some friend on Saturday.",
                correctedText: "",
                errors: [:]
            ),
            GrammarEvaluationDetail(
                promptText: "How do you make fried rice?",
                originalText: "To make my special fried rice, first you must prepare the rice from yesterday. Then, you chop some onion and garlic until small. The recipe say you need to use a very hot pan. You stir-fry the onion until it smell fragrant. After that, you add the rice and mix it with careful. Don't forget to close the gas when you are finished cooking.",
                correctedText: "",
                errors: [:]
            )
        ]
    }
    
    func loadData() async {
        for i in evaluationDetails.indices {
            // Mark current item as loading
            evaluationDetails[i].isLoading = true
            
            do {
                let corrected = try await analyst.runSyntacticCheck(on: evaluationDetails[i].originalText)
                evaluationDetails[i].correctedText = corrected
                
                let errors = try await networkManager.flagErrors(
                    original: evaluationDetails[i].originalText,
                    corrected: corrected
                )
                evaluationDetails[i].errors = errors
                
            } catch {
                print("Error processing item \(i): \(error.localizedDescription)")
            }
            
            // Mark current item as finished
            evaluationDetails[i].isLoading = false
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
