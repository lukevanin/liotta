import Foundation


protocol Material {
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool
    func emitted(u: Real, v: Real, p: Vector3) -> Color
    func copy() -> AnyMaterial
}

extension Material {
    func emitted(u: Real, v: Real, p: Vector3) -> Color {
        .zero
    }
}


final class AnyMaterial {
    
    private let _scatter: (Ray, HitRecord, ScatterRay) -> Bool
    private let _emitted: (Real, Real, Vector3) -> Color
    private let _copy: () -> AnyMaterial
    
    init<T>(_ instance: T) where T: Material {
        _scatter = instance.scatter
        _emitted = instance.emitted
        _copy = instance.copy
    }
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        _scatter(inputRay, hit, result)
    }
    
    func emitted(u: Real, v: Real, p: Vector3) -> Color {
        _emitted(u, v, p)
    }
    
    func copy() -> AnyMaterial {
        _copy()
    }
}
