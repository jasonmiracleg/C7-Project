//
//  InterpretationEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct InterpretationEvaluationView: View {
    
    // MARK: - Local Model
    private struct InterpretationItem: Identifiable {
        let id = UUID()
        let promptText: String
        let spokenText: String
        let interpretationPoints: [String]
    }
    
    // MARK: - Sample Data
    private var items: [InterpretationItem] = [
        InterpretationItem(
            promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
            spokenText: "I'm a self-described, born entrepreneur, from an early age I've always been eager to run a business.",
            interpretationPoints: [
                "You consider yourself an entrepreneur.",
                "You've wanted to run a business since your childhood."
            ]
        ),
        InterpretationItem(
            promptText: "That's impressive! What kind of business did you start when you were younger?",
            spokenText: "Uh, I start a small online shop selling, uh, custom phone case. It's not big, but I learning how to manage, like, money and customer talk properly.",
            interpretationPoints: [
                "You started an online shop.",
                "It sold custom phone cases.",
                "You learned about management and customer service."
            ]
        ),
        InterpretationItem(
            promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
            spokenText: "I like the feeling when idea become, uh, real thing. Even when fail, I still feel excited to try again and make it more better next time.",
            interpretationPoints: [
                "You are motivated by turning ideas into reality.",
                "You are resilient and see failure as a learning opportunity."
            ]
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(items) { item in
                    InterpretationItemCard(
                        promptText: item.promptText,
                        spokenText: item.spokenText,
                        interpretationPoints: item.interpretationPoints
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    InterpretationEvaluationView()
}
