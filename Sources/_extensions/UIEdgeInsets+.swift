#if canImport(UIKit)

import UIKit

internal extension UIEdgeInsets {
    
    @inline(__always)
    var vertical: CGFloat {
        return top + bottom
    }
    
    @inline(__always)
    var horizontal: CGFloat {
        return left + right
    }
    
}

#endif
