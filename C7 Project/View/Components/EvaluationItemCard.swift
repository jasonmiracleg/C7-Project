//
//  EvaluationItemCard.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 30/10/25.
//

import SwiftUI

struct EvaluationItemCard: View {
    let itemNumber: Int
    let promptText: String
    let spokenText: AttributedString
    @Binding var showingPopup: Bool
    @Binding var popupCorrection: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Numbered Circle
            Text("\(itemNumber)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.red))
                .padding(.top, 2)
            
            // Text Content
            VStack(alignment: .leading, spacing: 8) {
                Text(promptText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Divider()
                
                Text(spokenText)
                    .font(.body)
                    .foregroundColor(Color(UIColor.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .environment(\.openURL, OpenURLAction { url in
                        if url.scheme == "popup" {
                            let correction = String(url.host ?? "error")
                            popupCorrection = correction
                            showingPopup = true
                            return .handled
                        }
                        return .discarded
                    })
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }
}


