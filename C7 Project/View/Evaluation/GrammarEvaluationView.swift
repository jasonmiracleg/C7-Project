//
//  GrammarEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct GrammarEvaluationView: View {
    @Binding var showingPopup: Bool
    @Binding var correctionText: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                EvaluationHeaderCard(
                    title: "Incorrect Grammar",
                    subtitle: "20/130 sentences"
                )
                
                EvaluationItemCard(
                    promptText: "That's impressive! What kind of business did you start when you were younger?",
                    spokenText: grammarText2(),
                    showingGrammarPopup: $showingPopup,
                    grammarCorrection: $correctionText
                )
                
                EvaluationItemCard(
                    promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
                    spokenText: grammarText3(),
                    showingGrammarPopup: $showingPopup,
                    grammarCorrection: $correctionText
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - URL Builders
    private func grammarLink(for text: String) -> URL? {
        var components = URLComponents()
        components.scheme = "grammar"
        components.host = "show"
        components.queryItems = [
            URLQueryItem(name: "text", value: text)
        ]
        return components.url
    }
    
    private func grammarText2() -> AttributedString {
        var part1 = AttributedString("Uh, I start a small online shop selling, uh, custom phone case. It's not big, ")
        
        var grammarError = AttributedString("but I learning how to manage")
        grammarError.foregroundColor = .orange
        grammarError.underlineStyle = .single
        grammarError.underlineColor = .orange
        grammarError.link = grammarLink(for: "but I'm learning how to manage money.")
        
        var part2 = AttributedString(", like, money and customer talk properly.")
        
        part1.append(grammarError)
        part1.append(part2)
        return part1
    }
    
    private func grammarText3() -> AttributedString {
        var part1 = AttributedString("I like the feeling when idea ")
        
        var error1 = AttributedString("become")
        error1.foregroundColor = .orange
        error1.underlineStyle = .single
        error1.underlineColor = .orange
        error1.link = grammarLink(for: "becomes")
        
        var part2 = AttributedString(", uh, real ")
        
        var error2 = AttributedString("thing")
        error2.foregroundColor = .orange
        error2.underlineStyle = .single
        error2.underlineColor = .orange
        error2.link = grammarLink(for: "things")
        
        var part3 = AttributedString(". Even when fail, I still feel excited to try again and make it ")
        
        var error3 = AttributedString("more better")
        error3.foregroundColor = .orange
        error3.underlineStyle = .single
        error3.underlineColor = .orange
        error3.link = grammarLink(for: "better")
        
        var part4 = AttributedString(" next time.")

        part1.append(error1)
        part1.append(part2)
        part1.append(error2)
        part1.append(part3)
        part1.append(error3)
        part1.append(part4)
        return part1
    }
}
