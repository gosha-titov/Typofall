/// A character paired with its diff annotation and optional case‑correctness information.
///
/// `TFCharacter` is the core unit of a diffed text.
/// Each instance represents a single character along with metadata that describes how it relates to the reference (original) text.
///
/// ## Example
/// ```
/// let character = TFCharacter.missing("a")
/// character.value // Character("a")
/// character.annotation // .missing
/// ```
public struct TFCharacter: Equatable, Sendable {
    
    /// The underlying character value.
    public let value: Character
    
    /// The annotation describing the character's relation to the original text.
    public internal(set) var annotation: TFAnnotation
    
    /// A boolean value indicating whether the letter case of the character matches the original.
    /// - Note: `Nil` value means that the letter case does not matter.
    /// This is when the text is normalized, for example, to its lowercase version.
    public internal(set) var hasCorrectCase: Bool?
    
    
    // MARK: Init
    
    /// Creates a diff character instance with the specified parameters.
    public init(_ value: Character, annotation: TFAnnotation, hasCorrectCase: Bool? = nil) {
        self.hasCorrectCase = hasCorrectCase
        self.annotation = annotation
        self.value = value
    }
    
}



// MARK: - Behavior Extensions

extension TFCharacter {
    
    /// The boolean value indicating whether the annotation of the character is `correct`.
    public var isCorrect: Bool { annotation.isCorrect }
    
    /// The boolean value indicating whether the annotation of the character is `missing`.
    public var isMissing: Bool { annotation.isMissing }
    
    /// The boolean value indicating whether the annotation of the character is `extra`.
    public var isExtra: Bool { annotation.isExtra }
    
    /// The boolean value indicating whether the annotation of the character is `misspell`.
    public var isMisspell: Bool { annotation.isMisspell }
    
    /// The boolean value indicating whether the annotation of the character is `swapped`.
    public var isSwapped: Bool { annotation.isSwapped }
    
    
    // MARK: Methods
    
    /// Returns an uppercase version of the character.
    ///
    /// ## Example
    /// ```
    /// let character = TFCharacter.misspell("a", correct: "b")
    /// character.uppercased()  // .misspell("A", correct: "B")
    /// ```
    /// - Note: The uppercase character has no boolean indicator of its letter case correctness.
    internal func uppercased() -> Self {
        let newValue = value.uppercased().first
        let newAnnotation: TFAnnotation
        switch self.annotation {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.uppercased().first
            newAnnotation = .misspell(newCorrectChar ?? correctChar)
        default:
            newAnnotation = annotation
        }
        return TFCharacter(newValue ?? value, annotation: newAnnotation, hasCorrectCase: nil)
    }
    
    /// Returns a lowercase version of the character.
    ///
    /// ## Example
    /// ```
    /// let character = TFCharacter.misspell("A", correct: "B")
    /// character.lowercased()  // .misspell("a", correct: "b")
    /// ```
    /// - Note: The lowercase character has no boolean indicator of its letter case correctness.
    internal func lowercased() -> Self {
        let newValue = value.lowercased().first
        let newAnnotation: TFAnnotation
        switch self.annotation {
        case .misspell(let correctChar):
            let newCorrectChar = correctChar.lowercased().first
            newAnnotation = .misspell(newCorrectChar ?? correctChar)
        default:
            newAnnotation = annotation
        }
        return TFCharacter(newValue ?? value, annotation: newAnnotation, hasCorrectCase: nil)
    }
    
}



// MARK: - Syntactic Sugar

extension TFCharacter {
    
    /// Creates a character with the `.correct` annotation.
    public static func correct(_ value: Character, hasCorrectCase: Bool? = nil) -> Self {
        return TFCharacter(value, annotation: .correct, hasCorrectCase: hasCorrectCase)
    }
    
    /// Creates a character with the `.missing` annotation.
    public static func missing(_ value: Character, hasCorrectCase: Bool? = nil) -> Self {
        return TFCharacter(value, annotation: .missing, hasCorrectCase: hasCorrectCase)
    }
    
    /// Creates a character with the `.extra` annotation.
    public static func extra(_ value: Character, hasCorrectCase: Bool? = nil) -> Self {
        return TFCharacter(value, annotation: .extra, hasCorrectCase: hasCorrectCase)
    }
    
    /// Creates a character with the `.misspell` annotation.
    public static func misspell(_ value: Character, correct correctValue: Character, hasCorrectCase: Bool? = nil) -> Self {
        return TFCharacter(value, annotation: .misspell(correctValue), hasCorrectCase: hasCorrectCase)
    }
    
    /// Creates a character with the `.swapped` annotation.
    public static func swapped(_ value: Character, position: TFAnnotation.SwappedPosition, hasCorrectCase: Bool? = nil) -> Self {
        return TFCharacter(value, annotation: .swapped(position: position), hasCorrectCase: hasCorrectCase)
    }
    
}
