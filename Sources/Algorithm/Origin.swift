//
// Implementation notes
// ====================
//
//  (source texts) –> (math basis) –> [created text] -> (refined text) -> (displayed text)
//                                     ––––––––––––
//
// Example of creating a text
// ––––––––––––––––––––––––––
//
//  idealStromg = "hello"
//  inputStromg = "hola"
//
//  ┌─────────────────┬───────────────┐  ┌───────────────┐
//  │ idealString     │ h e   l l o   │  │ Legend        │
//  │ inputString     │ h   o l     a │  ├───────────────┤
//  ├─────────────────┼───────────────┤  │ "+" – correct │
//  │ sourceSequence  │ 0 1   2 3 4   │  │ "?" - missing │
//  │ sequence        │ 0   4 2    nil│  │ "!" – extra   │
//  │ subsequence     │ 0     2       │  └───────────────┘
//  │ missingElements │   1     3 4   │
//  ├─────────────────┼───────────────┤
//  │ text            │ h e o l l o a │
//  ├─────────────────┼───────────────┤
//  │ annotations     │ + ? ! + ? ? ! │
//  └─────────────────┴───────────────┘
//
//  How to read the diagram:
//  - `sourceSequence` is the indices of `idealString` (0..<n).
//  - `sequence` maps each character of `inputString` to an index in `idealString` (or `nil` if no match).
//  - `subsequence` is the longest increasing subsequence of `sequence`.
//  - `missingElements` are indices in `sourceSequence` not present in `subsequence`.
//  - The created text interleaves user characters (with `.correct` or `.extra`) and inserted missing characters (`.missing`) at the correct positions.
//
// Other notes
// –––––––––––
//
//  Only three character annotations are used during creation: `.correct`, `.missing`, and `.extra`.
//  The types `.swapped` and `.misspell` are introduced later by a separate editing pass.
//  This separation keeps the creation logic focused on order and presence,
//  while higher layers handle more complex transformations.
//

/// A text origin that consists of methods to create the raw text.
/// This class produces a `TFText` with only `.correct`, `.missing`, and `.extra` annotations.
internal final class TFOrigin {
    
    // MARK: - Form Text
    
    /// Creates a raw annotated `TFText` by comparing a user's input against a reference string,
    /// following the rules defined in the configuration.
    ///
    /// This method produces a text where each character is initially classified as `.correct`, `.extra`, or `.missing`.
    ///
    /// ## Example
    /// ```
    /// let idealString = "Hello"
    /// let inputString = "hola"
    ///
    /// let configuration = TFConfiguration(
    ///     textCaseStrategy: .insensitive(.capitalized)
    /// )
    /// let text = TFOrigin.text(
    ///     comparing: inputString,
    ///     against: idealString,
    ///     using: configuration
    /// )
    /// /*[.correct("H"),
    ///    .missing("e"),
    ///    .extra  ("o"),
    ///    .correct("l"),
    ///    .missing("l"),
    ///    .missing("o"),
    ///    .extra  ("a")
    /// ]*/
    /// ```
    ///
    /// The formation is performed if there is at least one correct char; otherwise, it returns extra or missing text.
    /// ```
    /// let idealString = "bye"
    /// let inputString = "hi!"
    ///
    /// let text = TFOrigin.text(
    ///     comparing: inputString,
    ///     against: idealString,
    ///     using: TFConfiguration()
    /// )
    ///
    /// /*[.extra("h"),
    ///    .extra("i"),
    ///    .extra("!")
    /// ]*/
    /// ```
    /// - Returns: A raw `TFText` where each character is annotated as `.correct`, `.extra`, or `.missing`.
    static func text(comparing inputString: String, against idealString: String, using configuration: TFConfiguration) -> TFText {
        
        let inputString = inputString.normalized(with: configuration.textNormalizations)
        let idealString = idealString.normalized(with: configuration.textNormalizations)
        
        var missingIdealText: TFText { TFText(idealString, .missing, configuration.textCaseStrategy.transformation) }
        var wrongInputText:   TFText { TFText(inputString, .extra,   configuration.textCaseStrategy.transformation) }
        
        guard !inputString.isEmpty else { return missingIdealText }
        guard !idealString.isEmpty else { return wrongInputText   }
        
        let quickComplianceIsPassed = checkQuickCompliance(for: inputString, relyingOn: idealString, to: configuration)
        guard quickComplianceIsPassed else { return wrongInputText }
        
        let basis = TFAlgebra.basis(diffing: inputString, against: idealString)
        
        guard !basis.subsequence.isEmpty else { return wrongInputText }
        
        var text = wrongInputText
        
        text = addingCorrectChars(to: text, relyingOn: idealString, basedOn: basis, conformingTo: configuration)
        text = addingMissingChars(to: text, relyingOn: idealString, basedOn: basis, conformingTo: configuration)
        
        if let transformation = configuration.textCaseStrategy.transformation {
            text = text.tranfromed(to: transformation)
        }
        
        return text
    }
    
    
    // MARK: - Adding Missing Chars
    
    /// Returns a new text with missing characters inserted at their correct positions.
    ///
    /// This method assumes that the input `text` already contains the user's characters
    /// (some may be marked as `.extra`, `.correct`, etc.) **in the order they were typed**.
    /// It then inserts `.missing` characters (from the reference text) into the text at positions that align with the mathematical basis.
    ///
    /// **Important side effect:** Insertion changes the count and positions of characters,
    /// making the original `basis` **no longer valid** for further use (indices shift).
    ///
    /// - Note: The order of characters in `text` must not have been changed before calling this method (except for annotations changes).
    ///   Insertion respects the original relative order.
    /// - Returns: A new `TFText` where missing characters are inserted as `.missing`.
    @inline(__always)
    static func addingMissingChars(to text: TFText, relyingOn idealString: String, basedOn basis: TFBasis, conformingTo configuration: TFConfiguration) -> TFText {
        
        var text = text, subindex = Int()
        var subelement: Int { basis.subsequence[subindex] }
        var missingElements = basis.missingElements
        var indexToInsert = Int(), offset = Int()
        
        for (index, element) in basis.sequence.enumerated() where element == subelement {
            
            func insert(_ indeces: [Int]) -> Void {
                for index in indeces.reversed() {
                    let character = idealString[index]
                    text.insert(.missing(character), at: indexToInsert)
                }
            }
            
            let insertions = missingElements.filter { $0 < subelement }
            missingElements.removeFirst(insertions.count)
            insert(insertions)
            
            offset += insertions.count
            indexToInsert = (index + 1) + offset
            subindex += 1
            
            guard subindex < basis.subsequence.count else {
                insert(missingElements); break
            }
        }
        
        return text
    }
    
    
    // MARK: - Adding Correct Chars
    
    /// Returns a new text where characters that belong to the longest increasing subsequence are marked as `.correct`.
    ///
    /// This method **does not** change the number of characters or their order.
    /// It only updates the `annotation` of existing characters (from `.extra` to `.correct`)
    /// and, if case‑sensitive comparison is required, sets `hasCorrectCase` accordingly.
    ///
    /// The method relies on the assumption that the input `text` already contains characters that correspond to the user's input,
    /// and that the `basis.subsequence` indicates which positions in `basis.sequence` represent the longest increasing sequence of matches.
    ///
    /// - Note: This method assumes that the order of typed characters has not been changed before calling it,
    ///   and that the text contains the user's original characters.
    /// - Returns: A new `TFText` where the matched characters are marked as `.correct` and have their case correctness set if applicable.
    @inline(__always)
    static func addingCorrectChars(to text: TFText, relyingOn idealString: String, basedOn basis: TFBasis, conformingTo configuration: TFConfiguration) -> TFText {
        
        var text = text, subindex = Int()
        var subelement: Int { basis.subsequence[subindex] }
        
        let shouldCompareLetterCases = configuration.textCaseStrategy.isSensitive
        
        for (index, element) in basis.sequence.enumerated() where element == subelement {
            if shouldCompareLetterCases {
                let accurateChar = idealString[subelement]
                let comparedChar = text[index].value // because initially, all these chars match chars of the compared text
                text[index].hasCorrectCase = accurateChar == comparedChar
            }
            text[index].annotation = .correct
            subindex += 1
            guard subindex < basis.subsequence.count else { break }
        }
        
        return text
    }
    
    
    // MARK: - Check Quick Compliance
    
    /// Performs a fast, optimistic pre‑check to determine whether the user's text could possibly satisfy the configuration.
    ///
    /// This method is an **early exit optimisation** used before running the full (expensive) LIS‑based algorithm.
    /// It only considers **character presence** (multiset intersection), **ignoring order** entirely.
    /// Therefore, it provides an **upper bound** on the actual compliance:
    /// - If the quick check passes, the full algorithm **may** succeed (but is not guaranteed).
    /// - If the quick check fails, the full algorithm **will definitely** fail – saving unnecessary computation.
    ///
    /// For example, quick compliance might report 70% when the true value is 50%,
    /// but it will never report 50% when the true value is 70%.
    ///
    /// - Important: Order is **not** considered. Swaps, reorderings, and long common subsequences are ignored.
    ///   This is intentionally optimistic to avoid false negatives.
    /// - Returns: `true` if the compared text **could possibly** satisfy all configuration requirements (based only on character frequencies);
    ///  `false` if it is **impossible** to satisfy them.
    @inline(__always)
    static func checkQuickCompliance(for inputString: String, relyingOn idealString: String, to configuration: TFConfiguration) -> Bool {
        
        let commonCount = TFAlgebra.commonCharactersCount(between: inputString, and: idealString)
        
        guard commonCount > 0 else { return false }
        
        let accurateLength = idealString.count
        
        if let requiredCount = configuration.requiredQuantityOfCorrectCharacters.count(for: accurateLength, clamped: true) {
            guard requiredCount <= commonCount else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongCharacters.count(for: accurateLength) {
            let missingCount = idealString.count - commonCount
            let wrongCount = inputString.count - commonCount
            // Wrong and missing characters can be paired into misspellings,
            // so the actual number of mistakes may be as low as max(extras, missing).
            // This gives an optimistic lower bound on the number of mistakes,
            // which is the correct threshold to compare against `acceptableCount`.
            let mistakesCount = max(wrongCount, missingCount)
            guard mistakesCount <= acceptableCount else { return false }
        }
        
        return true
    }
    
}
