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
    
    @Published var prompts: [String] = []
    @Published var answers: [String] = []
    var currentIndex = 0
    
    // for debugging purposes for the singular view
    @Published var dummyItems: [InterpretationItem] = [
        InterpretationItem(
            promptResponse: PromptResponse(
                promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
                answerText: "I'm a self-described, born entrepreneur, from an early age I've always been eager to run a business."
            )
        ),
        InterpretationItem(
            promptResponse: PromptResponse(
                promptText: "That's impressive! What kind of business did you start when you were younger?",
                answerText: "Uh, I start a small online shop selling, uh, custom phone case. It's not big, but I learning how to manage, like, money and customer talk properly."
            )

        ),
        InterpretationItem(
            promptResponse: PromptResponse(
                promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
                answerText: "I like the feeling when idea become, uh, real thing. Even when fail, I still feel excited to try again and make it more better next time.",
            ),
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
    
    
//    just gonna create the interpretor here, assuming a new view model is made everytime a session occurs.
    let interpretor = Interpretor()
    
    // initialize with the prompt text and spoken text
    init(items: [InterpretationItem] = []){
        self.items = items
    }
    
    // for testing purposes
    func loadDummyData() {
        items = dummyItems
    }
    
    // since they're doing it one by one
    func appendPrompt(_ prompt: String){
        prompts.append(prompt)
    }
    
    // supposedly its always question then answer first
    func appendAnswer(_ answer: String){
        answers.append(answer)
        
        
        // checks with a current index thingy
        if let prompt = prompts[safe: currentIndex],
           let answer = answers[safe: currentIndex] {
            appendEntry(promptResponse: PromptResponse(
                promptText: prompt,
                answerText: answer
                )
            )
            currentIndex += 1
        }
    }
    
    private func appendEntry(promptResponse: PromptResponse) {
        let newItem = InterpretationItem(promptResponse: promptResponse)
        items.append(newItem)
        
        let index = items.count - 1
        
        Task {
            await interpretText(at: index)
        }
    }
    

    private func interpretText(at index: Int) async {
        do {
            let response = items[index].getResponse()
            let result = try await interpretor.interpret(response)
            await MainActor.run {
                items[index].addInterpretation(result)
            }
        } catch {
            print("❌ Failed to interpret \(items[index].getResponse()): \(error)")
        }
    }

}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
