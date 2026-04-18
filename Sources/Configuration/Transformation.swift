/// A type that defines how text should be tranformed for case‑insensitive comparison.
public enum TFTransformation: Equatable, Sendable {
    
    /// Capitalises the first letter of each word and lowercases all other letters (e.g., "Hello World").
    case capitalized
    
    /// Transforms every letter to uppercase (e.g., "HELLO WORLD").
    case uppercased
    
    /// Transforms every letter to lowercase (e.g., "hello world").
    case lowercased
    
}



// MARK: - Compatibility Extensions

extension TFText {
    
    /// Returns a new text with the specified case transformation applied to every character.
    ///
    /// ## Example
    /// ```
    /// let text = TFText("Hello World", annotation: .correct)
    /// text.tranfromed(to: .lowercased)
    /// // TFText("hello world", annotation: .correct)
    /// ```
    @inline(__always)
    internal func tranfromed(to tranformation: TFTransformation) -> Self {
        return switch tranformation {
        case .capitalized: capitalized()
        case .uppercased: uppercased()
        case .lowercased: lowercased()
        }
    }
    
}
