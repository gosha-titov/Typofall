 /// An annotation that describes how a character relates to the reference (original) text.
///
/// The annotation is used to highlight differences in a user‑friendly diff view.
public enum TFAnnotation: Equatable, Sendable {
    
    /// The annotation indicating that the character is exactly the same as the original one.
    case correct
    
    /// The annotation indicating that the character is required by the original text but was omitted by the user.
    case missing
    
    /// The annotation indicating that the character was typed by the user but has no counterpart in the original text.
    case extra
    
    /// The annotation indicating that the character is a misspelling and should have been the provided correct character.
    /// - Parameter correct: The character that was expected at this position.
    case misspell(_ correct: Character)
    
    /// The annotation indicating that the character participates in a swap with its neighbour.
    /// - Note: Swaps are always detected in pairs. Use the associated `SwappedPosition`
    ///   to know whether this character is the left or right part of the swapped pair.
    case swapped(position: SwappedPosition)
    
}


extension TFAnnotation {
    
    /// A type that specifies whether a swapped character appears before or after its correct position.
    public enum SwappedPosition: Equatable, Sendable {
        
        /// The position of a character that is to the left of its correct position.
        case left
        
        /// The position of a character that is to the right of its correct position.
        case right
    }
    
}



// MARK: - Behavior Extensions

extension TFAnnotation {
    
    /// The boolean value indicating whether the annotation is `correct`.
    public var isCorrect: Bool { self == .correct }
    
    /// The boolean value indicating whether the annotation is `missing`.
    public var isMissing: Bool { self == .missing }
    
    /// The boolean value indicating whether the annotation is `extra`.
    public var isExtra: Bool { self == .extra }
    
    /// The boolean value indicating whether the annotation is `misspell`.
    public var isMisspell: Bool {
        return if case .misspell = self { true } else { false }
    }
    
    /// The boolean value indicating whether the annotation is `swapped`.
    public var isSwapped: Bool {
        return if case .swapped = self { true } else { false }
    }
    
    
    /// Creates an annotation with the `.extra` value.
    public init() { self = .extra }
    
}
