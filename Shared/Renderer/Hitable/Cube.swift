import Foundation


final class Cube: Hitable {
    
    private let center: Vector3
    private let size: Vector3
    private let material: AnyMaterial
    private let list: HitableList
    
    init(center: Vector3, size: Vector3, material: AnyMaterial) {
        self.center = center
        self.size = size
        self.material = material
        self.list = HitableList(
            XYRectangle(
                x0: center.x - size.x,
                x1: center.x + size.x,
                y0: center.y,
                y1: center.y + size.y,
                z: center.z - size.z,
                normal: Vector3(x: 0, y: 0, z: +1),
                material: material
            ).copy(),
            XYRectangle(
                x0: center.x - size.x,
                x1: center.x + size.x,
                y0: center.y,
                y1: center.y + size.y,
                z: center.z + size.z,
                normal: Vector3(x: 0, y: 0, z: -1),
                material: material
            ).copy(),
            YZRectangle(
                x: center.x + size.x,
                y0: center.y,
                y1: center.y + size.y,
                z0: center.z - size.z,
                z1: center.z + size.z,
                normal: Vector3(x: +1, y: 0, z: 0),
                material: material
            ).copy(),
            YZRectangle(
                x: center.x - size.x,
                y0: center.y,
                y1: center.y + size.y,
                z0: center.z - size.z,
                z1: center.z + size.z,
                normal: Vector3(x: -1, y: 0, z: 0),
                material: material
            ).copy(),
            XZRectangle(
                x0: center.x - size.x,
                x1: center.x + size.x,
                y: center.y + size.y,
                z0: center.z - size.z,
                z1: center.z + size.z,
                normal: Vector3(x: 0, y: +1, z: 0),
                material: material
            ).copy(),
            XZRectangle(
                x0: center.x - size.x,
                x1: center.x + size.x,
                y: center.y - size.y,
                z0: center.z - size.z,
                z1: center.z + size.z,
                normal: Vector3(x: 0, y: -1, z: 0),
                material: material
            ).copy()
        )
    }
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        list.hit(ray: ray, tMin: tMin, tMax: tMax, result: result)
    }
    
    func copy() -> AnyHitable {
        AnyHitable(
            Cube(
                center: center,
                size: size,
                material: material
            )
        )
    }
}
