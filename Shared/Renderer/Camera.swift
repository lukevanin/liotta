import Foundation
import simd


struct Camera {
    var corner: Vector3
    var horizontal: Vector3
    var vertical: Vector3
    var origin: Vector3
    var u: Vector3
    var v: Vector3
    var w: Vector3
    var lenseRadius: Real
    
    init(
        lookFrom: Vector3,
        lookAt: Vector3,
        vup: Vector3,
        fieldOfView: Real,
        aspectRatio: Real,
        aperature: Real,
        focusDistance: Real
    ) {
        let theta = fieldOfView * .pi / 180
        let halfHeight = tan(theta / 2)
        let halfWidth = aspectRatio * halfHeight
        let origin = lookFrom
        let w = simd_normalize(lookFrom - lookAt) // view direction
        let u = simd_normalize(simd_cross(vup, w)) // perpendicular to vup and view direction (view x-axis)
        let v = simd_normalize(simd_cross(w, u)) // perpendicular to view direction and view x-axis (view y-axis)
        let xAxis = halfWidth * focusDistance * u
        let yAxis = halfHeight * focusDistance * v
        let corner = origin - xAxis - yAxis - (focusDistance * w)
        let horizontal = 2 * xAxis
        let vertical = 2 * yAxis
        logger.info("Camera origin \(origin)")
        logger.info("Camera w (view direction) \(w)")
        logger.info("Camera u (view horizontal axis) \(u)")
        logger.info("Camera v (view vertical axis) \(u)")
        logger.info("Camera aperature \(aperature)")
        logger.info("Camera focus distance \(focusDistance)")
        self.origin = origin
        self.corner = corner
        self.horizontal = horizontal
        self.vertical = vertical
        self.u = u
        self.v = v
        self.w = w
        self.lenseRadius = aperature / 2
    }

    func rayAt(u: Real, v: Real) -> Ray {
        let rayDirection = lenseRadius * Vector3.randomInUnitDisk()
        let offset = self.u * rayDirection.x + self.v * rayDirection.y
        return Ray(
            origin: origin + offset,
            direction: simd_normalize(corner + (u * horizontal) + (v * vertical) - origin - offset)
        )
    }
}
