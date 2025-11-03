//
//  GameplaySheetView.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 30/10/25.
//

import SwiftUI

struct GameplaySheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isRecording = false
    @State private var isFinished = false

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: VerticalAlignment.center) {
                    HStack(alignment: VerticalAlignment.center) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(Color(.black.opacity(0.8)))
                            .font(Font.system(size: 18))
                        Text("02:40")
                            .font(.subheadline)
                    }
                    Spacer()
                    Text("Gameplay")
                        .font(.title2)
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color(.black))
                            .font(Font.system(size: 24))
                    }
                    .buttonStyle(.glass)
                }
                Text("Big Shot")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    MessageBubble(
                        text:
                            "So, can you tell me about what you worked on this past week",
                        isSent: false
                    )
                    MessageBubble(
                        text:
                            "I’ve been working on improving the team workflow. We, uh, implement new tools to improve productivity and optimise the team, like, uh, task management system.",
                        isSent: true
                    )
                    MessageBubble(
                        text:
                            "That’s great! What kind of tools did you implement to improve the workflow?",
                        isSent: false
                    )
                    MessageBubble(
                        text:
                            "We, um, used a new software to track the tasks better. It’s really help the team stay organized, and we can easily meet the deadlines now.",
                        isSent: true
                    )
                    MessageBubble(
                        text:
                            "Sounds impressive! How do you think this will help with the company’s efficiency, especially with some people being laid off?",
                        isSent: false
                    )
                }
            }
            .frame(height: 500)
            Spacer()
            
            if isFinished {
                Text("Good Job!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Now, Let's review how you did")
                    .padding(.bottom, 12)
                Button(action: {
                   
                }) {
                    Text("View Evaluation")
                        .font(.headline)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.8))
                )
                .foregroundStyle(Color.white)
                Spacer()
            } else {
                if !isRecording {
                    HStack {
                        Button(action: {
                            
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color(.black))
                                .font(Font.system(size: 24))
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                )
                        }
                        ZStack(alignment: .trailing) {
                            TextField("", text: .constant(""))
                                .padding(12)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.2))
                                )
                            Button(action: {
                                
                            }) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundStyle(Color.white)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.interactive)
                                    )
                                    .padding(.trailing, 4)
                            }
                        }
                    }
                    Spacer()
                } else {
                    Image("Sound Wave")
                    Spacer()
                }
                Button(action: {
                    isRecording.toggle()
                }) {
                    Image(
                        systemName: !isRecording ? "microphone.fill" : "square.fill"
                    )
                    .foregroundStyle(Color(.white))
                    .font(Font.system(size: 32))
                    .padding(18)
                    .background(
                        Circle()
                            .fill(Color.interactive)
                    )
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    GameplaySheetView()
}
