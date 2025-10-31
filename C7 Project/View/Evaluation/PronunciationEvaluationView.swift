//
//  PronunciationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI


struct PronunciationEvaluationView: View {
    
    @State private var showingPopup = false
    @State private var popupCorrection = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                EvaluationHeaderCard(
                    title: "Incorrect Pronunciation",
                    subtitle: "20/130 words"
                )
                
                EvaluationItemCard(
                    itemNumber: 1,
                    promptText: "Pitch your skills to the HR before the elevator reaches the ground floor!",
                    spokenText: evaluationText1(),
                    showingPopup: $showingPopup,
                    popupCorrection: $popupCorrection
                )
                
                EvaluationItemCard(
                    itemNumber: 2,
                    promptText: "That's impressive! What kind of business did you start when you were younger?",
                    spokenText: evaluationText2(),
                    showingPopup: $showingPopup,
                    popupCorrection: $popupCorrection
                )
                
                 EvaluationItemCard(
                     itemNumber: 3,
                     promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
                     spokenText: evaluationText3(),
                     showingPopup: $showingPopup,
                     popupCorrection: $popupCorrection
                 )

            }
            .padding(.horizontal)
        }
        .overlay(
            Group {
                if showingPopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingPopup = false
                        }
                    
                    PronunciationPopup(
                        correctionText: popupCorrection,
                        isPresented: $showingPopup
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showingPopup)
        )
    }

    private func evaluationText1() -> AttributedString {
        var text = AttributedString("I'm a self-described, born ")
        
        var entrepreneur = AttributedString("entrepreneur")
        entrepreneur.foregroundColor = .red
        entrepreneur.underlineStyle = .single
        entrepreneur.underlineColor = .red
        entrepreneur.link = URL(string: "popup://en-tre-pre-neur")
        
        var rest = AttributedString(", from an early age I've always been eager to run a business.")
        
        text.append(entrepreneur)
        text.append(rest)
        return text
    }
    
    private func evaluationText2() -> AttributedString {
        var part1 = AttributedString("Uh, I start a small online shop selling, uh, ")
        
        var custom = AttributedString("custom")
        custom.foregroundColor = .red
        custom.underlineStyle = .single
        custom.underlineColor = .red
        custom.link = URL(string: "popup://cus-tom")
        
        var part2 = AttributedString(" phone case. It's not big, but I learning how to manage, like, money and customer talk ")
        
        var properly = AttributedString("properly")
        properly.foregroundColor = .red
        properly.underlineStyle = .single
        properly.underlineColor = .red
        properly.link = URL(string: "popup://prop-er-ly")
        
        var part3 = AttributedString(".")
        
        part1.append(custom)
        part1.append(part2)
        part1.append(properly)
        part1.append(part3)
        return part1
    }
    
    private func evaluationText3() -> AttributedString {
        var part1 = AttributedString("I like the feeling when idea become, uh, real thing. Even when fail, I still feel ")
        
        var excited = AttributedString("excited")
        excited.foregroundColor = .red
        excited.underlineStyle = .single
        excited.underlineColor = .red
        excited.link = URL(string: "popup://ex-cit-ed")
        
        var part2 = AttributedString(" to try again and make it more better next time.")
        
        part1.append(excited)
        part1.append(part2)
        return part1
    }
}

#Preview {
    PronunciationEvaluationView()
}
