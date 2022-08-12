import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Component = Double


typealias Vector3 = SIMD3<Component>


typealias Color = Vector3


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
    
    func point(at t: Double) -> Vector3 {
        origin + (direction * t)
    }
}


struct HitRecord {
    let t: Double
    let p: Vector3
    let normal: Vector3
}


protocol Hitable {
    func hit(ray: Ray, tMin: Double, tMax: Double) -> HitRecord?
}


struct Sphere: Hitable {
    var center: Vector3
    var radius: Double
    
    func hit(ray: Ray, tMin: Double, tMax: Double) -> HitRecord? {
        let oc: Vector3 = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = simd_dot(oc, ray.direction)
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (a * c)
        if discriminant > 0 {
            let s = sqrt(discriminant)
            var temp: Double
            
            temp = (-b - s) / a
            if temp > tMin && temp < tMax {
                let p = ray.point(at: temp)
                return HitRecord(
                    t: temp,
                    p: p,
                    normal: simd_normalize(p - center)
                )
            }
            
            temp = (-b + s) / a
            if temp > tMin && temp < tMax {
                let p = ray.point(at: temp)
                return HitRecord(
                    t: temp,
                    p: p,
                    normal: simd_normalize(p - center)
                )
            }
        }
        
        return nil
    }
}


struct HitableList: Hitable {
    
    var items = [Hitable]()
    
    func hit(ray: Ray, tMin: Double, tMax: Double) -> HitRecord? {
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


struct Camera {
    var corner: Vector3 = Vector3(x: -2.0, y: -1.0, z: -1.0)
    var horizontal: Vector3 = Vector3(x: 4.0, y: 0.0, z: 0.0)
    var vertical: Vector3 = Vector3(x: 0.0, y: 2.0, z: 0.0)
    var origin: Vector3 = Vector3(x: 0.0, y: 0.0, z: 0.0)

    func rayAt(u: Double, v: Double) -> Ray {
        Ray(
            origin: origin,
            direction: corner + (u * horizontal) + ((1 - v) * vertical)
        )
    }
}


struct RenderScene {
    var camera = Camera()
    var world = HitableList(items: [
        Sphere(center: Vector3(x: 0, y: 0, z: -1), radius: 0.5),
        Sphere(center: Vector3(x: 0, y: -100.5, z: -1), radius: 100)
    ])
}


final class Renderer {
    
    typealias Pixel = UInt32
    
    struct Configuration {
        let width: Int
        let height: Int
        let samplesPerPixel: Int = 50
    }
    
    let configuration: Configuration
    private let buffer: UnsafeMutableBufferPointer<UInt32>
    
    init(configuration: Configuration) {
        self.configuration = configuration
        let count = configuration.width * configuration.height
        self.buffer = UnsafeMutableBufferPointer.allocate(capacity: count)
    }
    
    func renderImage(scene: RenderScene) -> CGImage? {
        render(scene: scene)
        return makeImage()
    }
    
    private func makeImage() -> CGImage? {
        let data = Data(buffer: buffer)
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            logger.warning("Cannot allocate data provider for render output")
            return nil
        }
        let alphaInfo = CGImageAlphaInfo.noneSkipLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
        let componentBytes = MemoryLayout<Pixel>.size
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
    
    private func render(scene: RenderScene) {
        let w = configuration.width
        let h = configuration.height
        let ns = configuration.samplesPerPixel
        var primaryRayCount = 0
        let startTime = Date()
        for y in 0 ..< h {
            for x in 0 ..< w {
                var accumulatedColor = Color.zero
                for _ in 0 ..< ns {
                    let dx = Component.random(in: 0 ..< 1)
                    let dy = Component.random(in: 0 ..< 1)
                    let u = (Component(x) + dx) / Component(w)
                    let v = (Component(y) + dy) / Component(h)
                    let ray = scene.camera.rayAt(u: u, v: v)
                    accumulatedColor += color(ray: ray, world: scene.world)
                    primaryRayCount += 1
                }
                let averageColor = accumulatedColor / Component(samplesPerPixel)
                renderer.setPixel(x: x, y: y, color: averageColor)
            }
        }
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        logger.info("Render time \(elapsedTime.formatted()) seconds")
        logger.info("Primary rays \(primaryRayCount)")
    }
    
    private func color(ray: Ray, world: Hitable) -> Color {
        if let hit = world.hit(ray: ray, tMin: 0, tMax: .greatestFiniteMagnitude) {
            return 0.5 * Vector3(x: hit.normal.x + 1, y: hit.normal.y + 1, z: hit.normal.z + 1)
        }
        else {
            return sky(ray: ray)
        }
    }
    
    private func sky(ray: Ray) -> Color {
        let colorA = Color(x: 1.0, y: 1.0, z: 1.0)
        let colorB = Color(x: 0.5, y: 0.7, z: 1.0)
        let unitDirection = simd_normalize(ray.direction)
        let t = 0.5 * (unitDirection.y + 1.0)
        return ((1 - t) * colorA) + (t * colorB)
    }

    private func setPixel(x: Int, y: Int, color: Color) {
        buffer[index(x: x, y: y)] = pixel(from: color)
    }
    
    private func pixel(from color: Color) -> Pixel {
        Component(color.z * 255.99) << 0x10 |
        Component(color.y * 255.99) << 0x08 |
        Component(color.x * 255.99) << 0x00
    }
    
    private func index(x: Int, y: Int) -> Int {
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
            let image = self.renderer.renderImage(scene: scene)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
