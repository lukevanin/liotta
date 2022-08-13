import Foundation
import simd


func makeChapter11Scene() -> RenderScene {
    RenderScene(
        camera: {
            let lookFrom = Vector3(x: 3, y: 3, z: 2)
            let lookAt = Vector3(x: 0, y: 0, z: -1)
            let focusDistance = simd_length(lookFrom - lookAt)
            return Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                vup: Vector3(x: 0, y: 1, z: 0),
                fieldOfView: 20,
                aspectRatio: 200.0 / 100.0,
                aperature: 2,
                focusDistance: focusDistance
            )
        }(),
        world: HitableList(items: [
            Sphere(
                center: Vector3(x: 0, y: 0, z: -1),
                radius: 0.5,
                material: LambertianMaterial(
                    albedo: Vector3(x: 0.1, y: 0.2, z: 0.5)
                )
            ),
            Sphere(
                center: Vector3(x: 0, y: -100.5, z: -1),
                radius: 100,
                material: LambertianMaterial(
                    albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
                )
            ),
            Sphere(
                center: Vector3(x: 1, y: 0, z: -1),
                radius: 0.5,
                material: MetalMaterial(
                    albedo: Vector3(x: 0.8, y: 0.6, z: 0.2),
                    fuzz: 0.0
                )
            ),
            Sphere(
                center: Vector3(x: -1, y: 0, z: -1),
                radius: 0.5,
                material: DielectricMaterial(
                    refractionIndex: 1.5
                )
            ),
            Sphere(
                center: Vector3(x: -1, y: 0, z: -1),
                radius: -0.45,
                material: DielectricMaterial(
                    refractionIndex: 1.5
                )
            ),
        ])
    )
}


func makeChapter12Scene() -> RenderScene {
    var list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: LambertianMaterial(
                albedo: Vector3(x: 0.5, y: 0.5, z: 0.5)
            )
        )
    )
    list.append(
        Sphere(
            center: Vector3(x: 0, y: 1, z: 0),
            radius: 1.0,
            material: DielectricMaterial(
                refractionIndex: 1.5
            )
        )
    )
    list.append(
        Sphere(
            center: Vector3(x: -4, y: 1, z: 0),
            radius: 1,
            material: LambertianMaterial(
                albedo: Vector3(x: 0.4, y: 0.2, z: 0.1)
            )
        )
    )
    list.append(
        Sphere(
            center: Vector3(x: 4, y: 1, z: 0),
            radius: 1,
            material: MetalMaterial(
                albedo: Vector3(x: 0.7, y: 0.6, z: 0.5),
                fuzz: 0
            )
        )
    )
    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -11 ..< 11 {
        for b in -11 ..< 11 {
            let center = Vector3(
                x: Real(a) + 0.9 * .random(),
                y: 0.2,
                z: Real(b) + 0.9 * .random()
            )
            if simd_length(center - reference) > 0.9 {
                let chooseMaterial = Real.random()
                let material: Material
                if chooseMaterial < 0.8 {
                    material = LambertianMaterial(
                        albedo: Vector3(
                            x: .random() * .random(),
                            y: .random() * .random(),
                            z: .random() * .random()
                        )
                    )
                }
                else if chooseMaterial < 0.95 {
                    material = MetalMaterial(
                        albedo: Vector3(
                            x: 0.5 * (1 * .random()),
                            y: 0.5 * (1 * .random()),
                            z: 0.5 * (1 * .random())
                        ),
                        fuzz: 0.5 * .random()
                    )
                }
                else {
                    material = DielectricMaterial(
                        refractionIndex: 1.5
                    )
                }
                list.append(
                    Sphere(
                        center: center,
                        radius: 0.2,
                        material: material
                    )
                )
            }
        }
    }
    return RenderScene(
        camera: Camera(
            lookFrom: Vector3(x: 13, y: 2, z: 3),
            lookAt: Vector3(x: 0, y: 0, z: 0),
            vup: Vector3(x: 0, y: 1, z: 0),
            fieldOfView: 20,
            aspectRatio: 200.0 / 100.0,
            aperature: 0.1,
            focusDistance: 10
        ),
        world: list
    )
}
