import Foundation

//
// Implementation notes
// ====================
//
//  (source texts) –> [math basis] –> (created text) -> (refined text) -> (displayed text)
//                     ––––––––––
//
// Overview
// ––––––––
//
//  The math core transforms two strings (reference and user input) into a mathematical basis consisting of index sequences.
//  This basis is then used by higher layers to determine character‑level types (correct, missing, extra, swapped, misspell).
//
//  Complexity depends heavily on the number of identical characters in the texts.
//  More identical characters → more possible matchings → more operations.
//
//
// First Examle
// ––––––––––––
//
//  For a text of length `n` consisting of a single repeated character, the algorithm must
//  consider all non‑decreasing sequences of indices of length `n` (with repetition allowed).
//  The number of such sequences is C(2n-1, n) (combinations with repetition).
//
//  Examples of tables with non-decreasing sequences of the specific length:
//
//  ┌─────┐ ┌───────┐ ┌─────────┐ ┌───────────┐ ┌─────────────┐
//  │ 0 0 │ │ 0 0 0 │ │ 0 0 0 0 │ │ 0 0 0 0 0 │ │ 0 0 0 0 0 0 │
//  │ 0 1 │ │ 0 0 1 │ │ 0 0 0 1 │ │ 0 0 0 0 1 │ │ 0 0 0 0 0 1 │
//  │ 1 1 │ │ 0 0 2 │ │         │ │           │ │             │
//  └─────┘ │ 0 1 1 │ │   ...   │ │    ...    │ │     ...     │
//     3    │ 0 1 2 │ │         │ │           │ │             │
//          │ 0 2 2 │ │ 2 3 3 3 │ │ 3 4 4 4 4 │ │ 4 5 5 5 5 5 │
//          │ 1 1 1 │ │ 3 3 3 3 │ │ 4 4 4 4 4 │ │ 5 5 5 5 5 5 │
//          │ 1 1 2 │ └─────────┘ └───────────┘ └─────────────┘
//          │ 1 2 2 │      35          126            462
//          │ 2 2 2 │
//          └───────┘
//              10
//
//  Table of operations for length L (without optimizations):
//  ┌────────┬───┬───┬────┬────┬─────┬─────┬──────┬──────┬───────┬───────┐
//  │ length │ 1 │ 2 │ 3  │ 4  │  5  │  6  │  7   │  8   │   9   │  10   │
//  ├────────┼───┼───┼────┼────┼─────┼─────┼──────┼──────┼───────┼───────┤
//  │ count  │ 1 │ 3 │ 10 │ 35 │ 126 │ 462 │ 1716 │ 6435 │ 24310 │ 92378 │
//  └────────┴───┴───┴────┴────┴─────┴─────┴──────┴──────┴───────┴───────┘
//
//  These numbers show how much the complexity of calculations increases
//  with an increase the number of identical chars.
//
//  That is, for the "aaa" text there are performed 10 operations.
//  (There are several optimizations that in most cases reduce the number of operations to a minimum)
//
//
// Second example
// ––––––––––––––
//
//  Let's take the accurate text = "abab" and the compared text = "baba":
//
//  Firstly, we create the correct sequence for the accurate text, it's [0, 1, 2, 3]
//  Then we make a following table based on this sequence and the accurate text:
//
//   Sequences  Subsequences
//  ┌─────────┐ ┌─────────┐
//  │ 1 0 1 0 │ │   0 1   │
//  │[1 0 1 2]│ │[  0 1 2]│ <- Best dyad (smallest subsequence sum)
//  │ 1 0 3 0 │ │   0 3   │
//  │ 1 0 3 2 │ │   0   2 │
//  │ 1 2 1 2 │ │ 1 2     │
//  │ 1 2 3 2 │ │ 1 2 3   │
//  │ 3 0 3 0 │ │   0 3   │
//  │ 3 0 3 2 │ │   0   2 │
//  │ 3 2 3 2 │ │   2 3   │
//  └─────────┘ └─────────┘
//
//  Now we have to choose the best dyad: [1, 0, 1, 2] and [0, 1, 2].
//  This means that by comparing the sequence and its subsequence with each other
//  we are able to understand which characters are wrong or missing:
//
//  ┌──────────────────┬────────────┐
//  │ Source sequence  │    0 1 2 3 │
//  ├──────────────────┼────────────┤
//  │ Sequence         │  1 0 1 2   │
//  ├──────────────────┼────────────┤
//  │ Subsequence      │    0 1 2   │
//  ├──────────────────┼────────────┤
//  │ Missing Elements │          3 │
//  └──────────────────┴────────────┘
//
//  This leads to the conclusion:
//   - First character is extra (1 not in subsequence)
//   - Next three characters map to [0, 1, 2] are correct
//   - Last character of reference is missing.
//
//  Note, that final count of operations = (identical chars in reference) × (identical chars in user)
//  That is, 3*3=9 operations are performed for this example.
//  For "aaaaabbb" and "bbbaaaaa", 126*10=1260 operations are performed.
//  But this is without optimizations, because when using them, the final count is only ONE.
//
//  But at the same time for a text consisting of 300 chars where there are only 3 identical chars (100 kinds of char),
//  100*10=1000 operations are performed.
//
//
// General Optimization
// ––––––––––––––––––––
//
//  accurateText: "123a456bc789"
//  comparedText: "123bc456a789"
//
//  1. Remove common prefix and suffix:
//
//  accurateText: "123" [ "a456bc" ] "789"
//  comparedText: "123" [ "bc456c" ] "789"
//
//  2. Find a long common substring (longer than half the shorter remaining text):
//
//  accurateText: "123" [ "a"  ] "456" [ "bc" ] "789"
//  comparedText: "123" [ "bc" ] "456" [ "c"  ] "789"
//                        ^^^^           ^^^^
//
//  3. Only small parts remain for the full LIS‑based matching.
//
//
// Practical Considerations
// ––––––––––––––––––––––––
//
// In theory, the algorithm works for any text length.
// In practice, for very long texts (e.g., hundreds of characters with many repetitions), the number of raw sequences can explode.
// Therefore, it is recommended to split the input into sentences or words before processing.
//
// However, if the user input is expected to be reasonably close to the reference (typical typo‑detection),
// the optimisations already keep the performance acceptable even without splitting.
//

/// A math core that consists of static methods for working with numbers, sequences, subsequences and so on.
/// It implements the LIS‑based algorithm to produce a mathematical basis (TFBasis) from two input texts.
internal final class TFAlgebra {
    
    /// Calculates the mathematical basis for comparing a user's text against a reference text.
    ///
    /// This is the **entry point method** of `TFAlgebra`.
    /// It takes two strings (the reference text and the user's input) and produces a `TFBasis` – a set of index‑based sequences
    /// that describe how characters in the user's text can be matched to characters in the reference text,
    /// respecting order and accounting for possible mismatches, insertions, deletions, and swaps.
    ///
    /// ## Example
    /// ```swift
    /// let accurateText = "Hello"
    /// let comparedText = "hola"
    ///
    /// let basis = TFAlgebra.basis(
    ///     for: comparedText,
    ///     relyingOn: accurateText
    /// )
    ///
    /// basis.sourceSequence  // [0, 1, 2, 3, 4]
    /// basis.sequence        // [0, 4, 2, nil ]
    /// basis.subsequence     // [0,    2      ]
    /// basis.missingElements // [   1,    3, 4]
    /// ```
    /// - Note: Both texts are converted to lowercase before processing.
    ///   Case sensitivity is handled at a higher level (by `TFStrategy`).
    /// - Parameters:
    ///   - comparedText: The user's input text to be evaluated.
    ///   - accurateText: The reference (correct) text.
    /// - Returns: A `TFBasis` containing the index‑based representation of the best matching between the two texts.
    static func basis(for comparedText: String, relyingOn accurateText: String) -> TFBasis {
        
        // Step 1: Case‑insensitive normalisation (lowercase)
        let comparedText = comparedText.lowercased(), accurateText = accurateText.lowercased()
        let accurateSequence = TFSequence(0..<accurateText.count)
        
        // Step 2: Extract common prefix and suffix (optimisation)
        let prefixCount = comparedText.commonPrefix(with: accurateText).count
        var partialAccurateText = accurateText.dropFirst(prefixCount).toString()
        var partialComparedText = comparedText.dropFirst(prefixCount).toString()
        
        let suffixCount = partialComparedText.commonSuffix(with: partialAccurateText).count
        partialAccurateText = partialAccurateText.dropLast(suffixCount).toString()
        partialComparedText = partialComparedText.dropLast(suffixCount).toString()
        
        // Steps 3: Process the remaining middle part
        let sequences = sequences(for: partialComparedText, relyingOn: partialAccurateText)
        let dyads = dyads(from: sequences)
        let dyad = bestDyad(among: dyads)
        
        // Step 4: Restore the common prefix and suffix indices
        let accurateSequencePrefix = accurateSequence.prefix(prefixCount).toArray()
        let accurateSequenceSuffix = accurateSequence.suffix(suffixCount).toArray()
        
        // Shift the middle part indices by the length of the prefix
        let shiftedPartialSequence    = dyad.sequence   .map { $0.hasValue ? $0! + prefixCount : nil }
        let shiftedPartialSubsequence = dyad.subsequence.map {               $0  + prefixCount       }
        
        // Step 5: Assemble the complete sequences
        let sequence    = accurateSequencePrefix + shiftedPartialSequence    + accurateSequenceSuffix
        let subsequence = accurateSequencePrefix + shiftedPartialSubsequence + accurateSequenceSuffix
        
        return TFBasis(accurateSequence, sequence, subsequence)
    }
    
    
    // MARK: - Pick Best Dyad
    
    /// Selects the best mathematical pair from an array of candidates based on the sum of its subsequence.
    ///
    /// Given multiple raw pairs (each containing a sequence and its longest increasing subsequence),
    /// this method chooses the pair whose subsequence has the **smallest total sum** of its elements.
    ///
    /// The subsequence indices correspond to positions in the reference text.
    /// A smaller sum typically means the matched characters appear **earlier** in the reference text,
    /// which often yields a more natural alignment and reduces the chance of spurious matches.
    ///
    /// ## Example
    /// ```swift
    /// let dyads = [
    ///     TFDyad([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///     TFDyad([nil, 1, 2, 4, 3], [1, 2, 3])  // best
    /// ]
    /// let bestDyad = TFAlgebra.bestDyad(among: dyads)
    /// // TFDyad([nil, 1, 2, 4, 3], [1, 2, 3])
    /// ```
    /// - Important: This method assumes that **all subsequences have the same length**.
    ///   If lengths differ, comparing sums is meaningless and the result is undefined.
    ///   The method is intended to be used after filtering by LIS length (e.g., via `makeRawPairs(from:)`).
    /// - Returns: The pair with the smallest sum of its `subsequence` array.
    ///   If the array is empty, returns an empty pair.
    @inline(__always)
    static func bestDyad(among dyads: [TFDyad]) -> TFDyad {
        
        guard dyads.isEmpty == false else { return TFDyad() }
        guard dyads.count > 1 else { return dyads[0] }
        
        var bestDyad = dyads[0]
        
        for dyad in dyads[1...] {
            let lis = dyad.subsequence, bestLis = bestDyad.subsequence
            if lis.sum() < bestLis.sum() {
                bestDyad = dyad
            }
        }
        
        return bestDyad
    }
    
    
    // MARK: - Make Raw Dyads
        
    /// Creates mathematical pairs by computing the LIS for each raw sequence and keeping only those with the maximum LIS length.
    ///
    /// This method processes the raw sequences generated by `generateRawSequences(for:relyingOn:)`.
    /// For each raw sequence (which may contain `nil` values for unmatched characters), it:
    /// 1. Filters out `nil`s to obtain a pure integer sequence.
    /// 2. Computes the longest increasing subsequence (LIS) of that integer sequence.
    /// 3. Tracks the maximum LIS length found across all raw sequences.
    /// 4. Returns only the pairs whose LIS length equals that maximum.
    ///
    /// The result represents the **best possible matches** between the user’s text and the reference,
    /// in terms of the longest chain of correctly ordered matching characters.
    ///
    /// ## Example
    /// ```
    /// let sequences = [
    ///     [nil, 1, 2, 4, 1], // LIS: [1, 2, 4]
    ///     [nil, 1, 2, 4, 3], // LIS: [1, 2, 3]
    ///     [nil, 3, 2, 4, 3]  // LIS: [2, 3]
    /// ]
    ///
    /// let dyads = TFAlgebra.dyads(from: sequences)
    /// /* [TFDyad([nil, 1, 2, 4, 1], [1, 2, 4]),
    ///     TFDyad([nil, 1, 2, 4, 3], [1, 2, 3])] */
    /// ```
    /// - Important: Only raw sequences whose LIS length is **equal to the global maximum** are included in the result.
    /// This discards suboptimal matchings.
    /// - Returns: An array of `TFDyad` containing only the pairs with the longest possible increasing subsequence.
    @inline(__always)
    static func dyads(from rawSequences: [TFOptionalSequence]) -> [TFDyad] {
        
        var dyads = [TFDyad]()
        var maxCount = Int()
        
        for rawSequence in rawSequences {
            let sequence = rawSequence.compactMap { $0 }
            let subsequence = lis(of: sequence)
            if subsequence.count >= maxCount {
                let dyad = TFDyad(rawSequence, subsequence)
                dyads.append(dyad)
                maxCount = subsequence.count
            }
        }
        
        return dyads.filter { $0.subsequence.count == maxCount }
    }
    
    
    // MARK: - Generate Raw Sequences

    /// Generates all possible sequences of indices from `accurateText` that can match characters in `comparedText`.
    ///
    /// This method builds a set of **raw sequences** (each an `OptionalSequence` of `Int?` values)
    /// representing all plausible ways to map each character of `comparedText` to a position in `accurateText`
    /// while preserving the relative order of characters in `accurateText`.
    ///
    /// The algorithm performs a recursive depth‑first search over the characters of `comparedText`.
    /// At each step, for a given character, it considers all positions in `accurateText` where that character occurs (ignoring case),
    /// provided the chosen position is **not less than** any previously chosen position for the same character (to keep the sequence non‑decreasing).
    /// For consecutive identical characters, additional constraints ensure positions are strictly increasing.
    ///
    /// The resulting raw sequences are used later by the LIS (longest increasing subsequence) algorithm
    /// to find the best matching subsequence (the one with the longest increasing chain).
    ///
    /// ## Example
    /// ```
    /// let accurateText = "robot"
    /// let comparedText = "gotob"
    ///
    /// let sequences = TFAlgebra.sequences(
    ///     for: comparedText,
    ///     relyingOn: accurateText
    /// )
    /// /* [[nil, 1, 4, 1, 2],
    ///     [nil, 1, 4, 3, 2],
    ///     [nil, 3, 4, 3, 2]] */
    /// ```
    ///
    ///  In this example:
    /// - `"g"` has no match → `nil`.
    /// - `"o"` appears at indices 1 and 3 in `"robot"` → branches accordingly.
    /// - The sequences are built recursively, respecting order constraints.
    ///
    /// - Important: The generated sequences are **non‑decreasing** for each character’s positions.
    ///   For consecutive equal characters, positions must increase by exactly 1 or be at the last possible position.
    ///   This pruning reduces the number of sequences dramatically.
    /// - Complexity: In the worst case, exponential (number of possible matchings),
    ///   but the constraints keep it manageable for typical typo‑detection scenarios.
    /// - Returns: An array of `OptionalSequence` (each `[Int?]`), where each element represents
    ///   a possible mapping from the indices of `comparedText` to indices in `accurateText` (or `nil` when no match exists).
    @inline(__always)
    static func sequences(for comparedText: String, relyingOn accurateText: String) -> [TFOptionalSequence] {
        
        // First Example
        // –––––––––––––
        //
        // comparedText is "caba", accurateText is "acab"
        //
        // dict is ["a": [0, 2], "c": [1], b: [3]]
        //
        // (c)   (a)   (b)   (a)
        //  1 ──> 0 ──> 3 ──> 0
        //   │           │
        //   │           └──> 2
        //   │
        //   └──> 2 ──> 3 ──> 2
        //
        // rawSequences are [ [1, 0, 3, 0], [1, 0, 3, 2], [1, 2, 3, 2] ]
        //
        //
        // Second Example
        // ––––––––––––––
        //
        // comparedText is "caaaba", accurateText is "baaaac"
        //
        // dict is ["b": [0], "a": [1, 2, 3, 4], "c": [5]]
        //
        // (c)   (a)   (a)   (a)   (b)   (a)
        //  5 ──> 1 ──> 2 ──> 3 ──> 0 ──> 3
        //                           │
        //                           └──> 4
        //
        // rawSequences are [ [5, 1, 2, 3, 0, 3], [5, 1, 2, 3, 0, 4] ]
        //
        
        var rawSequences = [TFOptionalSequence]()
        
        let dict = indices(of: accurateText)
        let comparedText = comparedText.lowercased()
        
        // Buffer that stores, for each character, the list of indices already chosen in the current sequence.
        // Used to enforce non‑decreasing order for the same character across multiple occurrences.
        var buffer = [Character: [Int]]()
        
        func recursion(_ sequence: TFOptionalSequence) -> Void {
            let currentIndex = sequence.count
            // If we've processed all characters of `comparedText`, store the completed sequence
            guard currentIndex < comparedText.count else {
                rawSequences.append(sequence)
                return
            }
            let currentChar = comparedText[currentIndex]
            // Take all possible positions for the current char
            if let sourcePositions = dict[currentChar] {
                for currentPosition in sourcePositions {
                    // Enforce non‑decreasing order: the new position must be >= the last chosen position for this character
                    if let positionsOfCurrentChar = buffer[currentChar], let lastPosition = positionsOfCurrentChar.last {
                        guard currentPosition >= lastPosition else { continue }
                        let previousChar = comparedText[currentIndex - 1]
                        // Special handling for consecutive identical characters: they must either increase by exactly 1 or be at the last available position.
                        if previousChar == currentChar {
                            let biggestPosition = sourcePositions.last!
                            guard (currentPosition == lastPosition + 1) || (lastPosition == biggestPosition) else {
                                continue
                            }
                        }
                        buffer[currentChar]!.append(currentPosition)
                    } else {
                        buffer[currentChar] = [currentPosition]
                    }
                    // Continue building the sequence
                    recursion(sequence + [currentPosition])
                    buffer[currentChar]!.removeLast()
                    // If the next character is the same as the current one, only the first suitable position is needed
                    // because the algorithm will handle consecutive duplicates with strict constraints
                    if let nextChar = comparedText[safe: currentIndex + 1] {
                        guard currentChar != nextChar else { break }
                    }
                }
            } else {
                // No matching character in the reference -> append `nil` and continue.
                recursion(sequence + [nil])
            }
        }
        
        recursion([])
        return rawSequences
    }
    
    
    // MARK: - Count Common Chars
    
    /// Counts the total number of common character occurrences between two texts, ignoring case.
    ///
    /// This method performs a **fast, lightweight pre‑optimisation check** before running the full LIS‑based matching algorithm.
    /// It quickly determines whether there is enough overlap between the user’s text and the reference to make further processing worthwhile.
    ///
    /// For example, if the best possible number of matching characters is already below a configuration threshold,
    /// the algorithm can abort early without expensive computation.
    ///
    /// ## Example
    /// ```
    /// let reference = "Abcde"
    /// let userInput = "aDftb"
    /// let commonCount = TFAlgebra.commonCharactersCount(between: reference, and: userInput) // 3
    /// ```
    /// - Note: Letter case does not affect the result; both texts are lowercased internally.
    /// - Returns: The total number of character occurrences common to both texts (counting duplicates).
    @inline(__always)
    static func commonCharactersCount(between text1: String, and text2: String) -> Int {
        let dict1 = indices(of: text1)
        let dict2 = indices(of: text2)
        var count = 0
        for (char1, positions1) in dict1 {
            if let positions2 = dict2[char1] {
                count += min(positions1.count, positions2.count)
            }
        }
        return count
    }
    
    
    // MARK: - Character Indices
        
    /// Builds a mapping from each character in the text to all indices where it occurs.
    ///
    /// This method is used during the initial matching phase of the algorithm.
    /// By knowing all possible positions of a given character in the reference text,
    /// the algorithm can quickly propose candidate matches for each character in the user’s input.
    ///
    /// ## Example
    /// ```
    /// let text = "Robot"
    /// let dict = TFAlgebra.indices(of: text)
    /// // ["r": [0], "o": [1, 3], "b": [2], "t": [4]]
    /// ```
    /// - Important: The text is **lowercased** before building the index map.
    ///   This makes the matching case‑insensitive at the mathematical level,
    ///   which is appropriate because case handling is applied separately via `TFStrategy`.
    /// - Complexity: O(*n*), where *n* is the length of the text.
    /// - Returns: A dictionary where keys are characters (lowercased) and values are
    ///   arrays of indices where that character appears in the original text (preserving original positions, only the key is lowercased).
    @inline(__always)
    static func indices(of text: String) -> [Character: [Int]] {
        var dict = [Character: [Int]]()
        for (index, char) in text.lowercased().enumerated() {
            dict[char, default: []].append(index)
        }
        return dict
    }
    
    
    // MARK: - Find Common Part
    
    /// Finds a contiguous substring common to both input strings that is longer than half the length of the shorter string.
    ///
    /// This method is part of a performance optimisation for the typo‑detection algorithm.
    /// It assumes that the user’s text is largely similar to the reference text, with only a few mistakes.
    ///
    /// By locating a long common substring early, the algorithm can split both texts into three parts:
    /// - A prefix before the common part,
    /// - The common part itself (guaranteed correct and in order),
    /// - A suffix after the common part.
    ///
    /// This reduces the problem size for the more expensive LIS‑based matching.
    ///
    /// ## Example
    /// ```
    /// let text1 = "ab123"
    /// let text2 = "a123"
    /// let segment = TFAlgebra.commonSegment(between: text1, and: text2)!
    /// // (index1: 2, index2: 1, length: 3)
    /// // Common substring: "123"
    /// ```
    /// - Returns: A tuple `(index1: Int, index2: Int, length: Int)` representing
    ///   the start index in `text1`, start index in `text2`, and the length of the common substring.
    ///   Returns `nil` if no common substring longer than half the shorter string’s length exists.
    @inline(__always)
    static func commonSegment(between text1: String, and text2: String) -> (index1: Int, index2: Int, length: Int)? {
        func roundedHalf(of text: String) -> Int { return Int(round(Double(text.count)) / 2) }
        func rawHalf(of text: String) -> Int { return text.count / 2 }
        let half = min(roundedHalf(of: text1), roundedHalf(of: text2))
        let rawHalf = min(rawHalf(of: text1), rawHalf(of: text2))
        for index1 in 0..<(text1.count - rawHalf) {
            for index2 in 0..<(text2.count - rawHalf) {
                let char1 = text1[index1]
                let char2 = text2[index2]
                if char1 == char2 {
                    let maxOffset1 = text1.count - index1
                    let maxOffset2 = text2.count - index2
                    var count = 1
                    for offset in 1..<min(maxOffset1, maxOffset2) {
                        let char1 = text1[index1 + offset]
                        let char2 = text2[index2 + offset]
                        guard char1 == char2 else { break }
                        count += 1
                    }
                    if count >= half {
                        return (index1, index2, count)
                    }
                }
            }
        }
        return nil
    }
    
    
    // MARK: - Compute LIS
    
    /// Finds the longest increasing subsequence (LIS) of the given sequence of integers.
    ///
    /// This is the core mathematical method on which all other operations are based.
    ///
    /// When multiple longest increasing subsequences exist,
    /// this method returns the **lexicographically smallest** one (the one with the smallest possible values at the earliest positions).
    /// This deterministic tie‑breaking ensures consistent behaviour for the same input.
    ///
    /// ## Example
    /// ```
    /// let sequence = [2, 6, 0, 8, 1, 3, 1]
    /// let subsequence = TFAlgebra.lis(of: sequence) // [0, 1, 3]
    /// ```
    ///
    /// The example sequence has two LISes of length 3:: `[2, 6, 8]` and `[0, 1, 3]`.
    /// This method returns the smallest one, that is `[0, 1, 3]`.
    ///
    /// - Complexity: In the worst case, O(*n* log *n*), where *n* is the length of the sequence.
    /// - Returns: The longest increasing subsequence of the sequence.
    @inline(__always)
    static func lis(of sequence: TFSequence) -> TFSubsequence {
        
        guard sequence.count > 1 else { return sequence }
        
        // The array maintains the best (smallest) increasing subsequence for each possible length,
        // where the last element of each subsequence is as small as possible.
        //
        // Lises are ordered by the last element. The length of next lis is one longer.
        // Therefore, the longest lis is the last one.
        //
        // Example: sequence = [0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7]
        // After processing all elements, `lises` contains:
        // [[0], [0, 1], [0, 1, 3], [0, 1, 3, 7], [0, 2, 6, 9, 11]]
        var lises: [TFSubsequence] = [[sequence.first!]]
        
        for element in sequence[1...] {
            
            var lowerBound = 0, upperBound = lises.count - 1
            var index: Int { lowerBound }
            
            // Binary search for the first subsequence whose last element is >= `element`.
            // This finds the position where `element` can extend or replace.
            while lowerBound < upperBound {
                let middle = lowerBound + (upperBound - lowerBound) / 2
                let middleElement = lises[middle].last!
                if middleElement == element { lowerBound = middle; break }
                if middleElement > element  { upperBound = middle }
                else { lowerBound = middle + 1 }
            }
            
            // 1. If `element` is greater than the last element of the longest subsequence,
            //    we can extend it and append a new subsequence.
            // 2. If `element` is smaller than the first subsequence's last element,
            //    we replace the first subsequence with `[element]`.
            // 3. Otherwise, we replace the subsequence at `index` with a new one that
            //    ends with `element` (by taking the previous subsequence and appending `element`).
            if index == lises.count - 1, element > lises[index].last! {
                lises.append(lises[index] + [element])
            } else if index == 0 {
                lises[0] = [element]
            } else {
                lises[index] = lises[index - 1] + [element]
            }
        }
        
        // The last subsequence in `lises` has the maximum length
        return lises.last!
    }
    
}
