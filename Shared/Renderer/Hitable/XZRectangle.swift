import Foundation


struct XZRectangle: Hitable {
    
    let x0: Real
    let x1: Real
    let y: Real
    let z0: Real
    let z1: Real
    var normal = Vector3(x: 0, y: 1, z: 0)
    let material: AnyMaterial
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        let t = (y - ray.origin.y) / ray.direction.y
        if t < tMin || t > tMax {
            return false
        }
        let x = ray.origin.x + (t * ray.direction.x)
        let z = ray.origin.z + (t * ray.direction.z)
        if z < z0 || z > z1 || x < x0 || x > x1 {
            return false
        }
        result.u = (x - x0) / (x1 - x0)
        result.v = (z - z0) / (z1 - z0)
        result.t = t
        result.p = ray.point(at: t)
        result.setFaceNormal(ray: ray, outwardNormal: normal)
        result.material = material
        return true
    }
    
    // TODO: Remember to pad k with epsilon when creating bounding box
    
    func copy() -> AnyHitable {
        AnyHitable(
            XZRectangle(
                x0: x0,
                x1: x1,
                y: y,
                z0: z0,
                z1: z1,
                normal: normal,
                material: material
            )
        )
    }
}
