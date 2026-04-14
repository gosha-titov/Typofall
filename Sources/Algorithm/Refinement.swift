//
// Implementation notes
// ====================
//
//  (source texts) –> (math basis) –> (created text) -> [refined text] -> (displayed text)
//                                                       ––––––––––––
//
//  ┌────────────────┐
//  │ Legend         │
//  ├────────────────┤
//  │ "+" – correct  │
//  │ "?" - missing  │
//  │ "^" – swapped  │
//  │ 'm' – misspell │
//  │ "!" – extra    │
//  └────────────────┘
//
//
// Step 0: preparing source text
// –––––––––––––––––––––––––––––
//
//    Initial values         After creation        After preparation      After refinement
//  ┌───────────┬─────┐    ┌───────┬─────────┐    ┌───────┬─────────┐    ┌───────┬───────┐
//  │ idealText │ day │    │ chars │ d a y y │    │ chars │ d a y y │    │ chars │ d y y │
//  ├───────────┼─────┤ ─> ├───────┼─────────┤ ─> ├───────┼─────────┤ ─> ├───────┼───────┤
//  │ inputText │ dyy │    │ types │ + ? + ! │    │ types │ + ? ! + │    │ types │ + a + │
//  └───────────┴─────┘    └───────┴─────────┘    └───────┴─────────┘    └───────┴───────┘
//
//
// Step 1: adding misspell chars
// –––––––––––––––––––––––––––––
//
//    Initial values         After creation        After refinement
//  ┌───────────┬─────┐    ┌───────┬─────────┐    ┌───────┬───────┐
//  │ idealText │ day │    │ chars │ d a e y │    │ chars │ d e y │
//  ├───────────┼─────┤ ─> ├───────┼─────────┤ ─> ├───────┼───────┤
//  │ inputText │ dey │    │ types │ + ? ! + │    │ types │ + a + │
//  └───────────┴─────┘    └───────┴─────────┘    └───────┴───────┘
//
//
// Step 2: adding swapped chars
// ––––––––––––––––––––––––––––
//
//    Initial values         After creation        After refinement
//  ┌───────────┬─────┐    ┌───────┬─────────┐    ┌───────┬───────┐
//  │ idealText │ day │    │ chars │ d y a y │    │ chars │ d y a │
//  ├───────────┼─────┤ ─> ├───────┼─────────┤ ─> ├───────┼───────┤
//  │ inputText │ dya │    │ types │ + ! + ? │    │ types │ + ^ ^ │
//  └───────────┴─────┘    └───────┴─────────┘    └───────┴───────┘
//

/// A text refinement that consists of methods to make a created text user-friendly.
internal final class TFRefinement {
    
    // MARK: - Refining Text
    
    /// Edits the given raw text into a user-friendly representation.
    ///
    /// ## Example
    /// ```
    /// let idealString = "Hello"
    /// let inputString = "Halol"
    /// let configuration = TFConfiguration()
    ///
    /// let rawText = TFOrigin.text(
    ///     from: inputString,
    ///     relyingOn: idealString,
    ///     with: configuration
    /// )
    /// /*[.correct("H"),
    ///    .missing("e"),
    ///    .extra  ("a"),
    ///    .correct("l"),
    ///    .extra  ("o"),
    ///    .correct("l"),
    ///    .missing("o")
    /// ]*/
    ///
    /// let text = TFRefinement.refining(rawText, with: configuration)
    /// /*[.correct ("H"),
    ///    .misspell("a", correct: "o"),
    ///    .correct ("l"),
    ///    .swapped ("o", position: .left),
    ///    .swapped ("l", position: .right)
    /// ]*/
    /// ```
    /// - Returns: The edited text that is user-friendly and is ready to be displayed.
    static func refining(_ text: TFText, with configuration: TFConfiguration) -> TFText {
        var text = preparing(text)
        text = addindMisspellChars(to: text)
        text = addingSwappedChars(to: text)
        
        let exactComplianceIsPassed = checkExactCompliance(for: text, to: configuration)
        guard exactComplianceIsPassed else { return wrong(text) }
        
        return text
    }
    
    
    // MARK: - Convert to Wrong Text
    
    /// Converts an annotated text into a simplified representation where all non‑missing characters are treated as extra.
    ///
    /// This method is used as a fallback when the refined text does not satisfy the exact compliance requirements defined in the configuration.
    /// It produces a `TFText` that contains only `.extra` annotations (except for `.missing` characters, which are omitted entirely).
    @inline(__always)
    static func wrong(_ text: TFText) -> TFText {
        var characters = [TFCharacter]()
        for character in text.characters {
            switch character.annotation {
            case .correct, .extra, .misspell, .swapped:
                characters.append(.extra(character.value))
            case .missing:
                break
            }
        }
        return TFText(characters)
    }
    
    
    // MARK: - Check Exact Compliance
    
    /// Checks whether the annotated text strictly complies with the quantity limits defined in the configuration.
    ///
    /// Unlike a quick superficial check, this method performs a full statistical analysis based on the character‑by‑character annotations in the `TFText`.
    /// It counts how many characters are correct, missing, extra, misspelled, or swapped,
    /// and then compares those counts against the limits specified in `configuration.requiredQuantityOfCorrectCharacters` and `configuration.acceptableQuantityOfWrongCharacters`.
    ///
    /// - Returns: `true` if the text satisfies all the quantity constraints defined in the configuration; otherwise `false`.
    @inline(__always)
    static func checkExactCompliance(for text: TFText, to configuration: TFConfiguration) -> Bool {
        
        var correctCount = 0
        var missingCount = 0
        var extraCount = 0
        var misspellCount = 0
        var swappedCount = 0
        for character in text.characters {
            switch character.annotation {
            case .correct: correctCount += 1
            case .missing: missingCount += 1
            case .extra: extraCount += 1
            case .misspell: misspellCount += 1
            case .swapped: swappedCount += 1
            }
        }
        
        let idealLength = correctCount + missingCount + misspellCount + swappedCount
        if let requiredCount = configuration.requiredQuantityOfCorrectCharacters.count(for: idealLength, clamped: true) {
            let matchingCount = correctCount + swappedCount
            guard requiredCount <= matchingCount else { return false }
        }
        
        if let acceptableCount = configuration.acceptableQuantityOfWrongCharacters.count(for: idealLength) {
            let wrongCount = missingCount + extraCount + misspellCount + swappedCount / 2
            guard wrongCount <= acceptableCount else { return false }
        }
        
        return true
    }
    
    
    // MARK: - Adding Misspell Chars
    
    /// Combines nearby `.missing` and `.extra` characters into a single `.misspell` character.
    ///
    /// The text may still contain `.missing` and `.extra` characters that are close to each other.
    /// This method merges them pairwise into `.misspell` annotations,
    /// where a wrong character (`.extra`) is reinterpreted as a misspelling of the correct character (`.missing`).
    ///
    /// ## Example
    /// ```
    /// let idealString = "day"
    /// let inputString = "dey"
    ///
    /// let rawText = TFOrigin.text(
    ///     from: inputString,
    ///     relyingOn: idealString,
    ///     with: TFConfiguration()
    /// )
    /// /*[.correct("d"),
    ///    .missing("a"),
    ///    .extra  ("e"),
    ///    .correct("y")
    /// ]*/
    ///
    /// let adjustedText = TFRefinement.addindMisspellChars(to: rawText)
    /// /*[.correct ("d"),
    ///    .misspell("e", correct: "a")),
    ///    .correct ("y")
    /// ]*/
    /// ```
    /// - Returns: A new text where `.missing` and `.extra` pairs have been replaced with `.misspell` annotations.
    @inline(__always)
    static func addindMisspellChars(to text: TFText) -> TFText {
        guard text.count > 1 else { return text }
        
        var indecesOfMissingChars = [Int]()
        var indecesOfExtraChars   = [Int]()
        var text = text
        var offset = Int()
        
        for i in 0..<text.count {
            var index: Int { i + offset }
            switch text[index].annotation {
             case .missing:
                 if indecesOfExtraChars.count > 0 {
                     let indexOfExtraChar = indecesOfExtraChars.removeFirst()
                     let extraChar = text[indexOfExtraChar].value
                     let missingChar = text[index].value
                     text[indexOfExtraChar] = .misspell(extraChar, correct: missingChar)
                     text.remove(at: index)
                     offset -= 1
                 } else {
                     indecesOfMissingChars.append(index)
                 }
             case .extra:
                 if indecesOfMissingChars.count > 0 {
                     let indexOfMissingChar = indecesOfMissingChars.removeFirst()
                     let missingChar = text[indexOfMissingChar].value
                     let extraChar = text[index].value
                     text[indexOfMissingChar] = .misspell(extraChar, correct: missingChar)
                     text.remove(at: index)
                     offset -= 1
                 } else {
                     indecesOfExtraChars.append(index)
                 }
             default:
                 indecesOfMissingChars = []
                 indecesOfExtraChars = []
             }
        }
        
        return text
    }
    
    
    // MARK: - Adding Swapped Chars
    
    /// Detects and replaces a pattern of `.extra` + `.correct` + `.missing` with a swapped pair.
    ///
    /// This method looks for a specific three‑character pattern in the adjusted text:
    /// ```
    /// [extra] → [correct] → [missing]
    /// ```
    /// where the `.extra` and `.missing` characters have the **same lowercase value**,
    /// and the middle `.correct` character can be any value.
    ///
    /// When this pattern is found, it indicates that the user likely typed the correct character one position later than intended,
    /// resulting in a **swap** between the extra and the missing.
    ///
    /// ## Exampole
    /// ```
    /// let idealString = "day"
    /// let inputString = "dya"
    ///
    /// let rawText = TFOrigin.text(
    ///     from: inputString,
    ///     relyingOn: idealString,
    ///     with: TFConfiguration()
    /// )
    /// /*[.correct("d"),
    ///    .extra  ("y"),
    ///    .correct("a"),
    ///    .missing("y")
    /// ]*/
    ///
    /// let adjustedText = TFRefinement.addindSwappedChars(to: rawText)
    /// /*[.correct("d"),
    ///    .swapped("y", position: .left),
    ///    .swapped("a", position: .right)
    /// ]*/
    /// ```
    /// - Returns: A new text where detected swap patterns are replaced with `.swapped` annotations.
    @inline(__always)
    static func addingSwappedChars(to text: TFText) -> TFText {
        guard text.count > 1 else { return text }
        
        var text = text
        
        // from right to left to keep indices valid after removal
        for currIndex in (1..<text.count - 1).reversed() {
            
            let prevIndex = currIndex - 1, nextIndex = currIndex + 1
            let prevChar = text[prevIndex], nextChar = text[nextIndex]
            let prevAndNextCharsAreEqual = prevChar.value.lowercased() == nextChar.value.lowercased()
            let currCharIsCorrect = text[currIndex].isCorrect
            
            if prevAndNextCharsAreEqual, prevChar.isExtra, currCharIsCorrect, nextChar.isMissing {
                text[prevIndex].annotation = .swapped(position: .left)
                text[currIndex].annotation = .swapped(position: .right)
                text.remove(at: nextIndex)
            }
        }
        
        return text
    }
    
    
    // MARK: - Preparing Text
    
    /// Prepares the raw created text by reordering types between missing and subsequent matching characters.
    ///
    /// This method is a **preprocessing step** for later misspell detection (combining a missing and an extra into a single `.misspell`).
    /// It looks for patterns where a `.missing` character is followed by one or more `.correct` or `.extra` characters that have the **same lowercase value** as the missing one.
    /// When found, it swaps the types so that the missing character becomes `.extra` and the matching
    /// following character(s) become `.correct`, effectively "moving" the correct placement forward.
    ///
    /// ## Example
    /// ```
    /// let idealString = "day"
    /// let inputString = "dyy"
    ///
    /// let rawText = TFOrigin.text(
    ///     from: inputString,
    ///     relyingOn: idealString,
    ///     with: TFConfiguration()
    /// )
    /// /*[.correct("d"),
    ///    .missing("a"),
    ///    .correct("y"),
    ///    .extra  ("y")   // <<<
    /// ]*/
    ///
    /// let adjustedText = TFRefinement.preparing(rawText)
    /// /*[.correct("d"),
    ///    .missing("a"),
    ///    .extra  ("y"),  // <<<
    ///    .correct("y")
    /// ]*/
    /// ```
    /// - Returns: An adjusted `TFText` where certain type swaps have been performed to facilitate misspell detection.
    @inline(__always)
    static func preparing(_ text: TFText) -> TFText {
        guard text.count > 1 else { return text }
        
        var countOfEqualCorrectChars = Int()
        var countOfMissingChars = Int()
        var indexOfFirstCorrectChar: Int? = nil
        var text = text
        
        func resetValues() -> Void {
            indexOfFirstCorrectChar = nil
            countOfEqualCorrectChars = 0
            countOfMissingChars = 0
        }
        
        for (currentIndex, currentChar) in text.enumerated() {
            switch currentChar.annotation {
            case .missing:
                countOfMissingChars += 1
                indexOfFirstCorrectChar = nil
                countOfEqualCorrectChars = 0
            case .correct:
                guard countOfMissingChars > 0 else {
                    indexOfFirstCorrectChar = nil
                    countOfEqualCorrectChars = 0
                    continue
                }
                if let indexOfFirstCorrectChar {
                    let firstCorrectChar = text[indexOfFirstCorrectChar]
                    guard firstCorrectChar.value.lowercased() == currentChar.value.lowercased() else {
                        resetValues()
                        continue
                    }
                } else {
                    indexOfFirstCorrectChar = currentIndex
                }
                countOfEqualCorrectChars += 1
            case .extra:
                guard countOfMissingChars > 0, let indexOfFirstChar = indexOfFirstCorrectChar,
                      text[indexOfFirstChar].value.lowercased() == currentChar.value.lowercased()
                else {
                    resetValues()
                    continue
                }
                let indexOfLastChar = indexOfFirstChar + countOfEqualCorrectChars - 1
                for index in ((indexOfFirstChar + 1)...(indexOfLastChar + 1)).reversed() {
                    let previousChar = text[index - 1]
                    if let previousLetterCase = previousChar.hasCorrectCase {
                        let currentChar = text[index]
                        if currentChar.value == previousChar.value {
                            text[index].hasCorrectCase = previousLetterCase
                        } else {
                            text[index].hasCorrectCase = !previousLetterCase
                        }
                    } else {
                        text[index].hasCorrectCase = nil
                    }
                    text[index].annotation = .correct
                }
                text[indexOfFirstChar].hasCorrectCase = nil
                text[indexOfFirstChar].annotation = .extra
                indexOfFirstCorrectChar! += 1
                countOfMissingChars -= 1
            default:
                resetValues()
            }
        }
        
        return text
    }
    
}
