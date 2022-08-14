import Foundation
import simd


typealias Vector3 = SIMD3<Real>


extension Vector3 {
    
    static func randomInUnitSphere() -> Vector3 {
        var p = Vector3.zero
        let origin = Vector3.one
        repeat {
            let r = Vector3(x: .random(), y: .random(), z: .random())
            p = (2 * r) - origin
        } while simd_length_squared(p) >= 1
        return p
    }
    
    static func randomInUnitDisk() -> Vector3 {
        var p = Vector3.zero
        let origin = Vector3(x: 1, y: 1, z: 0)
        repeat {
            let r = Vector3(x: .random(), y: .random(), z: 0)
            p = (2 * r) - origin
        } while simd_dot(p, p) >= 1
        return p
    }
    
    static func refract(v: Vector3, n: Vector3, niOverNt: Real) -> Vector3? {
        let uv = simd_normalize(v)
        let dt = simd_dot(uv, n)
        let discriminant = 1.0 - niOverNt * niOverNt * (1.0 - dt * dt)
        guard discriminant > 0 else {
            return nil
        }
        return niOverNt * (uv - n * dt) - n * sqrt(discriminant)
    }
}
