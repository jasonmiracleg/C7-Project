//
//  ContextScenarioView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 30/10/25.
//

import SwiftUI

struct ContextScenarioView: View {
    @State private var showGameplaySheet = false
    
    var text: String =
        "The CEO of your company is doing an impromptu company visit. Apparently they are laying off some of the workforce for efficiency. He is asking everyone to tell him about what they worked on in the past week."

    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                )
                .overlay(alignment: .bottom) {
                    Triangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width:30, height: 20)
                        .offset(x: -40, y: 20)
                }
            Image("Context")
                .resizable()
                .frame(width: 350, height: 350)
                .padding(.top, -24)
            Spacer()
            Button(action: {
                showGameplaySheet = true
            }) {
                Text("START YOUR CONVERSATION")
                    .font(.headline)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color.accentColor.opacity(0.8))
            )
            .foregroundStyle(Color.white)
            .fullScreenCover(isPresented: $showGameplaySheet) {
                GameplaySheetView()
                    .padding(.horizontal, 24)
            }
        }
        .padding(.horizontal, 24)

    }
}

#Preview {
    ContextScenarioView()
}
