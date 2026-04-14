import Foundation

internal extension String {
    
    @inline(__always)
    func commonSuffix(with str: String) -> String {
        var index1 = endIndex, index2 = str.endIndex
        while index1 > startIndex && index2 > str.startIndex {
            self.formIndex(before: &index1)
            str .formIndex(before: &index2)
            if self[index1] != str[index2] {
                self.formIndex(after: &index1)
                str .formIndex(after: &index2)
                break
            }
        }
        return String(self[index1..<endIndex])
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
