import Foundation
import simd


typealias Vector3 = SIMD3<Real>


extension Vector3 {
    
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
