import Foundation
import simd


final class Camera {
    
    private let lookFrom: Vector3
    private let lookAt: Vector3
    private let vup: Vector3
    private let fieldOfView: Real
    private let aspectRatio: Real
    private let aperature: Real
    private let focusDistance: Real

    private let corner: Vector3
    private let horizontal: Vector3
    private let vertical: Vector3
    private let origin: Vector3
    private let u: Vector3
    private let v: Vector3
    private let w: Vector3
    private let lenseRadius: Real
    private let random = RandomNumberGenerator()
    
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
        self.lookFrom = lookFrom
        self.lookAt = lookAt
        self.vup = vup
        self.fieldOfView = fieldOfView
        self.aspectRatio = aspectRatio
        self.aperature = aperature
        self.focusDistance = focusDistance
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
        let rayDirection = lenseRadius * random.randomInUnitDisk()
        let offset = self.u * rayDirection.x + self.v * rayDirection.y
        return Ray(
            origin: origin + offset,
            direction: simd_normalize(corner + (u * horizontal) + (v * vertical) - origin - offset)
        )
    }
    
    func copy() -> Camera {
        Camera(
            lookFrom: lookFrom,
            lookAt: lookAt,
            vup: vup,
            fieldOfView: fieldOfView,
            aspectRatio: aspectRatio,
            aperature: aperature,
            focusDistance: focusDistance
        )
    }
}
