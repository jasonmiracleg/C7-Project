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
                    isSent ? Color.blue : Color.gray.opacity(0.2)
                )
                .clipShape(.rect(topLeadingCorner: 16, topTrailingCorner: 16, bottomLeadingCorner: Edge.Corner.Style(integerLiteral: (isSent ? 16 : 0)), bottomTrailingCorner: Edge.Corner.Style(integerLiteral: (isSent ? 0 : 16))))
                .foregroundColor(isSent ? .white : .primary)
            if !isSent { Spacer() }
        }
    }
}
