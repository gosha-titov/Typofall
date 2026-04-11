internal extension BinaryInteger {
    
    @inline(__always)
    func clamped(to limits: PartialRangeFrom<Self>) -> Self {
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
    
    @inline(__always)
    func clamped(to limits: ClosedRange<Self>) -> Self {
        if self > limits.upperBound { return limits.upperBound }
        if self < limits.lowerBound { return limits.lowerBound }
        return self
    }
    
}
