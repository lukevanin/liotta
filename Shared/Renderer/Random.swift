import Foundation
import simd


final class RandomNumberGenerator {
    // Gold Noise ©2015 dcerisano@standard3d.com
    // - based on the Golden Ratio
    // - uniform normalized distribution
    // - fastest static noise generator function (also runs at low precision)
    // - use with indicated fractional seeding method.
    // float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio
    // float gold_noise(in vec2 xy, in float seed){
    //        return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
    // }
//    private var source = SystemRandomNumberGenerator()
//
//    func next() -> Real {
//        let limit = UInt64(0xFFFFFFFF)
//        return Real(source.next(upperBound: limit)) / Real(limit)
//    }

    private let phi = 1.61803398874989484820459;  // Φ = Golden Ratio

    private var seed = Real(CFAbsoluteTimeGetCurrent())
    private var xy = Real(0)

    func next() -> Real {
//        xy += 1
//        let v = simd_double2(xy * phi, xy)
//        return simd_fract(tan(simd_length(v) * seed) * xy)
        drand48()
    }
}

extension RandomNumberGenerator {
    
    func randomInUnitSphere() -> Vector3 {
        var p = Vector3.zero
        let origin = Vector3.one
        repeat {
            let r = Vector3(x: next(), y: next(), z: next())
            p = (2 * r) - origin
        } while simd_length_squared(p) >= 1
        return p
    }
    
    func randomInUnitDisk() -> Vector3 {
        var p = Vector3.zero
        let origin = Vector3(x: 1, y: 1, z: 0)
        repeat {
            let r = Vector3(x: next(), y: next(), z: 0)
            p = (2 * r) - origin
        } while simd_dot(p, p) >= 1
        return p
    }

}
