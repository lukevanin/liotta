import Foundation


protocol Sky {
    func color(ray: Ray) -> Color
    func copy() -> AnySky
}


struct AnySky {
    
    private let _color: (Ray) -> Color
    private let _copy: () -> AnySky
    
    init<T>(_ instance: T) where T: Sky {
        _color = instance.color
        _copy = instance.copy
    }
    
    func color(ray: Ray) -> Color {
        _color(ray)
    }
    
    func copy() -> AnySky {
        _copy()
    }
}
