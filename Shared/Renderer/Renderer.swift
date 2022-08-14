import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Color = Vector3


protocol Material {
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay?
}


struct ScatterRay {
    var ray: Ray
    var attenuation: Vector3
}


struct HitRecord {
    let t: Real
    let p: Vector3
    let normal: Vector3
    let material: Material
}


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


protocol Hitable {
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord?
}


struct RenderScene {
    var camera: Camera
    var world: Hitable
}


actor Renderer {
    
    typealias Pixel = UInt32
    
    struct Configuration {
        let width: Int
        let height: Int
        let samplesPerPixel: Int = 10000
        let samplesPerIteration: Int = 1
        let maximumBounces: Int = 50
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
    
    deinit {
        buffer.deallocate()
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
                for _ in 0 ..< configuration.samplesPerIteration {
                    let dx = Real.random()
                    let dy = Real.random()
                    let u = (Real(x) + dx) / Real(w)
                    let v = (Real(y) + dy) / Real(h)
                    let ray = scene.camera.rayAt(u: u, v: v)
                    accumulatedColor += color(ray: ray, world: scene.world)
                }
                setPixel(x: x, y: y, color: accumulatedColor)
            }
        }
        sampleCount += configuration.samplesPerIteration
        logStats()
    }
    
    private func color(ray: Ray, world: Hitable, depth: Int = 0) -> Color {
        primaryRayCount += 1
        if let hit = world.hit(ray: ray, tMin: 0.001, tMax: .greatestFiniteMagnitude), depth < configuration.maximumBounces {
            if let output = hit.material.scatter(inputRay: ray, hit: hit) {
                return output.attenuation * color(ray: output.ray, world: world, depth: depth + 1)
            }
            else {
                return .zero
            }
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
    
    private func getPixel(x: Int, y: Int) -> Color {
        buffer[index(x: x, y: y)]
    }

    private func setPixel(x: Int, y: Int, color: Color) {
        buffer[index(x: x, y: y)] = color
    }
    
    private func index(x: Int, y: Int) -> Int {
        ((configuration.height - y - 1) * configuration.width) + x
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
    
    func logStats() {
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        let raysPerSecond = Real(primaryRayCount) / elapsedTime
        logger.info("Samples per pixel \(self.sampleCount.formatted())")
        logger.info("Render time \(elapsedTime.formatted()) seconds")
        logger.info("Primary rays \(self.primaryRayCount.formatted())")
        logger.info("Rays per second \(raysPerSecond.formatted())")
    }
}
