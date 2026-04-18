/// A quantity that can be expressed either as a fixed number of characters or as a proportion of a text’s length.
///
/// `TFQuantity` is used in `TFConfiguration` to specify thresholds like
/// “at least 75% of characters must be correct” (using a coefficient) or
/// “no more than 3 wrong characters are allowed” (using a number).
///
/// The special cases `.none` and `.zero` have distinct meanings:
/// - `.none` means “no requirement” – the corresponding check is skipped.
/// - `.zero` means “zero characters” (a fixed number of `0`).
public enum TFQuantity: Equatable, Sendable {
    
    /// The default quantity associated with zero chars.
    case zero
    
    /// The case indicating that there is no quantity.
    case none
    
    
    /// The default quantity associated with 100% of chars, that is, the coefficient is `1.0`.
    case all
    
    /// The default quantity associated with 75% of chars, that is, the coefficient is `0.75`.
    case high
    
    /// The default quantity associated with 50% of chars, that is, the coefficient is `0.5`.
    case half
    
    /// The default quantity associated with 25% of chars, that is, the coefficient is `0.25`.
    case low
    
    /// The quantity associated with a certain percentage of chars.
    /// - Important: Must be between `0.0` and `1.0`.
    case coefficient(Double)
    
    
    /// The default quantity associated with 1 char.
    case one
    
    /// The default quantity associated with 2 chars.
    case two
    
    /// The default quantity associated with 3 chars.
    case three
    
    /// The quantity associated with a certain number of chars.
    /// - Important: Must be non‑negative.
    case number(Int)
    
}



// MARK: - Behavior Extensions

extension TFQuantity {
    
    /// The coefficient (proportion) represented by this quantity, if applicable.
    @inline(__always)
    private var coefficient: Double? {
        return switch self {
        case .coefficient(let value): value.clamped(to: 0...1.0)
        case .all:  1.0
        case .high: 0.75
        case .half: 0.5
        case .low:  0.25
        default: nil
        }
    }
    
    /// The fixed integer number represented by this quantity, if applicable.
    @inline(__always)
    private var number: Int? {
        return switch self {
        case .number(let value): value.clamped(to: 0...)
        case .zero:  0
        case .one:   1
        case .two:   2
        case .three: 3
        default: nil
        }
    }
    
    
    /// Returns the effective integer count for a given total text length.
    internal func count(for length: Int, clamped: Bool = false) -> Int? {
        if let coefficient {
            if self == .all { return length }
            return Int((Double(length) * coefficient).rounded())
        }
        if let number {
            if clamped { return number.clamped(to: 0...length) }
            return number
        }
        return nil
    }
    
    
    /// Creates a quantity with the `.none` value.
    public init() {
        self = .none
    }
    
}

