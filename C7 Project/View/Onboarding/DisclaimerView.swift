//
//  DisclaimerView.swift
//  C7 Project
//
//  Created by Gerald Gavin Lienardi on 31/10/25.
//

import SwiftUI
import Foundation

struct DisclaimerView: View{
    
    var body: some View{
        ScrollView {
            VStack{
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
                Text("Welcome to ")
                    .font(.title3)
                + Text("TalkBoost")
                    .fontWeight(.bold) // or .semibold
                    .foregroundColor(.blue.opacity(0.6)) // highlight color
                    .font(.title3)
                + Text(", the career simulator where your voice shapes your professional journey.")
                    .font(.title3)
                
                DisclaimerBoxView(
                    text: "Step into realistic workplace scenarios designed to challenge and grow your communication skills",
                    image: "photo"
                )
                DisclaimerBoxView(
                    text: "Control the narrative by simply speaking your response - from crucial project updates to high-stakes pitches",
                    image: "photo"
                )
                DisclaimerBoxView(
                    text: "Our AI story engine listens, creating unique follow-up questions and consequences based on what you say and how you say it",
                    image: "photo"
                )
                DisclaimerBoxView(
                    text: "Your safe space to practice, build confidence, and prepare for the pivotal moments that will define your career",
                    image: "photo"
                )
                
                Button(action: {
                }) {
                    Text("Let's Start your First Scenario")
                        .frame(maxWidth: .infinity)
                        .font(.title3.bold())
                    
                    
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(50)
                .padding(.top, 48)
            }
            .padding()
        }
    }
    
}

struct DisclaimerBoxView: View{
    let text: String
    let image: String // I forgot how to images im a jippity coder
    
    
    var body: some View{
        HStack(
            spacing: 12,
        ){
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.15))
        )
    }
}

#Preview {
    DisclaimerView()
}
