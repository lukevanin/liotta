import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Color = Vector3


protocol Material {
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool
    func copy() -> AnyMaterial
}


final class AnyMaterial {
    
    private let _scatter: (Ray, HitRecord, ScatterRay) -> Bool
    private let _copy: () -> AnyMaterial
    
    init<T>(_ instance: T) where T: Material {
        _scatter = instance.scatter
        _copy = instance.copy
    }
    
    func scatter(inputRay: Ray, hit: HitRecord, result: ScatterRay) -> Bool {
        _scatter(inputRay, hit, result)
    }
    
    func copy() -> AnyMaterial {
        _copy()
    }
}


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


struct Viewport {
    let width: Int
    let height: Int
}


final class RenderScene {
    let camera: Camera
    let world: AnyHitable
    
    init(camera: Camera, world: AnyHitable) {
        self.camera = camera
        self.world = world
    }
    
    func copy() -> RenderScene {
        RenderScene(camera: camera.copy(), world: world.copy())
    }
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

    private var samplesPerPixel: Real
    private let scene: RenderScene
    private let hit = HitRecord()
    private let bounce = ScatterRay()
    private let configuration: Configuration
    private let random = RandomNumberGenerator()
    
    init(samplesPerPixel: Double, scene: RenderScene, canvas: Canvas, configuration: Configuration) {
        self.scene = scene
        self.configuration = configuration
        self.canvas = canvas
        self.samplesPerPixel = samplesPerPixel
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
        let samples = Int(ceil(samplesPerPixel))
        for _ in 0 ..< samples {
            let dx = random.next()
            let dy = random.next()
            for y in 0 ..< h {
                for x in 0 ..< w {
                    var accumulatedColor = canvas.getPixel(x: x, y: y)
                    let u = (Real(x) + dx) / Real(w)
                    let v = (Real(y) + dy) / Real(h)
                    let ray = scene.camera.rayAt(u: u, v: v)
                    accumulatedColor += color(ray: ray, world: scene.world)
                    canvas.setPixel(x: x, y: y, color: accumulatedColor)
                }
            }
        }
        
        sampleCount += samples // configuration.samplesPerIteration
//        samplesPerPixel = 1.5
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
                return attenuation * sky(ray: ray)
            }
            guard hit.material.scatter(inputRay: ray, hit: hit, result: bounce) else {
                return .zero
            }
            ray = bounce.ray
            attenuation = attenuation * bounce.attenuation
            depth += 1
        }
        return .zero
    }

    private func sky(ray: Ray) -> Color {
        let colorA = Color(x: 1.0, y: 1.0, z: 1.0)
        let colorB = Color(x: 0.5, y: 0.7, z: 1.0)
        let unitDirection = simd_normalize(ray.direction)
        let t = 0.5 * (unitDirection.y + 1.0)
        return ((1 - t) * colorA) + (t * colorB)
    }
}
