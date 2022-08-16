import Foundation


final class RenderScene {
    
    let camera: Camera
    let sky: AnySky
    let world: AnyHitable
    
    init(
        camera: Camera,
        sky: AnySky = SkyGradientEnvironment().copy(),
        world: AnyHitable
    ) {
        self.camera = camera
        self.sky = sky
        self.world = world
    }
    
    func copy() -> RenderScene {
        RenderScene(
            camera: camera.copy(),
            sky: sky.copy(),
            world: world.copy()
        )
    }
}
