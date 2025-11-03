//
//  MessageBubble.swift
//  C7 Project
//
//  Created by Jason Miracle Gunawan on 30/10/25.
//

import SwiftUI

struct MessageBubble: View {
    let text: String
    let isSent: Bool
    
    var body: some View {
        HStack {
            if isSent { Spacer() }
            Text(text)
                .frame(width: 250)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSent ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSent ? .white : .primary)
            if !isSent { Spacer() }
        }
    }
}
