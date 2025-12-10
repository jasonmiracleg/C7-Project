//
//  InterpretationEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct InterpretationEvaluationView: View {
    
    @ObservedObject var viewModel: InterpretationEvaluationViewModel
    
//    init(items: [InterpretationItem] = []) {
//        _viewModel = StateObject(wrappedValue: InterpretationEvaluationViewModel(items: items))
//    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: 16, pinnedViews: []) {
                ForEach(viewModel.items) { item in
                    InterpretationItemCard(
                        promptText: item.getPrompt(),
                        spokenText: item.getResponse(),
                        interpretedText: item.interpretedText
                    )
                    
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
//        .task {
//            // remove this if you dont wanna use dummy data
////            viewModel.viewDebug()
//            if viewModel.items.isEmpty {
//                viewModel.loadDummyData()
//            }
//            
//            await viewModel.loadInterpretations()
//        }
    }

}

//#Preview {
//    let dummyItems: [InterpretationItem] = [
//        InterpretationItem(
//            promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
//            spokenText: "I'm a self-described, born entrepreneur, from an early age I've always been eager to run a business."
//        ),
//        InterpretationItem(
//            promptText: "That's impressive! What kind of business did you start when you were younger?",
//            spokenText: "Uh, I start a small online shop selling, uh, custom phone case. It's not big, but I learning how to manage, like, money and customer talk properly."
//        ),
//        InterpretationItem(
//            promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
//            spokenText: "I like the feeling when idea become, uh, real thing. Even when fail, I still feel excited to try again and make it more better next time."
//        )
//    ]
//    InterpretationEvaluationView(items: dummyItems)
//}
