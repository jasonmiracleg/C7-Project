//
//  GrammarEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

private func evaluationText1() -> Text {
    Text("I'm a self-described, born entrepreneur from an early age I've always been eager to run a business.")
}

private func evaluationText2() -> Text {
    Text("Uh, I start a small online shop selling, uh, custom phone case. It's not big, ") + Text("but I learning how to manage").foregroundColor(.orange).underline(color: .orange) + Text(", like, money and customer talk properly.")
}

private func evaluationText3() -> Text {
    Text("I like the ") + Text("feeling when idea become, uh, real thing.").foregroundColor(.orange).underline(color: .orange) + Text(" Even when fail, I still feel excited to try again and make it ") + Text("more better").foregroundColor(.orange).underline(color: .orange) + Text(" next time.")
}

struct GrammarEvaluationView: View {
    var body: some View {
        ScrollView{
//            VStack{
//                EvaluationHeaderCard(
//                    title: "Incorrect Grammar",
//                    subtitle: "40/130 sentences"
//                )
//                .padding()
//                
//                EvaluationItemCard(
//                    itemNumber: 1,
//                    promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
//                    spokenText: evaluationText1()
//                )
//                
//                EvaluationItemCard(
//                    itemNumber: 2,
//                    promptText: "That's impressive! What kind of business did you start when you were younger?",
//                    spokenText: evaluationText2()
//                )
//                
//                EvaluationItemCard(
//                    itemNumber: 3,
//                    promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
//                    spokenText: evaluationText3()
//                )
//            }
        }
    }
}

#Preview {
    GrammarEvaluationView()
}
