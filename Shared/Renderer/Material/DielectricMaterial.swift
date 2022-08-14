import Foundation
import simd


struct DielectricMaterial: Material {
    
    var refractionIndex: Real
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
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
        
        if let refracted = Vector3.refract(v: inputRay.direction, n: outwardNormal, niOverNt: niOverNt) {
            let reflectionProbability = schlick(cosine: cosine)
            if Real.random() < reflectionProbability {
                let reflected = simd_reflect(inputRay.direction, hit.normal)
                return ScatterRay(
                    ray: Ray(origin: hit.p, direction: simd_normalize(reflected)),
                    attenuation: attenuation
                )
            }
            else {
                return ScatterRay(
                    ray: Ray(origin: hit.p, direction: simd_normalize(refracted)),
                    attenuation: attenuation
                )
            }
        }
        else {
            let reflected = simd_reflect(inputRay.direction, hit.normal)
            return ScatterRay(
                ray: Ray(origin: hit.p, direction: simd_normalize(reflected)),
                attenuation: attenuation
            )
        }
    }
    
    private func schlick(cosine: Real) -> Real {
        let r = (1 - refractionIndex) / (1 + refractionIndex)
        let r0 = r * r
        return r0 + (1 - r0) * pow((1 - cosine), 5)
    }
}
