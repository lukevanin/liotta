import Foundation


struct MonochromeLightMaterial: Material {
    
    let color: Color
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        false
    }
    
    func emitted(u: Real, v: Real, p: Vector3) -> Color {
        color
    }
    
    func copy() -> AnyMaterial {
        AnyMaterial(
            MonochromeLightMaterial(
                color: color
            )
        )
    }
}
