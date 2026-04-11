internal extension Sequence where Element: Numeric {
    
    @inline(__always)
    func sum() -> Element {
        return reduce(0, +)
    }
    
}
