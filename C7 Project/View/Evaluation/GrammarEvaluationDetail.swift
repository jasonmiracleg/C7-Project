// GrammarEvaluationDetail.swift
import Foundation

struct GrammarEvaluationDetail: Codable, Equatable, Identifiable {
    var id = UUID()
    let spokenSentence: String
    let correctedSentence: String
    let evaluationDetail: String
}
