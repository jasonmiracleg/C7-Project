import Foundation

extension GrammarEvaluationDetail: CustomStringConvertible {
    
    /// Provides a machine-readable JSON string description of the evaluation.
    ///
    /// Example Format:
    /// {
    ///   "annotated_original": "He <1: \"visit\"> his friends.",
    ///   "annotated_corrected": "He <1: \"visited\"> his friends.",
    ///   "errors": [
    ///     {
    ///       "id": 1,
    ///       "error_type": "Verb Tense",
    ///       "original": "visit",
    ///       "correction": "visited",
    ///       "edit": "changed 'visit' to 'visited'"
    ///     }
    ///   ]
    /// }
    public var description: String {
        
        // 1. Create a reverse lookup for error type
        var errorTypeLookup = [GrammarError: SyntacticErrorType]()
        for (type, errorList) in errors {
            for error in errorList {
                errorTypeLookup[error] = type
            }
        }
        
        // 2. Get all errors and assign stable, sorted IDs
        let allErrors = errors.values.flatMap { $0 }.sorted { $0.originalStartChar < $1.originalStartChar }
        var errorIDs = [GrammarError: Int]()
        for (index, error) in allErrors.enumerated() {
            errorIDs[error] = index + 1
        }
        
        // 3. Build annotated strings
        let annotatedOriginal = buildAnnotatedString(
            text: originalText,
            errors: allErrors,
            errorIDs: errorIDs,
            useOriginalOffsets: true
        )
        
        let annotatedCorrected = buildAnnotatedString(
            text: correctedText,
            errors: allErrors,
            errorIDs: errorIDs,
            useOriginalOffsets: false
        )
        
        // 4. Build the JSON for the error list
        var errorJsonObjects: [String] = []
        // Sort by ID to ensure list order matches [1], [2], ...
        for (error, id) in errorIDs.sorted(by: { $0.value < $1.value }) {
            guard let errorType = errorTypeLookup[error] else { continue }
            
            // *** USE THE NEW FUNCTION ***
            let jsonObject = jsonifyError(error: error, id: id, errorType: errorType)
            errorJsonObjects.append(jsonObject)
        }
        
        let errorArrayString = "[\n" + errorJsonObjects.joined(separator: ",\n") + "\n    ]"
        
        // 5. Assemble the final JSON output
        return """
        {
            "original_text": "\(escapeJSONString(annotatedOriginal))",
            "corrected_text": "\(escapeJSONString(annotatedCorrected))",
            "errors": \(errorArrayString)
        }
        """
    }
    
    /// Finds a specific error and its type by its 1-based sorted index.
    /// This sorting is consistent with the `description` JSON output.
    ///
    /// - Parameter id: The 1-based index of the error.
    /// - Returns: A tuple containing the `GrammarError` and its `SyntacticErrorType`, or `nil` if the ID is not found.
    public func getError(byId id: Int) -> (error: GrammarError, type: SyntacticErrorType)? {
        // 1. Create a reverse lookup for error type
        var errorTypeLookup = [GrammarError: SyntacticErrorType]()
        for (type, errorList) in errors {
            for error in errorList {
                errorTypeLookup[error] = type
            }
        }
        
        // 2. Get all errors in their stable, sorted order
        let allErrors = errors.values.flatMap { $0 }.sorted { $0.originalStartChar < $1.originalStartChar }
        
        // 3. Find the target error
        guard id > 0 && id <= allErrors.count else {
            return nil // ID is out of bounds
        }
        let targetError = allErrors[id - 1]
        
        guard let targetErrorType = errorTypeLookup[targetError] else {
            return nil // Should not happen, but good safety check
        }
        
        return (targetError, targetErrorType)
    }
    
    /// Formats the evaluation as a JSON string for a *single* specified error ID.
    ///
    /// - Parameter id: The 1-based index of the error to format.
    /// - Returns: A JSON-formatted string, or `nil` if the ID is not found.
    public func formatInputForError(id: Int) -> String? {
        // 1. Find the error
        guard let (error, _) = getError(byId: id) else {
            return nil
        }
        // 2. Call the overload
        return formatInputForError(error: error)
    }

    /// Formats the evaluation as a JSON string for a *single* specified error.
    ///
    /// - Parameter error: The `GrammarError` to format.
    /// - Returns: A JSON-formatted string, or `nil` if the error is not found in this evaluation.
    public func formatInputForError(error targetError: GrammarError) -> String? {
        // 1. We must find the ID and Type for this error, relative to this evaluation
        
        // 1a. Create a reverse lookup for error type
        var errorTypeLookup = [GrammarError: SyntacticErrorType]()
        for (type, errorList) in errors {
            for error in errorList {
                errorTypeLookup[error] = type
            }
        }
        
        // 1b. Get all errors in their stable, sorted order to find the ID
        let allErrors = errors.values.flatMap { $0 }.sorted { $0.originalStartChar < $1.originalStartChar }
        
        // 1c. Find the specific error, its type, and its ID
        guard let (index, foundError) = allErrors.enumerated().first(where: { $0.element.id == targetError.id }),
              let targetErrorType = errorTypeLookup[foundError]
        else {
            return nil // This error doesn't belong to this evaluation
        }
        
        let errorID = index
        
        // 2. Build annotated strings for *only* this error
        let errorToAnnotate = [targetError]
        let errorIDMap = [targetError: errorID]
        
        let annotatedOriginal = buildAnnotatedString(
            text: originalText,
            errors: errorToAnnotate,
            errorIDs: errorIDMap,
            useOriginalOffsets: true
        )
        
        let annotatedCorrected = buildAnnotatedString(
            text: correctedText,
            errors: errorToAnnotate,
            errorIDs: errorIDMap,
            useOriginalOffsets: false
        )
        
        // 3. Build the single error JSON object
        let errorJsonObject = jsonifyError(error: targetError, id: errorID, errorType: targetErrorType)
        
        // 4. Assemble the final JSON output
        return """
        {
            "original_text": "\(escapeJSONString(annotatedOriginal))",
            "corrected_text": "\(escapeJSONString(annotatedCorrected))",
            "error": \(errorJsonObject)
        }
        """
    }
    
    // MARK: - Private JSON Helpers
    
    /// Helper to build the annotated string with numbered indicators and the snippet,
    /// e.g., <1: "visit">.
    private func buildAnnotatedString(text: String, errors: [GrammarError], errorIDs: [GrammarError: Int], useOriginalOffsets: Bool) -> String {
        var result = ""
        var lastIndexOffset = 0
        
        // Sort errors based on the text we are annotating (original vs corrected)
        let sortedErrors = errors.sorted {
            let start1 = useOriginalOffsets ? $0.originalStartChar : $0.correctedStartChar
            let start2 = useOriginalOffsets ? $1.originalStartChar : $1.correctedStartChar
            return start1 < start2
        }
        
        for error in sortedErrors {
            guard let errorID = errorIDs[error] else { continue }
            
            let startOffset = useOriginalOffsets ? error.originalStartChar : error.correctedStartChar
            let endOffset = useOriginalOffsets ? error.originalEndChar : error.correctedEndChar
            
            // Determine the snippet to display inside the tag
            // If we're annotating the original text, use the original snippet, otherwise use the corrected one.
            let snippet = useOriginalOffsets ? error.originalText : error.correctedText
            
            // Create the tag, e.g., <1: "visit"> or <2: ""> for an insertion
            let tag = "<\(errorID): \"\(escapeJSONString(snippet))\">"
            
            guard startOffset >= lastIndexOffset,
                  let startIndex = text.index(text.startIndex, offsetBy: startOffset, limitedBy: text.endIndex),
                  let lastIndex = text.index(text.startIndex, offsetBy: lastIndexOffset, limitedBy: text.endIndex),
                  let endIndex = text.index(text.startIndex, offsetBy: endOffset, limitedBy: text.endIndex),
                  endIndex <= text.endIndex
            else {
                continue // Skip overlapping or out-of-bounds errors
            }
            
            // Append text from the last offset to this error's start
            result.append(String(text[lastIndex..<startIndex]))
            // Append the indicator tag
            result.append(tag)
            // Update the last offset position
            lastIndexOffset = endOffset
        }
        
        // Append any remaining text
        if let finalIndex = text.index(text.startIndex, offsetBy: lastIndexOffset, limitedBy: text.endIndex), finalIndex < text.endIndex {
            result.append(String(text[finalIndex..<text.endIndex]))
        } else if lastIndexOffset == 0 {
            return text // No errors, return original text
        }
        
        return result
    }
    
    /// Helper to generate the dynamic "edit" description string.
    private func getEditDescription(for error: GrammarError, ofType errorType: SyntacticErrorType) -> String {
        // Escape any single quotes *within* the snippets, as the output format uses single quotes.
        let originalSnippet = error.originalText.replacingOccurrences(of: "'", with: "\\'")
        let correctedSnippet = error.correctedText.replacingOccurrences(of: "'", with: "\\'")
        
        switch errorType {
        case .WordOrder:
            return "reordered '\(originalSnippet)' to '\(correctedSnippet)'"
        default:
            if originalSnippet.isEmpty {
                return "added '\(correctedSnippet)'"
            } else if correctedSnippet.isEmpty {
                return "removed '\(originalSnippet)'"
            } else {
                return "changed '\(originalSnippet)' to '\(correctedSnippet)'"
            }
        }
    }
    
    /// Helper to create the JSON object string for a single error.
    private func jsonifyError(error: GrammarError, id: Int, errorType: SyntacticErrorType) -> String {
        let editDesc = getEditDescription(for: error, ofType: errorType)
        
        // Build the JSON object string for this error
        return """
                {
                    "errorID": \(id),
                    "error_type": "\(escapeJSONString(errorType.title))",
                    "original": "\(escapeJSONString(error.originalText))",
                    "correction": "\(escapeJSONString(error.correctedText))",
                    "edit": "\(escapeJSONString(editDesc))"
                }
        """
    }
    
    /// Helper to make a string safe for embedding inside a JSON value.
    /// (Kept here because buildAnnotatedString needs it)
    private func escapeJSONString(_ string: String) -> String {
        var s = string
        s = s.replacingOccurrences(of: "\\", with: "\\\\") // Must be first
        s = s.replacingOccurrences(of: "\"", with: "\\\"")
        s = s.replacingOccurrences(of: "\n", with: "\\n")
        s = s.replacingOccurrences(of: "\t", with: "\\t")
        s = s.replacingOccurrences(of: "\r", with: "\\r")
        return s
    }
}
