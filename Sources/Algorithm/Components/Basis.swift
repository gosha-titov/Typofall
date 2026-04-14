/// A mathematical basis derived from two texts (reference and user input).
///
/// This type represents the final result of the `TFAlgebra` calculations.
/// It captures:
/// - The reference text as a sequence of indices (`sourceSequence`).
/// - The user text mapped to possible reference indices (`sequence`).
/// - The longest increasing subsequence (`subsequence`) of matching characters in correct order.
/// - The indices from the reference that were not matched (`missingElements`).
///
/// ## Example
/// ```
/// let idealText = "Hello"
/// let inputText = "hola"
///
/// let basis = TFAlgebra.basis(
///     diffing: inputText,
///     against: idealText
/// )
///
/// basis.sourceSequence  // [0, 1, 2, 3, 4]
/// basis.sequence        // [0, 4, 2, nil ]
/// basis.subsequence     // [0,    2      ]
/// basis.missingElements // [   1,    3, 4]
/// ```
/// - Note: The value of each element of the sequence is the index of the associated char in the source text.
internal struct TFBasis: Sendable {
    
    /// The complete sequence of indices representing all characters in the reference text.
    ///
    /// For a reference text of length `n`, this is `[0, 1, 2, ..., n-1]`.
    /// Used as the source of truth for ordering.
    let sourceSequence: TFSequence
    
    /// The sequence of optional indices generated from the user text,
    /// each pointing to a potential matching character in the reference text.
    let sequence: TFOptionalSequence
    
    /// The longest increasing subsequence (LIS) extracted from `sequence`.
    ///
    /// This represents the longest chain of user characters that match reference characters in the correct relative order.
    /// Elements of the subsequence are indices into `sourceSequence`.
    let subsequence: TFSubsequence
    
    /// Indices from `sourceSequence` that are **not** present in `subsequence`.
    let missingElements: TFSequence
    
    
    // MARK: Init
    
    /// Creates a math basis with the given parameters.
    @inline(__always)
    init(
        _ sourceSequence: TFSequence,
        _ sequence: TFOptionalSequence,
        _ subsequence: TFSubsequence
    ) {
        self.sourceSequence = sourceSequence
        self.sequence = sequence
        self.subsequence = subsequence
        missingElements = sourceSequence.filter { !subsequence.contains($0) }
    }
    
}



// MARK: - Behavior Extensions

extension TFBasis {
    
    /// Creates a math basis with explicitly named arguments.
    /// - Note: It's mainly used for testing.
    @inline(__always)
    init(
        sourceSequence: TFSequence,
        sequence: TFOptionalSequence,
        subsequence: TFSubsequence
    ) {
        self.init(sourceSequence, sequence, subsequence)
    }
    
    /// Creates an empty math basis.
    /// - Note: It's mainly used for testing.
    @inline(__always)
    init() {
        self.init(TFSequence(), TFOptionalSequence(), TFSubsequence())
    }
    
}


extension TFBasis: Equatable {
    
    @inline(__always)
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.subsequence == rhs.subsequence,
              lhs.sequence == rhs.sequence,
              lhs.sourceSequence == rhs.sourceSequence
        else { return false }
        return true
    }
    
}
