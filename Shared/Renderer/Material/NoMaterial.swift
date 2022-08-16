import Foundation
import simd


final class NoMaterial: Material {
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        return false
    }
    
    func copy() -> AnyMaterial {
        AnyMaterial(NoMaterial())
    }
}
