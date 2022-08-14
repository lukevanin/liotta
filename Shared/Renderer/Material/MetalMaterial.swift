import Foundation
import simd


struct MetalMaterial: Material {
    
    var albedo: Vector3
    var fuzz: Real
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
        let reflected = simd_reflect(inputRay.direction, hit.normal)
        let direction = reflected + (fuzz * .randomInUnitSphere())
        guard simd_dot(direction, hit.normal) > 0 else {
            return nil
        }
        return ScatterRay(
            ray: Ray(origin: hit.p, direction: simd_normalize(direction)),
            attenuation: albedo
        )
    }
}
