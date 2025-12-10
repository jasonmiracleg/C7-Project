//
//  FollowUpQuestionTestView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 06/11/25.
//

import SwiftUI
import FoundationModels

struct FollowUpQuestionTestView: View {
    @State private var scenario: String = ""
    @State private var previousQuestion: String = ""
    @State private var userAnswer: String = ""
    @State private var input:String = ""
    
    @State private var generatedQuestion: String = ""
    @State private var isLoading: Bool = false
    
    // Your actor instance
    private let followUpGenerator = FollowUpQuestion()
    
    var body: some View {
        ScrollView { // <— make entire form scrollable
            VStack(alignment: .leading, spacing: 16) {
                
                Group {
                    Text("Scenario")
                        .font(.headline)
                    
                    TextEditor(text: $scenario)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                Group {
                    Text("Previous Question")
                        .font(.headline)
                    
                    TextEditor(text: $previousQuestion)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                Group {
                    Text("User Answer")
                        .font(.headline)
                    
                    TextEditor(text: $userAnswer)
                        .frame(minHeight: 80)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                Button(action: generate) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Generate Follow-Up Question")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
                
                if !generatedQuestion.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Generated Follow-Up Question:")
                            .font(.headline)
                        
                        Text(generatedQuestion)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            .fixedSize(horizontal: false, vertical: true) // <— prevents truncation
                    }
                    .padding(.top, 20)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    // MARK: - Generate Logic
    private func generate() {
        Task {
            guard !scenario.isEmpty, !previousQuestion.isEmpty, !userAnswer.isEmpty else { return }
            isLoading = true
            do {
                let result = try await followUpGenerator.generateFollowUpQuestion(
                    scenario: scenario,
                    question: previousQuestion,
                    userAnswer: userAnswer
                )
                
                // Result contains struct: FollowUpQuestionText(scenario, question, userAnswer)
                // The generated question is in `result.userAnswer`
                generatedQuestion = result.description
            } catch {
                generatedQuestion = "⚠️ Failed to generate question."
            }
            isLoading = false
        }
    }
}

#Preview {
    FollowUpQuestionTestView()
}
