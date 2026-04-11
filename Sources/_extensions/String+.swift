import Foundation

internal extension String {
    
    @inline(__always)
    func commonSuffix(with str: String) -> String {
        var suffix = String()
        let min = min(count, str.count)
        let str1 = self.suffix(min)
        let str2 = str .suffix(min)
        for (char1, char2) in zip(str1, str2).reversed() {
            if char1 == char2 { suffix += char1 }
            else { break }
        }
        return String(suffix.reversed())
    }
    
    
    // MARK: Operators
    
    @inline(__always)
    static func += (lhs: inout String, rhs: Character) -> Void {
        lhs = lhs + String(rhs)
    }
    
    
    // MARK: Subscripts
    
    @inline(__always)
    subscript(offset: Int) -> Character {
        let index = index(startIndex, offsetBy: offset)
        return self[index]
    }
    
    @inline(__always)
    subscript(safe offset: Int) -> Character? {
        guard (0..<count).contains(offset) else { return nil }
        return self[offset]
    }
    
}
