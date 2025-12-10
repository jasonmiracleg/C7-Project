//
//  InterpretationItemCard.swift
//  C7 Project
//
//  Created by Abelito Faleyrio Visese on 03/11/25.
//
import SwiftUI

struct InterpretationItemCard: View {
    
    let promptText: String
    let spokenText: String
    let interpretedText: InterpretedText?
    
    @State private var isExpanded: Bool = false
    @State private var isInterpreted: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Prompt
            HStack(alignment: .top, spacing: 8) {
                Text(promptText)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            // Spoken Text
            HStack(alignment: .top, spacing: 8) {
                Text(spokenText)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(10)
            }
            
            // Interpretation header
            HStack(spacing: 8) {
                Text("Interpretation")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemBackground))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                    isExpanded.toggle()
                }
            }
            
            // Expanded points
            if isExpanded {
                if let interpretedText = interpretedText {
                    // ✅ Show interpreted points
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(interpretedText.points, id: \.self) { point in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 6)
                                Text(point)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 4)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    // 🌀 Show loading placeholder when interpretedText is nil
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Interpreting...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .transition(.opacity)
                }
            }


        }
        .padding(14)
        .background(Color(UIColor.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(UIColor.separator), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .contain)
    }
}
