import Foundation


protocol Hitable {
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool
    func copy() -> AnyHitable
}


final class AnyHitable {
    
    typealias Hit = (Ray, Real, Real, HitRecord) -> Bool
    typealias Copy = () -> AnyHitable
    
    private let _hit: Hit
    private let _copy: Copy
    
    init<T>(_ instance: T) where T: Hitable {
        _hit = instance.hit
        _copy = instance.copy
    }
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        _hit(ray, tMin, tMax, result)
    }
    
    func copy() -> AnyHitable {
        _copy()
    }
}
