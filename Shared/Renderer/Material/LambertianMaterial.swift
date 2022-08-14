import Foundation
import simd


struct LambertianMaterial: Material {
    
    var albedo: Vector3
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
        // TODO: Remove hit.p + followed by hit.p -
        //            let target = hit.normal + randomInUnitSphere()
        //            let nextRay = Ray(origin: hit.p, direction: simd_normalize(target))
        let target = hit.p + hit.normal + .randomInUnitSphere()
        return ScatterRay(
            ray: Ray(origin: hit.p, direction: simd_normalize(target - hit.p)),
            attenuation: albedo
        )
    }
}
