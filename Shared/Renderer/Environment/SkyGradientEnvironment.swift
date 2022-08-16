import Foundation
import simd


struct SkyGradientEnvironment: Sky {
    
    var colorA = Color(x: 1.0, y: 1.0, z: 1.0)
    var colorB = Color(x: 0.5, y: 0.7, z: 1.0)

    func color(ray: Ray) -> Color {
        let unitDirection = simd_normalize(ray.direction)
        let t = 0.5 * (unitDirection.y + 1.0)
        return ((1 - t) * colorA) + (t * colorB)
    }
    
    func copy() -> AnySky {
        AnySky(
            SkyGradientEnvironment(
                colorA: colorA,
                colorB: colorB
            )
        )
    }
}



