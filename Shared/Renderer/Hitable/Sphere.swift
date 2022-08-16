import Foundation
import simd


final class Sphere: Hitable {
    
    private let center: Vector3
    private let radius: Real
    private let material: AnyMaterial
    
    init(
        center: Vector3,
        radius: Real,
        material: AnyMaterial
    ) {
        self.center = center
        self.radius = radius
        self.material = material
    }
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        let oc = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = simd_dot(oc, ray.direction)
        if b > 0 {
            return false
        }
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (a * c)
        guard discriminant > 0 else {
            return false
        }
        
        let s = sqrt(discriminant)
        var temp: Real
        
        temp = (-b - s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            result.t = temp
            result.p = p
            result.normal = simd_normalize((p - center) / radius)
            result.material = material
            return true
        }
        
        temp = (-b + s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            result.t = temp
            result.p = p
            result.normal = simd_normalize((p - center) / radius)
            result.material = material
            return true
        }
        
        return false
    }
    
    func copy() -> AnyHitable {
        AnyHitable(
            Sphere(
                center: center,
                radius: radius,
                material: material.copy()
            )
        )
    }
}
