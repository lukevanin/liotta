import Foundation


struct HitableList: Hitable {
    
    var items = [Hitable]()
    
    mutating func append(_ item: Hitable) {
        items.append(item)
    }
    
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord? {
        var output: HitRecord?
        var closest = tMax
        for item in items {
            if let hit = item.hit(ray: ray, tMin: tMin, tMax: closest) {
                closest = hit.t
                output = hit
            }
        }
        return output
    }
}
