//
//  TestPlayground.swift
//  C7 Project
//
//  Created by Savio Enoson on 07/11/25.
//

import Playgrounds
import Foundation
import FoundationModels

@Generable
struct FluencySuggestion: CustomStringConvertible, Sendable, Hashable {
    @Guide(description: "Populate this field with the **full, original, unedited sentence** where the unnatural phrase occurred. This field MUST be **1 sentence at most**.")
    let originalSentence: String
    
    @Guide(description: "Populate this field with the **fully corrected version of the original sentence**.")
    let suggestedSentence: String
    
    @Guide(description: "A short, simple explanation for *why* the original phrase was unnatural/nonsensical and *why* the suggested correction is the standard, natural alternative in this context.")
    let rationale: String
    
    var description: String {
        return """
        Original: "\(self.originalSentence)"
        Suggestion: "\(self.suggestedSentence)"
        Rationale: \(self.rationale)
        """
    }
}


func getSystemPrompt() -> String {
    return """
    PRIME DIRECTIVE: FIND AND CORRECT UNNATURAL OR NONSENSICAL PHRASES.

    You are an expert English language tutor and native-speaker. Your task is to read a text written by a non-native speaker and identify all words or phrases that sound **unnatural, non-idiomatic, nonsensical, or "clunky."**

    Your goal is to trust your own intuition as a native speaker to correct for **fluency and naturalness**. You are not just checking objective grammar; you are checking for *idiomaticity*.

    ---
    **1. A GUIDELINE TO "UNNATURAL" PHRASES (WHAT TO LOOK FOR)**
    ---
    To guide your intuition, "unnatural" phrases commonly (but not always) fall into one of the following categories. Use these descriptions to help you spot errors. You do **not** need to classify the error; just find it and suggest the natural correction.

    * **GUIDELINE 1: Structural & Prepositional Errors (Calques)**
        * **Symptom:** The phrase's *grammatical structure* itself feels broken, awkward, or non-standard. This often happens with prepositions that are a literal L1 translation, or an awkward ordering of words in a passive construction.

    * **GUIDELINE 2: Unnatural Word Partnerships (Collocations)**
        * **Symptom:** The *grammar is correct*, but the words themselves do not "go together" in standard English. This includes unnatural pairings of "light verbs" with nouns, incorrect phrasal verbs for common actions, or tautological (redundant) phrases.

    * **GUIDELINE 3: Logical/Conceptual Errors (Misselections)**
        * **Symptom:** A *single word* is used in a way that is logically inconsistent or semantically *contradicts* its surrounding context, making the sentence confusing or nonsensical.

    ---
    **2. CRITICAL: WHAT *NOT* TO FLAG (YOUR "INVALIDITY" TEST)**
    ---
    Your biggest challenge is to avoid "false positives." You must obey this rule:

    **If a phrase is already 100% natural, correct, and idiomatic, you MUST leave it alone.**

    * **DO NOT BE A "GRAMMAR CHECKER":** The text will have *already* been corrected for basic grammar (tense, S/V agreement, etc.). You are **not** looking for those. You are looking for issues of **naturalness**.
    * **DO NOT MAKE STYLISTIC SWAPS:** This is a critical failure. If a phrase is already perfectly natural, do not swap one correct word for another correct synonym. You are only here to fix what is **unnatural or nonsensical**.

    ---
    **3. YOUR PROCEDURE (MANDATORY WORKFLOW)**
    ---
    You must follow these steps. This procedure is mandatory to prevent errors.

    1.  **Read and Identify:** Read the text to find an unnatural or nonsensical phrase.
    2.  **Extract Full Sentence:** Get the **full, original sentence** in which that phrase appears. This will be the `originalSentence`.
    3.  **Formulate Rationale (Show Your Work):**
        * You must *first* formulate the `rationale`. This rationale **MUST** contain three parts:
            1.  The *original unnatural phrase* (the part that is wrong).
            2.  The *suggested correct phrase* (the replacement).
            3.  A simple *reason* for the change.
        * This step is your "thought" process, written down.

    4.  **Formulate Corrected Sentence (Apply Your Work):**
        * Now, *mechanically* create the `suggestedSentence`.
        * Take the `originalSentence` from Step 2.
        * Find the "original unnatural phrase" (from Step 3) and replace it with the "suggested correct phrase" (from Step 3).
        * The rest of the sentence MUST remain identical.

    5.  **Generate Struct (CRITICAL):** You must now generate one `FluencySuggestion` struct.
        * The `originalSentence` field **MUST** contain the text from Step 2.
        * The `rationale` field **MUST** contain the text from Step 3.
        * The `suggestedSentence` field **MUST** contain the corrected sentence from Step 4.
        * **CRITICAL:** A mismatch between the `rationale`'s correction and the `suggestedSentence` is a primary failure. The `suggestedSentence` **MUST NOT** be identical to the `originalSentence`.

    6.  **Repeat:** Repeat this 5-step process for *every* unnatural phrase you find.
    7.  **Finalize:** If no unnatural or nonsensical phrases are found, you MUST return an empty array.

    """
}

func fluencyPrompt(task: String) -> String {
    return """
    Your task is to meticulously check the text for **unnatural, non-idiomatic, or nonsensical phrases**, following the rules and **MANDATORY 7-STEP WORKFLOW** in your system prompt.

    Trust your intuition as a native-speaker. For each error you find, you **MUST** first state the original and corrected phrase in the `rationale`, and then apply that exact correction to create the `suggestedSentence`.

    TEXT:
    "\(task)"
    """
}

#Playground {
    let inputText = """
        The new marketing proposal is causing a lot of debate. The director presented a new strategy that cuts our budget in half. His new idea was difficult to be accepted by the team because it seemed so risky. We'll need another meeting to discuss all the implications.
    """
    
    
    let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)
    let session = LanguageModelSession(model: model, instructions: getSystemPrompt())
    
//    let correctedGrammarText = try await grammarCheckSession.respond(
//        to: prompt,
//        generating: TextBlock.self,
//        options: GenerationOptions(sampling: .greedy, temperature: 0.5)
//    ).content.correctedText
    
    let response = try await session.respond(
        to: fluencyPrompt(task: inputText),
        generating: [FluencySuggestion].self,
        options: GenerationOptions(sampling: .greedy, temperature: 0.5)
    )
    
    let suggestions: [FluencySuggestion] = response.content
    for entry in suggestions {
        print(entry)
    }
}
