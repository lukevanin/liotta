import Foundation


struct YZRectangle: Hitable {
    
    let x: Real
    let y0: Real
    let y1: Real
    let z0: Real
    let z1: Real
    var normal = Vector3(x: 1, y: 0, z: 0)
    let material: AnyMaterial
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        let t = (x - ray.origin.x) / ray.direction.x
        if t < tMin || t > tMax {
            return false
        }
        let y = ray.origin.y + (t * ray.direction.y)
        let z = ray.origin.z + (t * ray.direction.z)
        if z < z0 || z > z1 || y < y0 || y > y1 {
            return false
        }
        result.u = (y - y0) / (y1 - y0)
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
            YZRectangle(
                x: x,
                y0: y0,
                y1: y1,
                z0: z0,
                z1: z1,
                normal: normal,
                material: material
            )
        )
    }
}
