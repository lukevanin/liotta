import Foundation
import OSLog


private let workerLog = OSLog(subsystem: "render", category: "worker")
private let workerEventLog = OSLog(subsystem: "render", category: .pointsOfInterest)


struct RenderResult {
    let renderId: Int
    let canvas: Canvas
    let duration: TimeInterval
    let rayCount: Int
    let sampleCount: Int
}


final class RenderWorker {
    
    typealias ResultHandler = (RenderResult) -> Void
    
    private var thread: Thread?
    
    init(
        id: Int,
        viewport: Viewport,
        scene: RenderScene,
        configuration: Renderer.Configuration,
        handler: @escaping ResultHandler
    ) {
        let signpostId = OSSignpostID(log: workerLog, object: self)
        thread = Thread {
//        Thread.detachNewThread {
            Thread.setThreadPriority(1.0)
            let scene = scene.copy()
            let configuration = configuration.copy()
            let canvas = Canvas(width: viewport.width, height: viewport.height)
            let output = Canvas(width: viewport.width, height: viewport.height)
            let renderer = Renderer(
                sampleFactor: id + 1,
                scene: scene,
                canvas: canvas,
                configuration: configuration
            )
            while Thread.current.isCancelled == false {
                os_signpost(.begin, log: workerLog, name: "Render", signpostID: signpostId)
//                let startTime = CFAbsoluteTimeGetCurrent()
                renderer.render()
//                let endTime = CFAbsoluteTimeGetCurrent()
//                let duration = endTime - startTime
//                os_signpost(.event, log: workerEventLog, name: "render", signpostID: signpostId, "duration %d", duration)
                os_signpost(.end, log: workerLog, name: "Render", signpostID: signpostId)

                // Copy the canvas from the renderer. Compute the average of each pixel
                // for the number of samples so far.
                for i in 0 ..< output.buffer.count {
                    output.buffer[i] = canvas.buffer[i] // / Real(renderer.sampleCount)
                }

                let result = RenderResult(
                    renderId: id,
                    canvas: output,
                    duration: 0, //duration,
                    rayCount: renderer.rayCount,
                    sampleCount: renderer.sampleCount
                )
                handler(result)

            }
            Thread.exit()
        }
        thread?.name = "Render Worker \(id)"
        thread?.qualityOfService = .userInteractive
        thread?.start()
    }
    
    deinit {
        thread?.cancel()
    }
}


final class RenderManager {
    
    typealias ImageCallback = (CGImage) -> Void
    
    private var imageCallback: ImageCallback?
    private var renderCount: Int
    private var totalSamples: Int
    private var totalRays: Int
    private var raysPerSecond: Double
    private var startTime: TimeInterval
    private var workers = [RenderWorker]()
    
    private var lock = os_unfair_lock()
    private let concurrency: Int
    private let tempCanvas: Canvas
    private let outputCanvas: Canvas

    init(concurrency: Int, scene: RenderScene, viewport: Viewport, configuration: Renderer.Configuration) {
        logger.info("Renderer concurrency \(concurrency)")
        logger.info("Renderer viewport \(viewport.width)x\(viewport.height)")
        self.concurrency = concurrency
        self.tempCanvas = Canvas(width: viewport.width, height: viewport.height)
        self.outputCanvas = Canvas(width: viewport.width, height: viewport.height)
        self.renderCount = 0
        self.raysPerSecond = 0
        self.totalRays = 0
        self.totalSamples = 0
        self.startTime = CFAbsoluteTimeGetCurrent()
        for i in 0 ..< concurrency {
            let worker = RenderWorker(
                id: i,
                viewport: viewport,
                scene: scene,
                configuration: configuration,
                handler: { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    self.updateOutput(result)
                }
            )
            workers.append(worker)
        }
    }
    
    func onImage(_ imageCallback: @escaping ImageCallback) {
        self.imageCallback = imageCallback
    }
    
    private func updateOutput(_ result: RenderResult) {
//        self.lock.lock()
        os_unfair_lock_lock(&lock)
        renderCount += 1
        totalSamples += result.sampleCount

        // Copy the canvas from the renderer. Compute the average of each pixel
        // for the number of samples so far.
        for i in 0 ..< tempCanvas.buffer.count {
            tempCanvas.buffer[i] += result.canvas.buffer[i]
        }
        
        // Copy the temp canvas to the output canvas. For each pixel, compute
        // the average over the number of renders.
//        var minColor = +Real.greatestFiniteMagnitude
//        var maxColor = -Real.greatestFiniteMagnitude
        for i in 0 ..< outputCanvas.buffer.count {
            var color = tempCanvas.buffer[i] / Real(totalSamples)
//            minColor = min(minColor, color.x, color.y, color.z)
            color.x = min(color.x, 1)
            color.y = min(color.y, 1)
            color.z = min(color.z, 1)
//            let color = tempCanvas.buffer[i] / Real(totalSamples)
            outputCanvas.buffer[i] = color
        }
        
//        let colorRange = 1 / maxColor
//        for i in 0 ..< outputCanvas.buffer.count {
//            outputCanvas.buffer[i] *= colorRange
//        }
        
        let image = makeImage()
        
        let workerRaysPerSecond = Real(result.rayCount) / result.duration
        self.totalRays += result.rayCount
        self.raysPerSecond += workerRaysPerSecond
        os_unfair_lock_unlock(&lock)
//        self.lock.unlock()

        // let averageRaysPerSecond = raysPerSecond / Real(renderCount)
        let totalTime = CFAbsoluteTimeGetCurrent() - startTime
        let averageRaysPerSecond = Real(totalRays) / totalTime

        logger.info("Average rays per second \(averageRaysPerSecond.formatted())")

        DispatchQueue.main.async {
            
            if let image = image {
                self.imageCallback?(image)
            }

//            logger.info("Render #\(self.renderCount.formatted()) (worker \(result.renderId))")
//            logger.info("Worker duration \(result.duration.formatted()) seconds")
//            logger.info("Worker rays \(result.rayCount.formatted())")
//            logger.info("Worker rays per second \(workerRaysPerSecond.formatted())")
//            logger.info("Total time \(totalTime.formatted()) seconds")
//            logger.info("Total rays \(self.totalRays.formatted())")
        }
    }
    
    func makeImage() -> CGImage? {
        return outputCanvas.makeImage()
    }
}


final class RenderController: ObservableObject {
    
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
        self.manager.onImage { image in
            DispatchQueue.main.async {
                self.setImage(image)
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
