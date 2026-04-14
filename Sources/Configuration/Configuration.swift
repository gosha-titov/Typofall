/// A configuration that defines the rules for evaluating a user’s text against a reference.
///
/// The configuration controls:
/// - The minimum number (or proportion) of characters that must be **correct**.
/// - The maximum number (or proportion) of characters that may be **wrong**.
/// - Text normalizations to apply before comparison (e.g., trimming, collapsing spaces).
/// - How letter case is handled during comparison (case‑sensitive or case‑insensitive, with optional normalisation).
///
/// ## Example
/// ```
/// let configuration = TFConfiguration(
///     requiredQuantityOfCorrectCharacters: .high, // at least 75% correct
///     acceptableQuantityOfWrongCharacters: .three, // up to 3 wrong characters allowed
///     textNormalizations: [.trimmingWhitespace, .collapsingWhitespace],
///     textCaseStrategy: .insensitive(.transformed(to: .lowercased))
/// )
/// ```
public struct TFConfiguration: Equatable, Sendable {
    
    /// The minimum acceptable quantity of correct characters.
    ///
    /// The evaluation **fails** if the actual number of correct characters is **less than** this quantity.
    /// If this value is `.none`, this requirement is ignored.
    /// - Note: The required count of correct chars is counted relative to the accurate text.
    public let requiredQuantityOfCorrectCharacters: TFQuantity
    
    /// The maximum acceptable quantity of wrong characters.
    ///
    /// The evaluation **fails** if the actual number of wrong characters is **greater than** this quantity.
    /// If this value is `.none`, this requirement is ignored.
    /// - Note: The acceptable count of wrong chars is counted relative to the compared text.
    public let acceptableQuantityOfWrongCharacters: TFQuantity
    
    /// The normalisations applied to **both** the user text and the reference text before comparison.
    ///
    /// Use this to eliminate irrelevant whitespace differences, such as leading/trailing spaces or multiple consecutive spaces.
    /// These normalisations are applied **before** case handling and character‑by‑character comparison.
    public let textNormalizations: TFNormalizations
    
    /// The strategy for handling letter case during evaluation.
    ///
    /// - `.sensitive`: Case differences count as mistakes. The original case is preserved.
    /// - `.insensitive(.unchanged)`: Case differences are ignored, but the text is **not** transformed.
    /// - `.insensitive(.normalized(...))`: Both texts are transformed (e.g., lowercased) before comparison;
    ///   case differences do **not** count as mistakes, and the transformed versions are used for counting correct/wrong characters.
    public let textCaseStrategy: TFStrategy
    
    
    // MARK: Inits
    
    /// Creates a configuration instance with the specified parameters.
    public init(
        requiredQuantityOfCorrectCharacters: TFQuantity = TFQuantity(),
        acceptableQuantityOfWrongCharacters: TFQuantity = TFQuantity(),
        textNormalizations: TFNormalizations = TFNormalizations(),
        textCaseStrategy: TFStrategy = TFStrategy()
    ) {
        self.requiredQuantityOfCorrectCharacters = requiredQuantityOfCorrectCharacters
        self.acceptableQuantityOfWrongCharacters = acceptableQuantityOfWrongCharacters
        self.textNormalizations = textNormalizations
        self.textCaseStrategy = textCaseStrategy
    }
    
}

