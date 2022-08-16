import Foundation
import simd


final class DielectricMaterial: Material {
    
    private let refractionIndex: Real
    private let random = RandomNumberGenerator()
    
    init(refractionIndex: Real) {
        self.refractionIndex = refractionIndex
    }
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        let attenuation = Vector3(x: 1.0, y: 1.0, z: 1.0)
        let outwardNormal: Vector3
        let niOverNt: Real
        let cosine: Real
        let rayDotNormal = simd_dot(inputRay.direction, hit.normal)
        
        if rayDotNormal > 0 {
            outwardNormal = -hit.normal
            niOverNt = refractionIndex
            cosine = refractionIndex * rayDotNormal
        }
        else {
            outwardNormal = hit.normal
            niOverNt = 1.0 / refractionIndex
            cosine = -rayDotNormal
        }
        
        let refracted = simd_refract(inputRay.direction, outwardNormal, niOverNt)
        if refracted != .zero {
            let reflectionProbability = schlick(cosine: cosine)
            if random.next() < reflectionProbability {
                let reflected = simd_reflect(inputRay.direction, hit.normal)
                result.ray.origin = hit.p
                result.ray.direction = simd_normalize(reflected)
                result.attenuation = attenuation
            }
            else {
                result.ray.origin = hit.p
                result.ray.direction = simd_normalize(refracted)
                result.attenuation = attenuation
            }
        }
        else {
            let reflected = simd_reflect(inputRay.direction, hit.normal)
            result.ray.origin = hit.p
            result.ray.direction = simd_normalize(reflected)
            result.attenuation = attenuation
        }
        return true
    }
    
    private func schlick(cosine: Real) -> Real {
        let r = (1 - refractionIndex) / (1 + refractionIndex)
        let r0 = r * r
        return r0 + (1 - r0) * pow((1 - cosine), 5)
    }
    
    func copy() -> AnyMaterial {
        AnyMaterial(
            DielectricMaterial(
                refractionIndex: refractionIndex
            )
        )
    }
}
