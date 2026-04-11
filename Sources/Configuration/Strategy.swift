/// A strategy for handling letter case when comparing a user’s text with a reference.
///
/// Use this type to control whether case differences are treated as mistakes, and if they are ignored,
/// whether the text should be transformed before comparison.
///
/// The strategy can be either:
/// - `.sensitive(_)` – case matters; `"Hello"` and `"hello"` are different.
/// - `.insensitive(_)` – case differences are ignored, with optional transformation.
public enum TFStrategy: Equatable, Sendable {
    
    /// Performs a case‑sensitive comparison.
    case sensitive(Sensitivity)
    
    /// Performs a case‑insensitive comparison, optionally transforming the text first.
    case insensitive(Insensitivity)
    
}


extension TFStrategy {
    
    /// A type of case‑sensitive behaviour to apply.
    public enum Sensitivity: String, Equatable, Sendable {
    
        /// Indicates to use comparison **without** any case-transformation.
        ///
        /// The user’s text and the reference text are compared exactly as they are.
        /// A difference in letter case (e.g., `"Great Britain"` vs `"great britain"`) is considered a mistake.
        ///
        /// Use this strategy when case is semantically important, such as with proper nouns, names, countries, or titles.
        case compared
        
    }
    
    
    /// A type of case‑insensitive behaviour to apply.
    public enum Insensitivity: Equatable, Sendable {
        
        /// Transforms both the user’s text and the reference text using the specified transformation before comparing them.
        ///
        /// It's used when letter case is not important and you want to compare the semantic content regardless of capitalization.
        /// Both user and correct answers are transformed using the same transformation before text-comparison.
        /// For example, when normalizing to lowercase, "Giraffe" and "giraffe" both become "giraffe" and then are compared.
        case transformed(to: TFTransformation)
        
        /// Indicates to use comparison **without** any case-transformation.
        ///
        /// It's used when you want to preserve the original case of the user's answer without modifying it,
        /// while still evaluating the result in a case-insensitive manner.
        /// The user's input case remains unchanged, but the comparison ignores case differences.
        case unchanged
        
    }
    
}



// MARK: - Behavior Extensions

extension TFStrategy {
    
    /// A boolean value indicating whether the strategy performs case‑sensitive comparison.
    public var isSensitive: Bool {
        return if case .sensitive = self { true } else { false }
    }
    
    /// A boolean value indicating whether the strategy performs case‑insensitive comparison.
    public var isInsensitive: Bool {
        return if case .insensitive = self { true } else { false }
    }
    
    
    /// A transformation associated with the strategy.
    internal var transformation: TFTransformation? {
        return switch self {
        case .insensitive(let insensitivity):
            switch insensitivity {
            case .transformed(let transformation): transformation
            case .unchanged: nil
            }
        case .sensitive: nil
        }
    }
    
    /// Creates a default case‑insensitive strategy.
    public init() {
        self = .insensitive(.unchanged)
    }
    
}



// MARK: - Syntactic Sugar

extension TFStrategy.Insensitivity {
    
    /// Creates an insensitive strategy with the `.transformed(to: .capitalized)` value.
    public static var capitalized: Self {
        return .transformed(to: .capitalized)
    }
    
    /// Creates an insensitive strategy with the `.transformed(to: .uppercased)` value.
    public static var uppercased: Self {
        return .transformed(to: .uppercased)
    }
    
    /// Creates an insensitive strategy with the `.transformed(to: .lowercased)` value.
    public static var lowercased: Self {
        return .transformed(to: .lowercased)
    }
    
}



// MARK: - Encodable & Decodable

extension TFStrategy: Codable {

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .sensitive(let strategy):
            switch strategy {
            case .compared:
                try container.encode(.compared)
            }
        case .insensitive(let strategy):
            switch strategy {
            case .transformed(let transformation):
                switch transformation {
                case .capitalized:
                    try container.encode(.capitalized)
                case .uppercased:
                    try container.encode(.uppercased)
                case .lowercased:
                    try container.encode(.lowercased)
                }
            case .unchanged:
                try container.encode(.unchanged)
            }
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = switch string {
        case .compared: .sensitive(.compared)
        case .capitalized: .insensitive(.capitalized)
        case .uppercased: .insensitive(.uppercased)
        case .lowercased: .insensitive(.lowercased)
        case .unchanged: .insensitive(.unchanged)
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: container.codingPath,
                debugDescription: "Invalid value"
            ))
        }
    }
    
}


private extension String {
    static let capitalized = "capitalized"
    static let uppercased = "uppercased"
    static let lowercased = "lowercased"
    static let unchanged = "unchanged"
    static let compared = "compared"
}
