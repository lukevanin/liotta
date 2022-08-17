import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var controller: RenderController
    
    var body: some View {
        ZStack {
            if let image = controller.image {
                Image(image, scale: 1.0, label: Text("An image. There are many like it, but this one is mine."))
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
