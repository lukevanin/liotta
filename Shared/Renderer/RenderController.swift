import Foundation


actor RenderManager {
    
    typealias ImageCallback = (CGImage) -> Void
    
    private var imageCallback: ImageCallback?
    private var renderCount: Int
    private var rayCount: Int
    private var duration: TimeInterval
    
    private let concurrency: Int
    private let tempCanvas: Canvas
    private let outputCanvas: Canvas

    init(concurrency: Int, scene: RenderScene, width: Int, height: Int, configuration: Renderer.Configuration) {
        self.concurrency = concurrency
        self.tempCanvas = Canvas(width: width, height: height)
        self.outputCanvas = Canvas(width: width, height: height)
        self.renderCount = 0
        self.rayCount = 0
        self.duration = 0
        for _ in 0 ..< concurrency {
            Task.detached(priority: .high) {
                let canvas = Canvas(width: width, height: height)
                let renderer = Renderer(scene: scene, canvas: canvas, configuration: configuration)
                while true {
                    let startTime = Date()
                    renderer.render()
                    let endTime = Date()
                    let duration = endTime.timeIntervalSince(startTime)
                    await self.updateOutput(
                        canvas: canvas,
                        sampleCount: renderer.sampleCount,
                        duration: duration,
                        rayCount: renderer.rayCount
                    )
                }
            }
        }
    }
    
    func onImage(_ imageCallback: @escaping ImageCallback) {
        self.imageCallback = imageCallback
    }
    
    private func updateOutput(
        canvas: Canvas,
        sampleCount: Int,
        duration: TimeInterval,
        rayCount: Int
    ) {
        renderCount += 1
        let s = 1 / Real(sampleCount)
        let r = 1 / Real(renderCount)
        // Copy the canvas from the renderer. Compute the average of each pixel
        // for the number of samples so far.
        for i in 0 ..< tempCanvas.buffer.count {
            tempCanvas.buffer[i] += canvas.buffer[i] * s
        }
        // Copy the temp canvas to the output canvas. For each pixel, compute
        // the average over the number of renders.
        for i in 0 ..< tempCanvas.buffer.count {
            outputCanvas.buffer[i] = tempCanvas.buffer[i] * r
        }
        
        
        if let imageCallback = imageCallback, let image = makeImage() {
            imageCallback(image)
        }
        
        self.duration += duration
        self.rayCount += rayCount
        let raysPerSecond = Real(rayCount) / duration
        logger.info("Render #\(self.renderCount.formatted())")
        logger.info("Duration \(self.duration.formatted()) seconds")
        logger.info("Rays \(self.rayCount.formatted())")
        logger.info("Rays per second \(raysPerSecond.formatted())")
    }
    
    func makeImage() -> CGImage? {
        return outputCanvas.makeImage()
    }
}


@MainActor final class RenderController: ObservableObject {
    
    @Published var image: CGImage?
    
    private var running: Bool
    private let manager: RenderManager
    
    init(manager: RenderManager) {
        self.manager = manager
        self.running = false
    }
    
    func startRenderer() {
        guard running == false else {
            return
        }
        running = true
        Task.detached {
            await self.manager.onImage { image in
                Task {
                    await self.setImage(image)
                }
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
