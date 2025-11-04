// GrammarEvaluationDetail.swift
import Foundation

struct GrammarEvaluationDetail: Codable, Equatable {
    let spokenSentence: String
    let correctedSentence: String
    let evaluationDetail: String
}
