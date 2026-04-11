/// A mathematical pair consisting of a sequence of optional indices and its longest increasing subsequence.
///
/// This type is used internally by the LIS (Longest Increasing Subsequence) algorithm
/// to find the longest sequence of matching characters between the user’s text and the reference.
///
/// The `sequence` array contains integer indices (or `nil` for gaps) representing potential matches between the two texts.
/// The `subsequence` is the **longest increasing subsequence** extracted from that sequence,
/// which corresponds to the longest chain of correctly ordered matching characters.
///
/// ## Example
/// ```
/// let dyad = TFDyad(
///     sequence: [4, 1, nil, 2, 0, 3],
///     subsequence: [1, 2, 3]
/// )
/// ```
internal struct TFDyad: Sendable {
    
    /// The original sequence of optional indices (may contain `nil` values).
    let sequence: TFOptionalSequence
    
    /// The longest increasing subsequence found in `sequence`.
    let subsequence: TFSubsequence
    
    
    // MARK: Init
    
    /// Creates a math dyad from a sequence and its longest increasing subsequence.
    @inline(__always)
    init(
        _ sequence: TFOptionalSequence,
        _ subsequence: TFSubsequence
    ) {
        self.sequence = sequence
        self.subsequence = subsequence
    }
    
}



// MARK: - Behavior Extensions

extension TFDyad {
    
    /// Creates a math dyad with explicitly named arguments.
    /// - Note: It's mainly used for testing.
    @inline(__always)
    init(sequence: TFOptionalSequence, subsequence: TFSubsequence) {
        self.init(sequence, subsequence)
    }
    
    /// Creates an empty math dyad (empty sequence and empty subsequence).
    @inline(__always)
    init() {
        self.init(TFOptionalSequence(), TFSubsequence())
    }
    
}


extension TFDyad: Equatable {
    
    @inline(__always)
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.subsequence == rhs.subsequence,
              lhs.sequence == rhs.sequence
        else { return false }
        return true
    }
    
}
