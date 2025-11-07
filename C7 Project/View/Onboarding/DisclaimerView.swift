//
//  DisclaimerView.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 31/10/25.
//

import SwiftUI
import Foundation

struct DisclaimerView: View {
    
    @Binding var currentAppState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                
                Image(systemName: "shield.checkmark.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.main.opacity(0.6))
                    .padding(.top, 32)
                
                Text("Welcome to ")
                    .font(.title3)
                + Text("TalkBoost")
                    .fontWeight(.bold)
                    .foregroundColor(.main.opacity(0.6))
                    .font(.title3)
                + Text(", the career simulator where your voice shapes your professional journey.")
                    .font(.title3)
                
                // Ganti ikon placeholder dengan yang lebih relevan
                DisclaimerBoxView(
                    text: "Step into realistic workplace scenarios designed to challenge and grow your communication skills",
                    image: "figure.wave"
                )
                DisclaimerBoxView(
                    text: "Control the narrative by simply speaking your response - from crucial project updates to high-stakes pitches",
                    image: "mic.fill"
                )
                DisclaimerBoxView(
                    text: "Our AI story engine listens, creating unique follow-up questions based on what you say",
                    image: "brain.head.profile"
                )
                DisclaimerBoxView(
                    text: "Your safe space to practice, build confidence, and prepare for the pivotal moments that will define your career",
                    image: "sparkles"
                )
                
                Button(action: {
                    withAnimation {
                        currentAppState = .mainApp
                    }
                }) {
                    Text("Let's Start your First Scenario")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .bold()
                }
                .padding()
                .background(Color.main)
                .foregroundColor(.white)
                .cornerRadius(50)
                
            }
            .padding(.horizontal)
        }
    }
}

struct DisclaimerBoxView: View{
    let text: String
    let image: String
    
    
    var body: some View{
        HStack{
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 320, minHeight: 100, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.15))
        )
    }
}


#Preview {
    DisclaimerView(currentAppState: .constant(.disclaimer))}
