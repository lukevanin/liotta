import Foundation


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
