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
    let interpretationPoints: [String]
    
    @State private var isExpanded: Bool = false
    
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
                
//                if interpretationPoints.count > 0 {
//                    Text("\(interpretationPoints.count)")
//                        .font(.caption.weight(.semibold))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .background(
//                            Capsule().fill(Color.accentColor)
//                        )
//                        .accessibilityLabel("\(interpretationPoints.count) points")
//                }
                
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
                withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                    isExpanded.toggle()
                }
            }
            
            // Expanded points
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(interpretationPoints, id: \.self) { point in
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
                .transition(.opacity.combined(with: .move(edge: .top)))
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
