import Foundation
import simd


final class LambertianMaterial: Material {
    
    private let albedo: Vector3
    private let random = RandomNumberGenerator()
    
    init(albedo: Vector3) {
        self.albedo = albedo
    }
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        // TODO: Remove hit.p + followed by hit.p -
        //            let target = hit.normal + randomInUnitSphere()
        //            let nextRay = Ray(origin: hit.p, direction: simd_normalize(target))
        let target = hit.p + hit.normal + random.randomInUnitSphere()
        result.ray.origin = hit.p
        result.ray.direction = simd_normalize(target - hit.p)
        result.attenuation = albedo
        return true
    }
    
    func copy() -> AnyMaterial {
        AnyMaterial(
            LambertianMaterial(
                albedo: albedo
            )
        )
    }
}
