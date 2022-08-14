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


final class Renderer {
    
    typealias Pixel = UInt32
    
    struct Configuration {
        let samplesPerPixel: Int = 10000
        let samplesPerIteration: Int = 2
        let maximumBounces: Int = 50
    }
    
    private(set) var sampleCount: Int = 0
    private(set) var rayCount: Int = 0
    let canvas: Canvas

    private var scene: RenderScene
    private var startTime: Date = Date()
    private let configuration: Configuration
    
    init(scene: RenderScene, canvas: Canvas, configuration: Configuration) {
        self.scene = scene
        self.configuration = configuration
        self.canvas = canvas
        startTime = Date()
        sampleCount = 0
        rayCount = 0
    }
    
    func render() {
        rayCount = 0
        guard sampleCount < configuration.samplesPerPixel else {
            return
        }
        let w = canvas.width
        let h = canvas.height
        for y in 0 ..< h {
            for x in 0 ..< w {
                var accumulatedColor = canvas.getPixel(x: x, y: y)
                for _ in 0 ..< configuration.samplesPerIteration {
                    let dx = Real.random()
                    let dy = Real.random()
                    let u = (Real(x) + dx) / Real(w)
                    let v = (Real(y) + dy) / Real(h)
                    let ray = scene.camera.rayAt(u: u, v: v)
                    accumulatedColor += color(ray: ray, world: scene.world)
                }
                canvas.setPixel(x: x, y: y, color: accumulatedColor)
            }
        }
        sampleCount += configuration.samplesPerIteration
        // logStats()
    }
    
    private func color(ray: Ray, world: Hitable, depth: Int = 0) -> Color {
        rayCount += 1
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
    
    func logStats() {
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        let raysPerSecond = Real(rayCount) / elapsedTime
        logger.info("Samples per pixel \(self.sampleCount.formatted())")
        logger.info("Render time \(elapsedTime.formatted()) seconds")
        logger.info("Primary rays \(self.rayCount.formatted())")
        logger.info("Rays per second \(raysPerSecond.formatted())")
    }
}
