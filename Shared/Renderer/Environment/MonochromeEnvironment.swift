import Foundation


struct MonochromeEnvironment: Sky {
    
    var color = Color(x: 1.0, y: 0.0, z: 1.0)

    func color(ray: Ray) -> Color {
        self.color
    }
    
    func copy() -> AnySky {
        AnySky(
            MonochromeEnvironment(
                color: color
            )
        )
    }
}



