import Foundation
import simd


final class MetalMaterial: Material {
    
    private let albedo: Vector3
    private let fuzz: Real
    private let random = RandomNumberGenerator()
    
    init(albedo: Vector3, fuzz: Real) {
        self.albedo = albedo
        self.fuzz = fuzz
    }
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        let reflected = simd_reflect(inputRay.direction, hit.normal)
        let direction = reflected + (fuzz * random.randomInUnitSphere())
        guard simd_dot(direction, hit.normal) > 0 else {
            return false
        }
        result.ray.origin = hit.p
        result.ray.direction = simd_normalize(direction)
        result.attenuation = albedo
        return true
    }
    
    func copy() -> AnyMaterial {
        AnyMaterial(
            MetalMaterial(
                albedo: albedo,
                fuzz: fuzz
            )
        )
    }
}
