import Foundation
import CoreGraphics
import OSLog


let logger = Logger(subsystem: "liotta", category: "render")


typealias Component = Float16


struct Color {
    var r: Component
    var g: Component
    var b: Component
}


final class RenderScene {
    
    func render(renderer: Renderer) {
        let w = renderer.configuration.width
        let h = renderer.configuration.height
        for y in 0 ..< h {
            for x in 0 ..< w {
                let u = Component(x) / Component(w)
                let v = Component(y) / Component(h)
                let c = Color(
                    r: u,
                    g: u * v,
                    b: v
                )
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
        Component(color.b * 255) << 0x10 |
        Component(color.g * 255) << 0x08 |
        Component(color.r * 255) << 0x00
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
