internal extension Optional {
    
    @inline(__always)
    var hasValue: Bool { self != nil }
    
}
