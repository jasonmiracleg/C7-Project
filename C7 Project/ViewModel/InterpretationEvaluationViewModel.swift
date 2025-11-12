//
//  InterpretationEvaluationViewModel.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 05/11/25.
//

import Foundation
import Combine

@MainActor
class InterpretationEvaluationViewModel: ObservableObject {
    @Published var isLoading = false
    
    @Published var items: [InterpretationItem]
    
    @Published var dummyItems: [InterpretationItem] = [
        InterpretationItem(
            promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
            spokenText: "I'm a self-described, born entrepreneur, from an early age I've always been eager to run a business."
        ),
        InterpretationItem(
            promptText: "That's impressive! What kind of business did you start when you were younger?",
            spokenText: "Uh, I start a small online shop selling, uh, custom phone case. It's not big, but I learning how to manage, like, money and customer talk properly."
        ),
        InterpretationItem(
            promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
            spokenText: "I like the feeling when idea become, uh, real thing. Even when fail, I still feel excited to try again and make it more better next time.",
            interpretedText: InterpretedText(
                original: "original text",
                summary: "summary of text",
                points: [
                    "This is point 1",
                    "This is point 2",
                    "Im just testing view"
                ]
            )
        )
    ]
    
    @Published var currentTaskDescription: String? = nil // this is for debugging purposes, shows what the viewModel is doing rn
    @Published var debugging = false
    
    // initialize with the prompt text and spoken text
    init(items: [InterpretationItem] = []){
        self.items = items
    }
    
    // for testing purposes
    func loadDummyData() {
        items = dummyItems
    }
    
    // function to call in views to generate points
    func loadInterpretations() async {
        guard !items.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        currentTaskDescription = "Model is interpretating..."
        
        await generateInterpretedPoints()
        
        if debugging {
            currentTaskDescription = "items have been updated"
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        currentTaskDescription = nil
    }
    
    //    i expect it initially has InterpretedText as nil so this generates the points from spokenText
    //  live updates
    private func generateInterpretedPoints() async {
        let interpretor = Interpretor.shared
            
        // need to use indices instead of iterating through items
        // because it needs to access array, otherwise itll only provide a copy
        for i in items.indices {
            if items[i].interpretedText == nil {
                currentTaskDescription = "Interpreting text \(i + 1): \(items[i].spokenText)"
                do {
                    let result = try await interpretor.interpret(items[i].spokenText)
                    items[i].addInterpretation(result)
                } catch {
                    print("❌ Failed to interpret \(items[i].spokenText): \(error)")
                }
            }
        }
        
    }
    
    func viewDebug() {
        debugging = true
    }
}
