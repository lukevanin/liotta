import SwiftUI

struct ContentView: View {
    
    @ObservedObject var controller = RenderController(
        manager: RenderManager(
            concurrency: 2,
            scene: makeChapter11Scene(),
            width: 400, height: 200,
            configuration: Renderer.Configuration()
        )
    )
    
    var body: some View {
        ZStack {
            if let image = controller.image {
                Image(image, scale: 0.5, label: Text("An image. There are many like it, but this one is mine."))
            }
            else {
                ProgressView()
            }
        }
        .frame(width: 800, height: 400)
        .background(.mint)
        .onAppear() {
            controller.startRenderer()
        }
        .onDisappear() {
            controller.stopRenderer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
