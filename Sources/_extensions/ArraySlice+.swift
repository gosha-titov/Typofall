internal extension ArraySlice {
    
    @inline(__always)
    func toArray() -> Array<Element> {
        return Array(self)
    }
    
}
