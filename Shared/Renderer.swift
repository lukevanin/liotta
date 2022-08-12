import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Real = Double


typealias Vector3 = SIMD3<Real>


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
    
    func point(at t: Real) -> Vector3 {
        origin + (direction * t)
    }
}


struct HitRecord {
    let t: Real
    let p: Vector3
    let normal: Vector3
}


protocol Hitable {
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord?
}


struct Sphere: Hitable {
    var center: Vector3
    var radius: Real
    
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord? {
        let oc: Vector3 = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = simd_dot(oc, ray.direction)
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (a * c)
        if discriminant > 0 {
            let s = sqrt(discriminant)
            var temp: Real
            
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


struct Camera {
    var corner: Vector3 = Vector3(x: -2.0, y: -1.0, z: -1.0)
    var horizontal: Vector3 = Vector3(x: 4.0, y: 0.0, z: 0.0)
    var vertical: Vector3 = Vector3(x: 0.0, y: 2.0, z: 0.0)
    var origin: Vector3 = Vector3(x: 0.0, y: 0.0, z: 0.0)

    func rayAt(u: Real, v: Real) -> Ray {
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


actor Renderer {
    
    typealias Pixel = UInt32
    
    struct Configuration {
        let width: Int
        let height: Int
        let samplesPerPixel: Int = 100
        let maximumBounces: Int = 100
    }
    
    private var scene: RenderScene?
    private var sampleCount: Int = 0
    private var primaryRayCount: Int = 0
    private var startTime: Date = Date()
    private let configuration: Configuration
    private let buffer: UnsafeMutableBufferPointer<Color>
    
    init(configuration: Configuration) {
        self.configuration = configuration
        let count = configuration.width * configuration.height
        self.buffer = UnsafeMutableBufferPointer.allocate(capacity: count)
        buffer.initialize(repeating: .zero)
    }
    
    func setScene(_ scene: RenderScene?) {
        self.scene = scene
        startTime = Date()
        sampleCount = 0
        primaryRayCount = 0
        buffer.assign(repeating: .zero)
    }
    
    func render() {
        guard let scene = scene else {
            return
        }
        guard sampleCount < configuration.samplesPerPixel else {
            return
        }
        let w = configuration.width
        let h = configuration.height
        for y in 0 ..< h {
            for x in 0 ..< w {
                var accumulatedColor = getPixel(x: x, y: y)
                let dx = random()
                let dy = random()
                let u = (Real(x) + dx) / Real(w)
                let v = (Real(y) + dy) / Real(h)
                let ray = scene.camera.rayAt(u: u, v: v)
                accumulatedColor += color(ray: ray, world: scene.world)
                setPixel(x: x, y: y, color: accumulatedColor)
                primaryRayCount += 1
            }
        }
        sampleCount += 1
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        logger.info("Samples per pixel \(self.sampleCount.formatted())")
        logger.info("Render time \(elapsedTime.formatted()) seconds")
        logger.info("Primary rays \(self.primaryRayCount)")
    }
    
    private func color(ray: Ray, world: Hitable, depth: Int = 0) -> Color {
        guard depth < configuration.maximumBounces else {
            return .zero
        }
        if let hit = world.hit(ray: ray, tMin: 0, tMax: .greatestFiniteMagnitude) {
            // TODO: Remove hit.p + followed by hit.p -
            let target = hit.p + hit.normal + randomInUnitSphere()
            let nextRay = Ray(origin: hit.p, direction: simd_normalize(target - hit.p))
//            let target = hit.normal + randomInUnitSphere()
//            let nextRay = Ray(origin: hit.p, direction: simd_normalize(target))
            return 0.5 * color(ray: nextRay, world: world, depth: depth + 1)
        }
        else {
            return sky(ray: ray)
        }
    }
    
    private func randomInUnitSphere() -> Vector3 {
        var p = Vector3.zero
        repeat {
            let r = Vector3(x: random(), y: random(), z: random())
            p = (2 * r) - .one
        } while simd_length_squared(p) >= 1
        return p
    }
    
    private func random() -> Real {
        Real.random(in: 0 ..< 1)
    }

    private func sky(ray: Ray) -> Color {
        let colorA = Color(x: 1.0, y: 1.0, z: 1.0)
        let colorB = Color(x: 0.5, y: 0.7, z: 1.0)
        let unitDirection = simd_normalize(ray.direction)
        let t = 0.5 * (unitDirection.y + 1.0)
        return ((1 - t) * colorA) + (t * colorB)
    }
    
    private func getPixel(x: Int, y: Int) -> Color {
        buffer[index(x: x, y: y)]
    }

    private func setPixel(x: Int, y: Int, color: Color) {
        buffer[index(x: x, y: y)] = color
    }
    
    private func index(x: Int, y: Int) -> Int {
        (y * configuration.width) + x
    }
    
    func makeImage() -> CGImage? {
        let componentBytes = MemoryLayout<Pixel>.size
        let count = configuration.width * configuration.height
        var data = Data(count: count * componentBytes)
        data.withUnsafeMutableBytes { rawPointer in
            let bufferPointer = rawPointer.bindMemory(to: Pixel.self)
            let t = (1 / Real(sampleCount))
            for i in 0 ..< count {
                let c = correctGamma(buffer[i] * t)
                let p = pixel(from: c)
                bufferPointer[i] = p
            }
        }
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            logger.warning("Cannot allocate data provider for render output")
            return nil
        }
        let alphaInfo = CGImageAlphaInfo.noneSkipLast
        let bitmapInfo = CGBitmapInfo(rawValue: alphaInfo.rawValue)
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
    
    private func pixel(from color: Color) -> Pixel {
        Pixel(color.z * 255.99) << 0x10 |
        Pixel(color.y * 255.99) << 0x08 |
        Pixel(color.x * 255.99) << 0x00
    }
    
    private func correctGamma(_ input: Color) -> Color {
        Color(
            x: sqrt(input.x),
            y: sqrt(input.y),
            z: sqrt(input.z)
        )
    }
}


@globalActor
actor RenderActor {
    
    static var shared = RenderActor()
}


@MainActor final class RenderController: ObservableObject {
    
    @Published var image: CGImage?
    
    var scene: RenderScene? {
        didSet {
            setRenderScene(scene)
        }
    }
    
    private var running: Bool
    private let renderer: Renderer
    
    init(configuration: Renderer.Configuration) {
        self.renderer = Renderer(configuration: configuration)
        self.running = false
    }
    
    private func setRenderScene(_ scene: RenderScene?) {
        Task.detached {
            await self.renderer.setScene(scene)
        }
    }
    
    func startRenderer() {
        guard running == false else {
            return
        }
        running = true
        Task.detached {
            let running = await self.running
            while running == true {
                await self.renderer.render()
                let image = await self.renderer.makeImage()
                await self.setImage(image)
            }
        }
    }
    
    private func setImage(_ image: CGImage?) {
        self.image = image
    }

    func stopRenderer() {
        running = false
    }
}
