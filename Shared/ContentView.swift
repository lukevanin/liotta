import SwiftUI

struct ContentView: View {
    
    @ObservedObject var controller = RenderController(
        renderer: Renderer(
            configuration: Renderer.Configuration(
                width: 200,
                height: 100
            )
        ),
        queue: DispatchQueue(
            label: "render-queue",
            qos: .userInitiated,
            attributes: [],
            autoreleaseFrequency: .workItem,
            target: .none
        )
    )
    
    var body: some View {
        ZStack {
            if let image = controller.image {
                Image(image, scale: 0.25, label: Text("An image. There are many like it, but this one is mine."))
            }
            else {
                ProgressView()
            }
        }
        .frame(width: 800, height: 400)
        .background(.mint)
        .onAppear() {
            controller.render(scene: RenderScene())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
