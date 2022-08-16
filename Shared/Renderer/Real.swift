import Foundation


typealias Real = Double


extension Real {
    static func random() -> Real {
//        Real.random(in: 0 ..< 1)
        drand48()
//        0.5
    }
}
