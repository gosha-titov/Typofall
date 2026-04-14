#if canImport(UIKit)

import UIKit

internal extension NSAttributedString {
    
    @inline(__always)
    func applying(underline style: NSUnderlineStyle, withColor color: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.underlineColor: color, .underlineStyle: style.rawValue], inRange: range)
    }
    
    @inline(__always)
    func applying(strikethrough value: Int, withColor color: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.strikethroughStyle: value, .strikethroughColor: color], inRange: range)
    }
    
    @inline(__always)
    func applying(font: UIFont, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.font: font], inRange: range)
    }
    
    @inline(__always)
    func applying(foregroundColor: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.foregroundColor: foregroundColor], inRange: range)
    }
    
    @inline(__always)
    func applying(backgroundColor: UIColor, inRange range: NSRange? = nil) -> NSAttributedString {
        return applying([.backgroundColor: backgroundColor], inRange: range)
    }
    
}


internal extension NSAttributedString {
    
    @inline(__always)
    func applying(_ attributes: [Key: Any], inRange: NSRange? = nil) -> NSAttributedString {
        guard !string.isEmpty else { return self }
        let range: NSRange
        if let inRange { range = inRange }
        else { range = .init(0..<length) }
        let mutableCopy = NSMutableAttributedString(attributedString: self)
        mutableCopy.addAttributes(attributes, range: range)
        return mutableCopy
    }
    
    @inline(__always)
    convenience init(_ character: TFCharacter) {
        self.init(string: String(character.value))
    }

}


#endif
