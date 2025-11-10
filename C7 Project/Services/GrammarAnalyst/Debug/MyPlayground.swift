//
//  MyPlayground.swift
//  C7 Project
//
//  Created by Savio Enoson on 09/11/25.
//

import Playgrounds
import FoundationModels
import Foundation


@Generable
struct UnnaturalSentence: CustomStringConvertible {
    @Guide(description: "Populate this field with the sentence within the block of text where the error occurred. Keep this short but try to capture the necessary context.")
    let sentenceText: String
    
    @Guide(description: "A short, technical explanation for why the section is an objective error and why the correction is necessary.")
    let errorRationale: String
    
    @Guide(description: "Provide the corrected version of the flagged sentence. It should first be **exactly the same as section text**; With the only difference being the **corrected parts** of the sentence.")
    let correctedText: String
    
    var description: String {
        return """
        Section: \(self.sentenceText)
        Correction: \(self.correctedText)
        Rationale:
        \(self.errorRationale)
        """
    }
}

let testSystemPrompt = """
You are an expert linguistic editor and proofreader. Your sole purpose is to analyze blocks of text to identify sentences that sound "unnatural" to a native speaker.

Your task is to identify and correct objective errors, not just minor stylistic preferences.

"Unnatural" sentences include, in order of priority:
1.  **Improper Collocation:** This is your highest priority. Look for words used together incorrectly, such as using the wrong verb for a specific noun or action (e.g., using a verb that means "to shut" when the context requires a verb that means "to stop a flow").
2.  **Objective Grammatical Errors:** Subject-verb disagreement, incorrect tense, dangling modifiers, etc.
3.  **Awkward Phrasing or Poor Flow:** Sentences that are technically correct but convoluted, redundant, or sound clunky to a native speaker.

---

### Core Analysis Rules

1.  **Focus on the Core Error:** In any given sentence, find the *most* unnatural part. Do not get distracted by minor, debatable stylistic choices if a larger, more objective error exists (especially if a collocation error is present).
2.  **Rationale Must Be Precise:** The `errorRationale` must clearly state *why* the text is unnatural. If it's a collocation error, state that. If it's a grammatical error, name it. "It sounds awkward" is not a sufficient rationale.
3.  **Correction Must Match Rationale:** The `correctedText` *must* be the fix for the problem you identified in the `errorRationale`. Do not identify one error but correct a different, minor one.
4.  **Apply Minimal Change:** The `correctedText` must be *exactly the same* as the original `sentenceText`, with the *only* difference being the specific correction. Preserve the rest of the sentence verbatim.

"""

func testInputPrompt(task: String) -> String {
    return """
    Analyze the following block of text for unnatural sounding sentences based strictly on the criteria in your system instructions.

    TEXT:
    "\(task)"
    """
}


#Playground {
    let inputText = """
    To make my special fried rice, first you must prepare the rice from yesterday. Then, you chop some onion and garlic until they are small. The recipe says you need to use a very hot pan. You stir-fry the onion until it smells fragrant. After that, you add the rice and mix it carefully. Don't forget to close the gas when you are finished cooking.
    """
    
    let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    let session = LanguageModelSession(model: model, instructions: testSystemPrompt)
    
    let response = try await session.respond(
        to: testInputPrompt(task: inputText),
        generating: [UnnaturalSentence].self,
        options: GenerationOptions(sampling: .greedy, temperature: 0.5)
    )
    
    for flag in response.content {
        print(flag)
    }
    
//    var correctedText:  String = ""
//    var errorMessage: String = ""
//    let analyst = GrammarAnalyst()
//    
//    do {
//        let response = try await analyst.runSyntacticCheck(on: inputText)
//        
//        await MainActor.run {
//            correctedText = response
//        }
//        
//    } catch {
//        // Handle any errors
//        await MainActor.run {
//            errorMessage = error.localizedDescription
//        }
//    }
}
