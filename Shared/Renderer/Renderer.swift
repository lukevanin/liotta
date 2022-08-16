import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Color = Vector3


final class ScatterRay {
    var ray: Ray = Ray(origin: .zero, direction: .zero)
    var attenuation: Vector3 = .zero
}


final class HitRecord {
    var t: Real = 0
    var p: Vector3 = .zero
    var normal: Vector3 = .zero
    var material: AnyMaterial = AnyMaterial(NoMaterial())
}


final class Ray {
    
    var origin: Vector3
    var direction: Vector3
    
    convenience init() {
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


struct Viewport {
    let width: Int
    let height: Int
}


final class Renderer {
    
    typealias Pixel = UInt32
    
    final class Configuration {
        var samplesPerPixel: Int = 10000
        var samplesPerIteration: Int = 1
        var maximumBounces: Int = 50
        
        func copy() -> Configuration {
            let output = Configuration()
            output.samplesPerPixel = samplesPerPixel
            output.samplesPerIteration = samplesPerIteration
            output.maximumBounces = maximumBounces
            return output
        }
    }
    
    private(set) var sampleCount: Int = 0
    private(set) var renderCount: Int = 0
    private(set) var rayCount: Int = 0
    let canvas: Canvas

    private let sampleFactor: Int
    private let scene: RenderScene
    private let hit = HitRecord()
    private let bounce = ScatterRay()
    private let configuration: Configuration
    private let random = RandomNumberGenerator()
    
    init(sampleFactor: Int, scene: RenderScene, canvas: Canvas, configuration: Configuration) {
        self.sampleFactor = sampleFactor
        self.scene = scene
        self.configuration = configuration
        self.canvas = canvas
        self.renderCount = 0
        sampleCount = 0
    }
    
    func render() {
        rayCount = 0
        guard sampleCount < configuration.samplesPerPixel else {
            return
        }
        let w = canvas.width
        let h = canvas.height
        let samples = sampleFactor * configuration.samplesPerIteration
        for y in 0 ..< h {
            for x in 0 ..< w {
                var accumulatedColor = canvas.getPixel(x: x, y: y)
                for _ in 0 ..< samples {
                    let dx = random.next()
                    let dy = random.next()
                    let u = (Real(x) + dx) / Real(w)
                    let v = (Real(y) + dy) / Real(h)
                    let ray = scene.camera.rayAt(u: u, v: v)
                    accumulatedColor += color(ray: ray, world: scene.world)
                }
                canvas.setPixel(x: x, y: y, color: accumulatedColor)
            }
        }
        
        sampleCount += samples
        renderCount += 1
    }
    
    private func color(ray primaryRay: Ray, world: AnyHitable) -> Color {
        var attenuation = Vector3.one
        var depth = 0
        var ray = primaryRay
        while depth < configuration.maximumBounces {
            rayCount += 1
            guard world.hit(ray: ray, tMin: 0.001, tMax: .greatestFiniteMagnitude, result: hit) else {
                // Ray did not hit anything. Use the background sky color.
                return attenuation * scene.sky.color(ray: ray)
            }
            guard hit.material.scatter(inputRay: ray, hit: hit, result: bounce) else {
                return hit.material.emitted(u: 0, v: 0, p: hit.p)
            }
            ray = bounce.ray
            attenuation = attenuation * bounce.attenuation
            depth += 1
        }
        return .zero
    }
}
