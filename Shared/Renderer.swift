import Foundation
import CoreGraphics
import simd
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Real = Double


typealias Vector3 = SIMD3<Real>


typealias Color = Vector3


extension Real {
    static func random() -> Real {
        Real.random(in: 0 ..< 1)
    }
}


extension Vector3 {
    static func randomInUnitSphere() -> Vector3 {
        var p = Vector3.zero
        repeat {
            let r = Vector3(x: .random(), y: .random(), z: .random())
            p = (2 * r) - .one
        } while simd_length_squared(p) >= 1
        return p
    }
    
    static func refract(v: Vector3, n: Vector3, niOverNt: Real) -> Vector3? {
        let uv = simd_normalize(v)
        let dt = simd_dot(uv, n)
        let discriminant = 1.0 - niOverNt * niOverNt * (1.0 - dt * dt)
        guard discriminant > 0 else {
            return nil
        }
        return niOverNt * (uv - n * dt) - n * sqrt(discriminant)
    }
}


protocol Material {
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay?
}


struct ScatterRay {
    var ray: Ray
    var attenuation: Vector3
}


struct LambertianMaterial: Material {
    
    var albedo: Vector3
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
        // TODO: Remove hit.p + followed by hit.p -
        //            let target = hit.normal + randomInUnitSphere()
        //            let nextRay = Ray(origin: hit.p, direction: simd_normalize(target))
        let target = hit.p + hit.normal + .randomInUnitSphere()
        return ScatterRay(
            ray: Ray(origin: hit.p, direction: simd_normalize(target - hit.p)),
            attenuation: albedo
        )
    }
}


struct MetalMaterial: Material {
    
    var albedo: Vector3
    var fuzz: Real
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
        let reflected = simd_reflect(inputRay.direction, hit.normal)
        let direction = reflected + (fuzz * .randomInUnitSphere())
        guard simd_dot(direction, hit.normal) > 0 else {
            return nil
        }
        return ScatterRay(
            ray: Ray(origin: hit.p, direction: simd_normalize(direction)),
            attenuation: albedo
        )
    }
}


struct DielectricMaterial: Material {
    
    var refractionIndex: Real
    
    func scatter(inputRay: Ray, hit: HitRecord) -> ScatterRay? {
        let attenuation = Vector3(x: 1.0, y: 1.0, z: 1.0)
        let outwardNormal: Vector3
        let niOverNt: Real
        let cosine: Real
        let rayDotNormal = simd_dot(inputRay.direction, hit.normal)
        
        if rayDotNormal > 0 {
            outwardNormal = -hit.normal
            niOverNt = refractionIndex
            cosine = refractionIndex * rayDotNormal
        }
        else {
            outwardNormal = hit.normal
            niOverNt = 1.0 / refractionIndex
            cosine = -rayDotNormal
        }
        
        if let refracted = Vector3.refract(v: inputRay.direction, n: outwardNormal, niOverNt: niOverNt) {
            let reflectionProbability = schlick(cosine: cosine)
            if Real.random() < reflectionProbability {
                let reflected = simd_reflect(inputRay.direction, hit.normal)
                return ScatterRay(
                    ray: Ray(origin: hit.p, direction: simd_normalize(reflected)),
                    attenuation: attenuation
                )
            }
            else {
                return ScatterRay(
                    ray: Ray(origin: hit.p, direction: simd_normalize(refracted)),
                    attenuation: attenuation
                )
            }
        }
        else {
            let reflected = simd_reflect(inputRay.direction, hit.normal)
            return ScatterRay(
                ray: Ray(origin: hit.p, direction: simd_normalize(reflected)),
                attenuation: attenuation
            )
        }
    }
    
    private func schlick(cosine: Real) -> Real {
        let r = (1 - refractionIndex) / (1 + refractionIndex)
        let r0 = r * r
        return r0 + (1 - r0) * pow((1 - cosine), 5)
    }
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


struct Sphere: Hitable {
    var center: Vector3
    var radius: Real
    var material: Material
    
    func hit(ray: Ray, tMin: Real, tMax: Real) -> HitRecord? {
        let oc = ray.origin - center
        let a = simd_dot(ray.direction, ray.direction)
        let b = simd_dot(oc, ray.direction)
        let c = simd_dot(oc, oc) - (radius * radius)
        let discriminant = (b * b) - (a * c)
        guard discriminant > 0 else {
            return nil
        }
        
        let s = sqrt(discriminant)
        var temp: Real
        
        temp = (-b - s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            return HitRecord(
                t: temp,
                p: p,
                normal: simd_normalize((p - center) / radius),
                material: material
            )
        }
        
        temp = (-b + s) / a
        if temp > tMin && temp < tMax {
            let p = ray.point(at: temp)
            return HitRecord(
                t: temp,
                p: p,
                normal: simd_normalize((p - center) / radius),
                material: material
            )
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
    var corner: Vector3
    var horizontal: Vector3
    var vertical: Vector3
    var origin: Vector3
    
    init(fieldOfView: Real, aspectRatio: Real) {
        let theta = fieldOfView * .pi / 180
        let halfHeight = tan(theta / 2)
        let halfWidth = aspectRatio * halfHeight
        self.corner = Vector3(x: -halfWidth, y: -halfHeight, z: -1.0)
        self.horizontal = Vector3(x: 2 * halfWidth, y: 0, z: 0)
        self.vertical = Vector3(x: 0, y: 2 * halfHeight, z: 0)
        self.origin = .zero
    }

    func rayAt(u: Real, v: Real) -> Ray {
        Ray(
            origin: origin,
            direction: simd_normalize(corner + (u * horizontal) + ((1 - v) * vertical))
        )
    }
}


struct RenderScene {
    var camera = Camera(fieldOfView: 90, aspectRatio: 200.0 / 100.0)
    var world = HitableList(items: [
        Sphere(
            center: Vector3(x: 0, y: 0, z: -1),
            radius: 0.5,
            material: LambertianMaterial(
                albedo: Vector3(x: 0.1, y: 0.2, z: 0.5)
            )
        ),
        Sphere(
            center: Vector3(x: 0, y: -100.5, z: -1),
            radius: 100,
            material: LambertianMaterial(
                albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
            )
        ),
        Sphere(
            center: Vector3(x: 1, y: 0, z: -1),
            radius: 0.5,
            material: MetalMaterial(
                albedo: Vector3(x: 0.8, y: 0.6, z: 0.2),
                fuzz: 0.0
            )
        ),
        Sphere(
            center: Vector3(x: -1, y: 0, z: -1),
            radius: 0.5,
            material: DielectricMaterial(
                refractionIndex: 1.5
            )
        ),
        Sphere(
            center: Vector3(x: -1, y: 0, z: -1),
            radius: -0.45,
            material: DielectricMaterial(
                refractionIndex: 1.5
            )
        ),
    ])
}


actor Renderer {
    
    typealias Pixel = UInt32
    
    struct Configuration {
        let width: Int
        let height: Int
        let samplesPerPixel: Int = 1000
        let samplesPerIteration: Int = 10
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
        if let hit = world.hit(ray: ray, tMin: 0.001, tMax: .greatestFiniteMagnitude), depth < configuration.maximumBounces {
            primaryRayCount += 1
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
    
    func logStats() {
        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        let raysPerSecond = Real(primaryRayCount) / elapsedTime
        logger.info("Samples per pixel \(self.sampleCount.formatted())")
        logger.info("Render time \(elapsedTime.formatted()) seconds")
        logger.info("Primary rays \(self.primaryRayCount)")
        logger.info("Rays per second \(raysPerSecond.formatted())")
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
