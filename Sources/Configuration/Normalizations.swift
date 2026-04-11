import Foundation

/// A set of normalisations to apply to both user text and reference text before comparison.
///
/// Use this to clean up whitespace differences that should not count as typos.
/// For example, trimming leading/trailing spaces or collapsing multiple spaces into one.
public struct TFNormalizations: OptionSet, Sendable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
}



// MARK: - Options

extension TFNormalizations {
    
    /// Removes whitespace characters (spaces, tabs, newlines) from the beginning and end of the text.
    public static let trimmingWhitespace = Self(rawValue: 1 << 0)
    
    /// Replaces any sequence of whitespace characters (including tabs and newlines) with a single space.
    public static let collapsingWhitespace = Self(rawValue: 1 << 1)
    
}



// MARK: - Compatibility Extensions

extension String {
    
    /// Applies a set of whitespace normalizations to the string in sequence.
    internal func normalized(with normalizations: TFNormalizations) -> String {
        var result = self
        if normalizations.contains(.trimmingWhitespace) {
            result = result.trimmingWhitespace()
        }
        if normalizations.contains(.collapsingWhitespace) {
            result = result.collapsingWhitespace()
        }
        return result
    }
    
    /// Returns a new string with whitespaces removed from both ends.
    ///
    /// ## Example
    /// ```
    /// let string = " hello \n"
    /// string.trimmed() // "hello"
    /// ```
    @inline(__always)
    private func trimmingWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Returns a new string with consecutive whitespaces replaced with a single space.
    ///
    /// ## Example
    /// ```
    /// let string = "Hello, \n  world!"
    /// string.collapsingWhitespace() // "Hello, world!"
    /// ```
    @inline(__always)
    private func collapsingWhitespace() -> String {
        let maybeRegex = try? NSRegularExpression(pattern: "\\s+", options: .caseInsensitive)
        guard let regex = maybeRegex else { return self }
        let range = NSRange(startIndex..., in: self)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " ")
    }
    
}
