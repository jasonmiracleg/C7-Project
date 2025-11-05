//
//  ErrorTaggingPlayground.swift
//  C7 Project
//
//  Created by Savio Enoson on 03/11/25.
//

import SwiftUI
import Foundation
import FoundationModels
import NaturalLanguage
import Playgrounds


#Playground {
    // 1. Initialize the analyst
    let analyst = GrammarAnalyst()
    
    let paragraph = """
    I'm not sure if we should go camping, even though the tent is new. I just checked the weather online and it doesn't look good. The weather forecast predicts hard rain for tomorrow afternoon. I really don't want all our gear to get soaked, especially since I just saw two cats sleeping happily near the window.
    """
    
    // 2. Run the full analysis
    let (correctedText, validatedFlags) = try await analyst.runFullAnalysis(text: paragraph)
    
    let pgText = correctedText
    let pgFlag = validatedFlags
}
