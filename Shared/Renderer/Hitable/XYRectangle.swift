import Foundation


struct XYRectangle: Hitable {
    
    let x0: Real
    let x1: Real
    let y0: Real
    let y1: Real
    let z: Real
    var normal: Vector3 = Vector3(x: 0, y: 0, z: 1)
    let material: AnyMaterial
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        let t = (z - ray.origin.z) / ray.direction.z
        if t < tMin || t > tMax {
            return false
        }
        let x = ray.origin.x + (t * ray.direction.x)
        let y = ray.origin.y + (t * ray.direction.y)
        if x < x0 || x > x1 || y < y0 || y > y1 {
            return false
        }
        result.u = (x - x0) / (x1 - x0)
        result.v = (y - y0) / (y1 - y0)
        result.t = t
        let outwardNormal = normal
        result.p = ray.point(at: t)
        result.setFaceNormal(ray: ray, outwardNormal: outwardNormal)
        result.material = material
        return true
    }
    
    // TODO: Remember to pad k with epsilon when creating bounding box
    
    func copy() -> AnyHitable {
        AnyHitable(
            XYRectangle(
                x0: x0,
                x1: x1,
                y0: y0,
                y1: y1,
                z: z,
                normal: normal,
                material: material
            )
        )
    }
}
