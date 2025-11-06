//
//  ChatMessage.swift
//  C7 Project
//
//  Created by Maria Angelica Vinesytha Chandrawan on 05/11/25.
//

import Foundation

struct ChatMessage: Identifiable{
    let id = UUID()
    let text: String
    let isSent: Bool
}
