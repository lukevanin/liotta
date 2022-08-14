import Foundation
import simd


struct Sphere: Hitable {
    var center: Vector3
    var radius: Real
    var material: Material
    
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord? {
        let oc = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = simd_dot(oc, ray.direction)
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (a * c)
        guard discriminant > 0 else {
            return nil
        }
        
        let s = sqrt(discriminant)
        var temp: Real
        
        temp = (-b - s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            return HitRecord(
                t: temp,
                p: p,
                normal: simd_normalize((p - center) / radius),
                material: material
            )
        }
        
        temp = (-b + s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            return HitRecord(
                t: temp,
                p: p,
                normal: simd_normalize((p - center) / radius),
                material: material
            )
        }
        
        return nil
    }
}
