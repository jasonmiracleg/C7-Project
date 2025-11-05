//
//  SystemPrompt.swift
//  C7 Project
//
//  Created by Savio Enoson on 02/11/25.
//

// MARK: -- Flagging Model System Prompts
/// System Prompt given to the flagging model at the start of each session
nonisolated let grammarCheckSystemPrompt = """
You are an expert proofreader and English language tutor, specializing in identifying and correcting errors commonly made by L1 (First Language) Bahasa Indonesia speakers.

Your task is to identify and correct objective grammatical errors, spelling mistakes, and punctuation issues in the text provided.

You must adhere to the following rules:

1.  **Preserve Meaning:** Do not alter the user's original meaning, voice, or stylistic choices. Your corrections must be purely technical.

2.  **Focus on Errors:** Only correct objective errors (e.g., subject-verb agreement, tense, spelling). Do not make stylistic suggestions or rewrite sentences that are grammatically correct.

3.  **Obey Specific Task:** In addition to these general rules, you MUST pay special attention to the *specific task* mentioned in the user's prompt (e.g., "check for tense," "check for adjective order").

4.  **Clear Output:** Provide *only* the fully corrected version of the user's text. Do not add commentary, explanations, or engage in conversation. If no errors of the specified type are detected, reply with the original, unchanged text.
"""

/// Concatenated check prompt--seems to work almost just as well? Saves a lot of time.
/// TODO: Validate efficacy
nonisolated func checkAllCategories(forTask task: String) -> String {
    return """
    Your task is to perform a general check for all grammatical, spelling, and punctuation errors. Correct any errors you find.
    As a guide, here are several error types you should look out for:
    
    Articles: Insert missing articles ('a', 'an', 'the') where they are required (e.g., "I buy book" -> "I buy a book"). Correct any such errors you find.
    Missing Copula Verbs: Insert missing copula verbs ('is', 'am', 'are') where they are required (e.g., "She happy" -> "She is happy", "He at home" -> "He is at home"). Correct any such errors you find.
    Adjective Word Order: Correct any instances of the Bahasa Indonesia pattern (Noun + Adjective, e.g., "mobil merah") to the English pattern (Adjective + Noun, e.g., "red car").
    Verb Tenses: Look for incorrect verb forms for the context (e.g., "I go yesterday") or illogical mixing of tenses. Correct any tense errors you find.
    Subject-verb Agreement: Look for mismatches between a subject and its verb (e.g., "He walk", "They walks"). Correct any agreement errors you find.
    Modality: Look for incorrect use of modal verbs (e.g., "I can to go") or incorrect forms for hypothetical/conditional sentences (e.g., "If I am rich, I will buy a car"). Correct any modal errors you find.
    Word Formation (Morphology): Scrutinize the text for words that use the correct root concept but the wrong form (e.g., using an adjective like "clear" when an adverb "clearly" or a noun "clarity" is required). Correct any such errors you find.

    TEXT:
    "\(task)"
    """
}

nonisolated func generalGrammarCheck(forTask task: String) -> String {
    return """
    Your task is to perform a general check for all grammatical, spelling, and punctuation errors. Correct any errors you find.

    TEXT:
    "\(task)"
    """
}

nonisolated func articlesCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors related to missing or incorrect articles. Insert missing articles ('a', 'an', 'the') where they are required (e.g., "I buy book" -> "I buy a book"). Correct any such errors you find.
    
    TEXT:
    "\(task)"
    """
}

nonisolated func copulaCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors related to missing copula verbs. Insert missing copula verbs ('is', 'am', 'are') where they are required (e.g., "She happy" -> "She is happy", "He at home" -> "He is at home"). Correct any such errors you find.
    
    TEXT:
    "\(task)"
    """
}

nonisolated func adjectiveOrderCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors in adjective word order. Correct any instances of the Bahasa Indonesia pattern (Noun + Adjective, e.g., "mobil merah") to the English pattern (Adjective + Noun, e.g., "red car").
    
    TEXT:
    "\(task)"
    """
}

nonisolated func tensesCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors in verb tense. Look for incorrect verb forms for the context (e.g., "I go yesterday") or illogical mixing of tenses. Correct any tense errors you find.
    
    TEXT:
    "\(task)"
    """
}

nonisolated func pluralityCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors in subject-verb agreement. Look for mismatches between a subject and its verb (e.g., "He walk", "They walks"). Correct any agreement errors you find.
    
    TEXT:
    "\(task)"
    """
}

nonisolated func modalityCheck(forTask task: String) -> String {
    return """
    Your specific task is to check *only* for errors in modality. Look for incorrect use of modal verbs (e.g., "I can to go") or incorrect forms for hypothetical/conditional sentences (e.g., "If I am rich, I will buy a car"). Correct any modal errors you find.
    
    TEXT:
    "\(task)"
    """
}
