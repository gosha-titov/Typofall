/// A sequence of annotated characters representing the result of comparing a user's text with a reference.
///
/// `TFText` is the primary container for a diffed text.
/// It holds an ordered array of `TFCharacter` instances,
/// each with its own annotation (`.correct`, `.missing`, `.extra`, `.misspell`, or `.swapped`).
///
/// ## Example
/// ```
/// let text = TFText([
///     .correct("H", hasCorrectCase: false),
///     .correct("e", hasCorrectCase: true),
///     .correct("l", hasCorrectCase: true),
///     .correct("l", hasCorrectCase: true),
///     .missing("o", hasCorrectCase: nil)
/// ])
/// text.isAbsolutelyRight // false
/// text.isCompletelyWrong // false
/// text.countOfTyposAndMistakes // 1
/// text.countOfWrongLetterCases // 1
/// ```
public struct TFText: Equatable, Sendable {
    
    /// The characters containing in the text.
    public var characters: [TFCharacter]
    
    /// Creates a text with the given characters.
    @inline(__always)
    public init<S: Sequence>(_ characters: S) where S.Element == TFCharacter {
        self.characters = Array(characters)
    }
    
}



// MARK: - Behavior Extensions

extension TFText {
    
    /// An empty text with no characters.
    public static var empty: Self {
        return TFText(Array())
    }
    
    
    /// A boolean value indicating that every character is correct and every case is correct (if case matters).
    ///
    /// ## Example
    /// ```
    /// let text = TFText([
    ///     .correct("H", hasCorrectCase: false),
    ///     .correct("i", hasCorrectCase: true)
    /// ])
    /// text.isAbsolutelyRight // false
    /// ```
    public var isAbsolutelyRight: Bool {
        for character in characters {
            guard character.isCorrect else { return false }
            if let caseIsCorrect = character.hasCorrectCase {
                guard caseIsCorrect else { return false }
            }
        }
        return true
    }
    
    /// A boolean value indicating that every character is either extra, missing, or a misspelling.
    ///
    /// ## Example
    /// ```
    /// let text = TFText([
    ///     .swapped("i", position: .left),
    ///     .swapped("h", position: .right)
    /// ])
    /// text.isCompletelyWrong // false
    /// ```
    /// - Note: Swapped characters are **not** considered completely wrong because they are still the correct letters, only out of order.
    public var isCompletelyWrong: Bool {
        for character in characters {
            guard character.isExtra || character.isMissing || character.isMisspell else { return false }
        }
        return true
    }
    
    
    /// The total number of typos and mistakes in the text.
    ///
    /// - Each misspelling, missing, or extra character counts as **one** mistake.
    /// - A swapped pair (two `.swapped` characters) counts as **one** mistake.
    public var countOfTyposAndMistakes: Int {
        var count = 0
        var countOfSwappedChars = 0
        for character in characters {
            switch character.annotation {
            case .extra, .missing, .misspell: count += 1
            case .swapped: countOfSwappedChars += 1
            case .correct: break
            }
        }
        return count + countOfSwappedChars / 2
    }
    
    /// The number of characters whose letter case is explicitly marked as incorrect.
    public var countOfWrongLetterCases: Int {
        var count = 0
        for character in characters {
            if let letterCaseIsCorrect = character.hasCorrectCase, letterCaseIsCorrect == false {
                count += 1
            }
        }
        return count
    }
    
    
    // MARK: Methods
    
    /// Returns a capitalized version of the text.
    @inline(__always)
    internal func capitalized() -> Self {
        guard let first = first?.uppercased() else { return .empty }
        guard count > 1 else { return [first] }
        return TFText([first] + self[1...].map { $0.lowercased() })
    }
  
    /// Returns an uppercased version of the text.
    @inline(__always)
    internal func uppercased() -> Self {
        return TFText(map { $0.uppercased() })
    }
    
    /// Returns a lowercased version of the text.
    @inline(__always)
    internal func lowercased() -> Self {
        return TFText(map { $0.lowercased() })
    }
    
    
    /// Inserts a new character at the specified position.
    @inline(__always)
    internal mutating func insert(_ character: TFCharacter, at index: Index) {
        characters.insert(character, at: index)
    }
    
    /// Removes the character at the specified position.
    @inline(__always)
    internal mutating func remove(at index: Index) {
        characters.remove(at: index)
    }
    
    
    // MARK: Init
    
    /// Creates a text from a plain string, assigning the same character type to every character.
    ///
    /// ## Example
    /// ```
    /// let text = TFText("Hello", annotation: .correct)
    /// /*[.correct("H"),
    ///    .correct("e"),
    ///    .correct("l"),
    ///    .correct("l"),
    ///    .correct("o")
    /// ]*/
    /// ```
    @inline(__always)
    public init(_ string: String, annotation: TFAnnotation) {
        let text = string.map { TFCharacter($0, annotation: annotation) }
        self.init(text)
    }
    
    /// Creates a text from a plain string, assigning the same character type to every character.
    @inline(__always)
    internal init(_ string: String, _ annotation: TFAnnotation, _ transformation: TFTransformation?) {
        let text = TFText(string, annotation: annotation)
        self = if let transformation { text.tranfromed(to: transformation) } else { text }
    }
    
    /// Creates an empty text with no characters.
    @inline(__always)
    public init() {
        self = .empty
    }
    
}


extension TFText: Collection {
    
    public typealias Element = TFCharacter
    public typealias Index = Array<TFCharacter>.Index
    
    @inline(__always)
    public var startIndex: Index { characters.startIndex }
    
    @inline(__always)
    public var endIndex: Index  { characters.endIndex }
    
    @inline(__always)
    public func index(after index: Index) -> Index {
        return characters.index(after: index)
    }
    
    @inline(__always)
    public subscript(index: Index) -> Element {
        get { return characters[index] }
        set { characters[index] = newValue }
    }
    
}


extension TFText: BidirectionalCollection {
    
    @inline(__always)
    public func index(before index: Index) -> Index {
        return characters.index(before: index)
    }
    
}


extension TFText: ExpressibleByArrayLiteral {
    
    @inline(__always)
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
    
}
