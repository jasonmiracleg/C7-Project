//
//  GrammarEvaluationView.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct GrammarEvaluationView: View {
    @Binding var showingPopup: Bool
    @Binding var selectedGrammarDetail: GrammarEvaluationDetail?
    
    let grammarDetails: [String: GrammarEvaluationDetail] = [
        "key1": GrammarEvaluationDetail(
            spokenSentence: "but I learning how to manage",
            correctedSentence: "but I'm learning how to manage",
            evaluationDetail: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eu turpis molestie, dictum est a, mattis tellus. Sed dignissim, metus nec fringilla accumsan, risus sem sollicitudin lacus, ut interdum tellus elit sed risus."
        ),
        "key2": GrammarEvaluationDetail(spokenSentence: "become", correctedSentence: "becomes", evaluationDetail: "Explanation for 'becomes'."),
        "key3": GrammarEvaluationDetail(spokenSentence: "thing", correctedSentence: "things", evaluationDetail: "Explanation for 'things'."),
        "key4": GrammarEvaluationDetail(spokenSentence: "more better", correctedSentence: "better", evaluationDetail: "Explanation for 'better'.")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                EvaluationHeaderCard(
                    title: "Incorrect Grammar",
                    subtitle: "20/130 sentences",
                    color: Color.orange
                )
                
                EvaluationItemCard(
                    promptText: "That's impressive! What kind of business did you start when you were younger?",
                    spokenText: grammarText2(),
                    showingGrammarPopup: $showingPopup,
                    selectedGrammarDetail: $selectedGrammarDetail,
                    grammarDetails: grammarDetails
                )
                
                EvaluationItemCard(
                    promptText: "Sounds like you've got a real passion for entrepreneurship. What motivates you to keep building businesses?",
                    spokenText: grammarText3(),
                    showingGrammarPopup: $showingPopup,
                    selectedGrammarDetail: $selectedGrammarDetail,
                    grammarDetails: grammarDetails
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - URL Builders
    private func grammarLink(for detail: GrammarEvaluationDetail) -> URL? {
        do {
            let data = try JSONEncoder().encode(detail)
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            var components = URLComponents()
            components.scheme = "grammar"
            components.host = "show"
            components.queryItems = [
                URLQueryItem(name: "payload", value: jsonString)
            ]
            return components.url
        } catch {
            return nil
        }
    }
    
    private func grammarText2() -> AttributedString {
        var part1 = AttributedString("Uh, I start a small online shop selling, uh, custom phone case. It's not big, ")
        
        var grammarError = AttributedString("but I learning how to manage")
        grammarError.foregroundColor = .orange
        grammarError.underlineStyle = .single
        grammarError.underlineColor = .orange
        grammarError.link = URL(string: "grammar://key1")
        
        var part2 = AttributedString(", like, money and customer talk properly.")
        
        part1.append(grammarError)
        part1.append(part2)
        return part1
    }
    
    private func grammarText3() -> AttributedString {
        var part1 = AttributedString("I like the feeling when idea ")
        var error1 = AttributedString("become"); error1.foregroundColor = .orange; error1.underlineStyle = .single; error1.underlineColor = .orange
        error1.link = URL(string: "grammar://key2")
        
        var part2 = AttributedString(", uh, real ")
        var error2 = AttributedString("thing"); error2.foregroundColor = .orange; error2.underlineStyle = .single; error2.underlineColor = .orange
        error2.link = URL(string: "grammar://key3")
        
        var part3 = AttributedString(". Even when fail, I still feel excited to try again and make it ")
        var error4 = AttributedString("more better"); error4.foregroundColor = .orange; error4.underlineStyle = .single; error4.underlineColor = .orange
        error4.link = URL(string: "grammar://key4")
        
        var part4 = AttributedString(" next time.")

        part1.append(error1); part1.append(part2); part1.append(error2);
        part1.append(part3); part1.append(error4); part1.append(part4)
        return part1
    }
}

#Preview {
    GrammarEvaluationPreview()
}

private struct GrammarEvaluationPreview: View {
    @State private var showingPopup = false
    @State private var selectedGrammarDetail: GrammarEvaluationDetail? = nil
    
    var body: some View {
        NavigationStack {
            GrammarEvaluationView(
                showingPopup: $showingPopup,
                selectedGrammarDetail: $selectedGrammarDetail
            )
            .navigationTitle("Grammar Evaluation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
