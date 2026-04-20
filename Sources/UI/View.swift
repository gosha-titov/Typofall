#if canImport(UIKit)
import UIKit

//
// Implementation notes
// ====================
//
// UIKit aligns the text of a label to the center based on the length of the non‑whitespace content.
// That is, it measures the text up to the last non‑space character, ignoring any trailing spaces.
//
// For example, how it should be: [  _text__  ]
//              how it really is: [   _text__ ]
//
// To work around this, we align the label itself (its frame) rather than relying on its text alignment.
// This ensures the entire label content, including trailing spaces, is correctly positioned.
//                                | [_text__] |
//

/// A scrollable view that displays a diffed text with visual annotations for typos and mistakes.
///
/// `TFView` presents a `TFText` object by highlighting different types of character differences:
/// - Correct characters appear in a standard color.
/// - Missing characters (present in the ideal text but absent in the user's input) appear in a dimmed color.
/// - Extra characters (present in the user's input but not in the ideal text) appear with a strikethrough and a red color.
/// - Misspelled characters appear with a warning color and show the correct character above.
/// - Swapped character pairs are underlined with arrows indicating the swap direction.
///
/// The view uses a monospaced font and displays three vertically stacked labels:
/// - An upper label that shows the correct character for misspellings.
/// - A main label that shows the actual characters with appropriate styling.
/// - A lower label that shows arrows for swapped characters.
@available(iOS 15.0, *)
open class TFView: UIScrollView {
    
    /// The annotated text that is currently being displayed.
    public var text = TFText() {
        didSet { updateDisplay() }
    }
    
    
    /// The color used when the entire text is completely correct (no mistakes of any kind).
    public var completelyCorrectColor = UIColor.systemGreen {
        didSet { updateDisplay() }
    }
    
    /// The color used for characters that are marked as `.correct`.
    public var correctColor = UIColor.label {
        didSet { updateDisplay() }
    }
    
    /// The color used to highlight swapped characters, the arrows shown below them, and incorrect letter cases.
    public var warningColor = UIColor.systemYellow {
        didSet { updateDisplay() }
    }
    
    /// The color used for extra characters and strikethrough lines.
    public var wrongColor = UIColor.systemRed {
        didSet { updateDisplay() }
    }
    
    /// The color used for missing characters (those present in the ideal text but absent in the input).
    public var missingColor = UIColor.systemGray3 {
        didSet { updateDisplay() }
    }
    
    
    /// The font size (in points) for the monospaced font used to display the text.
    public var fontSize = CGFloat(20) {
        didSet { updateDisplay() }
    }
    
    /// The font weight for the monospaced font used to display the text.
    public var fontWeight = UIFont.Weight.medium {
        didSet { updateDisplay() }
    }
    
    
    /// The boolean value that determines whether the text is centered horizontally when its total width fits inside the scroll view's bounds.
    public var alignsTextToCenterIfFits = true {
        didSet {
            needsLayout = true
            setNeedsLayout()
        }
    }
    
    /// The additional inset distances for the content view relative to the scroll view's bounds.
    public var padding = UIEdgeInsets() {
        didSet {
            needsLayout = true
            setNeedsLayout()
        }
    }
    
    /// The vertical distance between adjacent labels.
    public var spacing = CGFloat()  {
        didSet {
            needsLayout = true
            setNeedsLayout()
        }
    }
    
    
    /// The label that displays the correct character above a misspelled one.
    private let upperLabel = UILabel()
    
    /// The main label that displays the actual character (with its annotation styling).
    private let mainLabel = UILabel()
    
    /// The label that displays arrows (e.g., "↔︎") below swapped characters.
    private let lowerLabel = UILabel()
    
    
    /// The boolean value indicating whether the layout needs to be recalculated.
    private var needsLayout = true
    
    /// The previously recorded bounds size, used to detect size changes.
    private var previousSize = CGSize()
    
    
    // MARK: Methods
    
    /// Triggers a full display update from the current `text`.
    private func updateDisplay() {
        render(text)
    }
    
    /// Renders the given annotated text into the three labels.
    private func render(_ text: TFText) {
        guard text.isEmpty == false else {
            upperLabel.attributedText = nil
            mainLabel.attributedText = nil
            lowerLabel.attributedText = nil
            return
        }
        let upperString = NSMutableAttributedString()
        let centerString = NSMutableAttributedString()
        let lowerString = NSMutableAttributedString()
        let space = NSAttributedString(" ").applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
        
        if text.isAbsolutelyRight {
            let correctText = NSAttributedString(string: String(text.characters.map(\.value)))
                .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
                .applying(foregroundColor: completelyCorrectColor)
            upperString.append(space)
            centerString.append(correctText)
            lowerString.append(space)
        } else {
            for char in text {
                let currentChar = NSAttributedString(char).applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
                switch char.annotation {
                case .correct:
                    var correctChar = currentChar.applying(foregroundColor: correctColor)
                    if let letterCaseIsCorrect = char.hasCorrectCase, letterCaseIsCorrect == false {
                        correctChar = correctChar.applying(underline: .single, withColor: warningColor)
                    }
                    upperString.append(space)
                    centerString.append(correctChar)
                    lowerString.append(space)
                case .missing:
                    let missingChar: NSAttributedString
                    if char.value == " " {
                        missingChar = currentChar
                            .applying(backgroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        missingChar = currentChar
                            .applying(foregroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    }
                    upperString.append(space)
                    centerString.append(missingChar)
                    lowerString.append(space)
                case .extra:
                    let extraChar = currentChar
                        .applying(foregroundColor: correctColor)
                        .applying(strikethrough: 1, withColor: wrongColor)
                    upperString.append(space)
                    centerString.append(extraChar)
                    lowerString.append(space)
                case .misspell(let correctCharacter):
                    let misspellChar: NSAttributedString
                    let correctChar: NSAttributedString
                    if char.value == " " {
                        misspellChar = currentChar
                            .applying(backgroundColor: missingColor)
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        misspellChar = currentChar
                            .applying(foregroundColor: correctColor)
                            .applying(strikethrough: 1, withColor: wrongColor)
                    }
                    if correctCharacter == " " {
                        correctChar = currentChar
                            .applying(underline: .single, withColor: wrongColor)
                    } else {
                        correctChar = NSAttributedString(string: String(correctCharacter))
                            .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
                            .applying(foregroundColor: wrongColor)
                    }
                    upperString.append(correctChar)
                    centerString.append(misspellChar)
                    lowerString.append(space)
                case .swapped(let position):
                    let arrowSymbol = switch position {
                    case .left:  "←"
                    case .right: "→"
                    }
                    let swappedChar: NSAttributedString
                    if char.value == " " {
                        swappedChar = currentChar
                            .applying(underline: .single, withColor: warningColor)
                    } else {
                        swappedChar = currentChar
                            .applying(foregroundColor: warningColor)
                    }
                    let arrow = NSAttributedString(string: String(arrowSymbol))
                        .applying(font: .monospacedSystemFont(ofSize: fontSize, weight: fontWeight))
                        .applying(foregroundColor: warningColor)
                    upperString.append(space)
                    centerString.append(swappedChar)
                    lowerString.append(arrow)
                }
            }
        }
        upperLabel.attributedText = upperString
        mainLabel .attributedText = centerString
        lowerLabel.attributedText = lowerString
        upperLabel.invalidateIntrinsicContentSize()
        mainLabel .invalidateIntrinsicContentSize()
        lowerLabel.invalidateIntrinsicContentSize()
        needsLayout = true
        setNeedsLayout()
    }
    
    /// Lays out subviews.
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Avoiding expensive layout work during scrolling
        if needsLayout || previousSize != bounds.size {
            layout()
            needsLayout = false
        }
        previousSize = bounds.size
    }
    
    /// Returns a size that best fits within a proposed container size.
    open override func sizeThatFits(_ proposedSize: CGSize) -> CGSize {
        return fittingSize(within: proposedSize)
    }
    
    
    // MARK: Init
    
    /// Creates a new text view with an optional configuration closure.
    /// - Parameters:
    ///   - frame: The frame rectangle for the view, measured in points.
    ///   - initialize: An optional closure that gives you a chance to configure the view after it has been created.
    public init(frame: CGRect = .zero, initialize: ((TFView) -> Void)? = nil) {
        super.init(frame: frame)
        addSubview(upperLabel)
        addSubview(mainLabel)
        addSubview(lowerLabel)
        initialize?(self)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



// MARK: - Layout

@available(iOS 15.0, *)
extension TFView {
    
    /// Positions the view's subviews.
    private func layout() {
        let boundingRect = bounds.inset(by: padding)
        let textSize = mainLabel.intrinsicContentSize
        let (boundingWidth, boundingHeight) = (boundingRect.width, boundingRect.height)
        let (intrinsicWidth, textHeight) = (textSize.width, textSize.height)
        var xOffset = CGFloat()
        if alignsTextToCenterIfFits {
            if boundingWidth > intrinsicWidth {
                xOffset = (boundingWidth - intrinsicWidth) / 2
            }
        }
        var yOffset = CGFloat()
        let intrinsicHeight = textHeight * 3 + spacing * 2
        if boundingHeight > intrinsicHeight {
            yOffset = (boundingHeight - intrinsicHeight) / 2
        }
        let textX = boundingRect.minX + xOffset
        upperLabel.frame = CGRect(
            origin: CGPoint(
                x: textX,
                y: boundingRect.minY + yOffset
            ),
            size: textSize
        )
        mainLabel.frame = CGRect(
            origin: CGPoint(
                x: textX,
                y: boundingRect.minY + (boundingHeight - textHeight) / 2
            ),
            size: textSize
        )
        lowerLabel.frame = CGRect(
            origin: CGPoint(
                x: textX,
                y: boundingRect.maxY - yOffset - textHeight
            ),
            size: textSize
        )
        contentSize = CGSize(
            width: boundingWidth > intrinsicWidth ? bounds.width : intrinsicWidth + padding.horizontal,
            height: bounds.height
        )
    }
    
    /// Calculates the optimal size for displaying the view's content within proposed constraints.
    private func fittingSize(within proposedSize: CGSize) -> CGSize {
        let textSize = mainLabel.intrinsicContentSize // sizes of each label are the same
        let (intrinsicWidth, textHeight) = (textSize.width, textSize.height)
        let proposedWidth = proposedSize.width
        let intrinsicHeight = textHeight * 3 + spacing * 2
        if proposedWidth > 0, proposedWidth.isFinite, proposedWidth > (padding.left + padding.right) {
            return CGSize(width: proposedWidth, height: intrinsicHeight + padding.vertical)
        } else {
            return CGSize(width: intrinsicWidth + padding.horizontal, height: intrinsicHeight + padding.vertical)
        }
    }
    
}

#endif
