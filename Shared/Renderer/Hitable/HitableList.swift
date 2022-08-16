import Foundation


final class HitableList: Hitable {
    
    var items = [AnyHitable]()
    
    convenience init(_ items: AnyHitable...) {
        self.init(items)
    }
    
    init(_ items: [AnyHitable]) {
        self.items = items
    }
    
    func append(_ item: AnyHitable) {
        items.append(item)
    }
    
    func hit(ray: Ray, tMin: Real, tMax: Real, result: HitRecord) -> Bool {
        var closest = tMax
        var isHit = false
        for item in items {
            if item.hit(ray: ray, tMin: tMin, tMax: closest, result: result) {
                isHit = true
                closest = result.t
            }
        }
        return isHit
    }
    
    func copy() -> AnyHitable {
        AnyHitable(HitableList(items.map { $0.copy() }))
    }
}
