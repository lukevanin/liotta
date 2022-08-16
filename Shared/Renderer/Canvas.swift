import Foundation
import CoreGraphics


final class Canvas {
    
    let width: Int
    let height: Int
    
    let buffer: UnsafeMutableBufferPointer<Color>
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.buffer = UnsafeMutableBufferPointer.allocate(
            capacity: width * height
        )
        buffer.initialize(repeating: .zero)
        clear()
    }
    
    deinit {
        buffer.deallocate()
    }
    
    func clear(_ value: Color = .zero) {
        buffer.assign(repeating: value)
    }
    
    func copy(from canvas: Canvas) {
        guard canvas.width == width else {
            fatalError()
        }
        guard canvas.height == height else {
            fatalError()
        }
        guard let target = buffer.baseAddress else {
            fatalError()
        }
        guard let source = canvas.buffer.baseAddress else {
            fatalError()
        }
        target.assign(from: source, count: buffer.count)
    }

    func getPixel(x: Int, y: Int) -> Color {
        buffer[index(x: x, y: y)]
    }

    func setPixel(x: Int, y: Int, color: Color) {
        buffer[index(x: x, y: y)] = color
    }
    
    func index(x: Int, y: Int) -> Int {
        ((height - y - 1) * width) + x
    }
}

extension Canvas {
    
    typealias Pixel = UInt32
    
    func makeImage() -> CGImage? {
        let componentBytes = MemoryLayout<Pixel>.size
        let count = width * height
        var data = Data(count: count * componentBytes)
        data.withUnsafeMutableBytes { rawPointer in
            let bufferPointer = rawPointer.bindMemory(to: Pixel.self)
            for i in 0 ..< count {
                let c = correctGamma(buffer[i])
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
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: componentBytes * 8,
            bytesPerRow: componentBytes * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .perceptual
        )
    }
    
    private func pixel(from color: Color) -> Pixel {
        (Pixel(color.z * 255.99) & 0xff) << 0x10 |
        (Pixel(color.y * 255.99) & 0xff) << 0x08 |
        (Pixel(color.x * 255.99) & 0xff) << 0x00
    }
    
    private func correctGamma(_ input: Color) -> Color {
        Color(
            x: sqrt(input.x),
            y: sqrt(input.y),
            z: sqrt(input.z)
        )
    }
}
