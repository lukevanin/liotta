import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Component = Double


typealias Vector3 = SIMD3<Component>


typealias Color = Vector3


//struct Color {
//    var r: Component
//    var g: Component
//    var b: Component
//}


struct Ray {
    
    var origin: Vector3
    var direction: Vector3
    
    init() {
        self.init(origin: .zero, direction: .zero)
    }
    
    init(origin: Vector3, direction: Vector3) {
        self.origin = origin
        self.direction = direction
    }
    
    func pointAtParameter(t: Double) -> Vector3 {
        origin + (direction * t)
    }
}


final class RenderScene {
    
    func hitSphere(center: Vector3, radius: Double, ray: Ray) -> Bool {
        let oc: Vector3 = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = 2.0 * simd_dot(oc, ray.direction)
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (4 * a * c)
        return discriminant > 0
    }
    
    func color(ray: Ray) -> Color {
        if hitSphere(center: Vector3(x: 0, y: 0, z: -1), radius: 0.5, ray: ray) {
            return Vector3(x: 1, y: 0, z: 0)
        }
        let a = Color(x: 1.0, y: 1.0, z: 1.0)
        let b = Color(x: 0.5, y: 0.7, z: 1.0)
        let unitDirection = simd_normalize(ray.direction)
        let t = 0.5 * (unitDirection.y + 1.0)
        return ((1 - t) * a) + (t * b)
    }
    
    func render(renderer: Renderer) {
        let w = renderer.configuration.width
        let h = renderer.configuration.height
        let corner = Vector3(x: -2.0, y: -1.0, z: -1.0)
        let horizontal = Vector3(x: 4.0, y: 0.0, z: 0.0)
        let vertical = Vector3(x: 0.0, y: 2.0, z: 0.0)
        let origin = Vector3(x: 0.0, y: 0.0, z: 0.0)
        for y in 0 ..< h {
            for x in 0 ..< w {
                let u = Component(x) / Component(w)
                let v = Component(y) / Component(h)
                let ray = Ray(
                    origin: origin,
                    direction: corner + (u * horizontal) + ((1 - v) * vertical)
                )
                let c = color(ray: ray)
                renderer.setPixel(x: x, y: y, color: c)
            }
        }
    }
}


final class Renderer {
    
    typealias Component = UInt32
    
    struct Configuration {
        let width: Int
        let height: Int
    }
    
    let configuration: Configuration
    private let buffer: UnsafeMutableBufferPointer<UInt32>
    
    init(configuration: Configuration) {
        self.configuration = configuration
        let count = configuration.width * configuration.height
        self.buffer = UnsafeMutableBufferPointer.allocate(capacity: count)
    }
    
    func render(scene: RenderScene) -> CGImage? {
        scene.render(renderer: self)
        let data = Data(buffer: buffer)
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            logger.warning("Cannot allocate data provider for render output")
            return nil
        }
        let alphaInfo = CGImageAlphaInfo.noneSkipLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        let componentBytes = MemoryLayout<Component>.size
        return CGImage(
            width: configuration.width,
            height: configuration.height,
            bitsPerComponent: 8,
            bitsPerPixel: componentBytes * 8,
            bytesPerRow: componentBytes * configuration.width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .perceptual
        )
    }
    
    func setPixel(x: Int, y: Int, color: Color) {
        buffer[index(x: x, y: y)] = component(from: color)
    }
    
    func component(from color: Color) -> Component {
        Component(color.z * 255.99) << 0x10 |
        Component(color.y * 255.99) << 0x08 |
        Component(color.x * 255.99) << 0x00
    }
    
    func index(x: Int, y: Int) -> Int {
        (y * configuration.width) + x
    }
}


final class RenderController: ObservableObject {
    
    @Published var image: CGImage?
    
    private let renderer: Renderer
    private let queue: DispatchQueue
    
    init(renderer: Renderer, queue: DispatchQueue) {
        self.renderer = renderer
        self.queue = queue
    }
    
    func render(scene: RenderScene) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
            let image = self.renderer.render(scene: scene)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
