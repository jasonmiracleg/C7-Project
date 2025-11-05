//
//  InterpretationEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct InterpretationEvaluationView: View {
    
    // MARK: - Sample Data
    private var items: [InterpretationItem] = [
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
            spokenText: "I like the feeling when idea become, uh, real thing. Even when fail, I still feel excited to try again and make it more better next time."
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(items) { item in
                    InterpretationItemCard(
                        promptText: item.promptText,
                        spokenText: item.spokenText,
                        interpretedText: item.interpretedText
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
    
//    i expect it initially has InterpretedText as nil
    private func generateInterpretedPoints(items: [InterpretationItem]) async -> [InterpretationItem] {
        let interpretor = Interpretor()
        var tempItems = items
        
        for i in tempItems.indices {
            if tempItems[i].interpretedText == nil {
                do {
                    let result = try await interpretor.interpret(tempItems[i].spokenText)
                    tempItems[i].interpretedText = result
                } catch {
                    print("❌ Failed to interpret \(tempItems[i].spokenText): \(error)")
                    tempItems[i].interpretedText = nil
                }
            }
        }
        
        return tempItems
    }

}

#Preview {
    InterpretationEvaluationView()
}
