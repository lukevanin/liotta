import Foundation
import simd


func makeOneSphereScene() -> RenderScene {
    RenderScene(
        camera: {
            let lookFrom = Vector3(x: 0, y: 0, z: 0)
            let lookAt = Vector3(x: 0, y: 0, z: -1)
            let focusDistance = simd_length(lookFrom - lookAt)
            return Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                vup: Vector3(x: 0, y: 1, z: 0),
                fieldOfView: 90,
                aspectRatio: 200.0 / 100.0,
                aperature: 0.1,
                focusDistance: focusDistance
            )
        }(),
        world: AnyHitable(
            Sphere(
                center: Vector3(x: 0, y: 0, z: -1),
                radius: 0.5,
                material: AnyMaterial(
                    LambertianMaterial(
                        albedo: Vector3(x: 0.5, y: 0.2, z: 0.5)
                    )
                )
            )
        )
    )
}

func makeTwoSpheresScene() -> RenderScene {
    RenderScene(
        camera: {
            let lookFrom = Vector3(x: 0, y: 0, z: 0)
            let lookAt = Vector3(x: 0, y: 0, z: -1)
            let focusDistance = simd_length(lookFrom - lookAt)
            return Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                vup: Vector3(x: 0, y: 1, z: 0),
                fieldOfView: 90,
                aspectRatio: 200.0 / 100.0,
                aperature: 0.1,
                focusDistance: focusDistance
            )
        }(),
        world: AnyHitable(
            HitableList(
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            MetalMaterial(
                                albedo: Vector3(x: 0.8, y: 0.3, z: 0.3),
                                fuzz: 0
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: -100.5, z: -1),
                        radius: 100,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
                            )
                        )
                    )
                )
            )
        )
    )
}


func makeChapter9Scene() -> RenderScene {
    RenderScene(
        camera: {
            let lookFrom = Vector3(x: 0, y: 0, z: 0)
            let lookAt = Vector3(x: 0, y: 0, z: -1)
            let focusDistance = simd_length(lookFrom - lookAt)
            return Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                vup: Vector3(x: 0, y: 1, z: 0),
                fieldOfView: 90,
                aspectRatio: 200.0 / 100.0,
                aperature: 0.1,
                focusDistance: focusDistance
            )
        }(),
        world: AnyHitable(
            HitableList(
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.1, y: 0.2, z: 0.5)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: -100.5, z: -1),
                        radius: 100,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            MetalMaterial(
                                albedo: Vector3(x: 0.8, y: 0.6, z: 0.2),
                                fuzz: 0
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: -0.45,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                )
            )
        )
    )
}


func makeChapter10Scene() -> RenderScene {
    RenderScene(
        camera: {
            let lookFrom = Vector3(x: -2, y: 2, z: 1)
            let lookAt = Vector3(x: 0, y: 0, z: -1)
            let focusDistance = simd_length(lookFrom - lookAt)
            return Camera(
                lookFrom: lookFrom,
                lookAt: lookAt,
                vup: Vector3(x: 0, y: 1, z: 0),
                fieldOfView: 20,
                aspectRatio: 200.0 / 100.0,
                aperature: 0.1,
                focusDistance: focusDistance
            )
        }(),
        world: AnyHitable(
            HitableList(
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.1, y: 0.2, z: 0.5)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: -100.5, z: -1),
                        radius: 100,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            MetalMaterial(
                                albedo: Vector3(x: 0.8, y: 0.6, z: 0.2),
                                fuzz: 0
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: -0.45,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                )
            )
        )
    )
}

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
        world: AnyHitable(
            HitableList(
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.1, y: 0.2, z: 0.5)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 0, y: -100.5, z: -1),
                        radius: 100,
                        material: AnyMaterial(
                            LambertianMaterial(
                                albedo: Vector3(x: 0.8, y: 0.8, z: 0.0)
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: 1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            MetalMaterial(
                                albedo: Vector3(x: 0.8, y: 0.6, z: 0.2),
                                fuzz: 0.0
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: 0.5,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                ),
                AnyHitable(
                    Sphere(
                        center: Vector3(x: -1, y: 0, z: -1),
                        radius: -0.45,
                        material: AnyMaterial(
                            DielectricMaterial(
                                refractionIndex: 1.5
                            )
                        )
                    )
                )
            )
        )
    )
}


func makeChapter12Scene() -> RenderScene {
    let list = HitableList()
    list.append(
        AnyHitable(
            Sphere(
                center: Vector3(x: 0, y: -1000, z: 0),
                radius: 1000,
                material: AnyMaterial(
                    LambertianMaterial(
                        albedo: Vector3(x: 0.5, y: 0.5, z: 0.5)
                    )
                )
            )
        )
    )
    list.append(
        AnyHitable(
            Sphere(
                center: Vector3(x: 0, y: 1, z: 0),
                radius: 1.0,
                material: AnyMaterial(
                    DielectricMaterial(
                        refractionIndex: 1.5
                    )
                )
            )
        )
    )
    list.append(
        AnyHitable(
            Sphere(
                center: Vector3(x: -4, y: 1, z: 0),
                radius: 1,
                material: AnyMaterial(
                    LambertianMaterial(
                        albedo: Vector3(x: 0.4, y: 0.2, z: 0.1)
                    )
                )
            )
        )
    )
    list.append(
        AnyHitable(
            Sphere(
                center: Vector3(x: 4, y: 1, z: 0),
                radius: 1,
                material: AnyMaterial(
                    MetalMaterial(
                        albedo: Vector3(x: 0.7, y: 0.6, z: 0.5),
                        fuzz: 0
                    )
                )
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
                let material: AnyMaterial
                if chooseMaterial < 0.8 {
                    material = AnyMaterial(
                        LambertianMaterial(
                            albedo: Vector3(
                                x: .random() * .random(),
                                y: .random() * .random(),
                                z: .random() * .random()
                            )
                        )
                    )
                }
                else if chooseMaterial < 0.95 {
                    material = AnyMaterial(
                        MetalMaterial(
                            albedo: Vector3(
                                x: 0.5 * (1 * .random()),
                                y: 0.5 * (1 * .random()),
                                z: 0.5 * (1 * .random())
                            ),
                            fuzz: 0.5 * .random()
                        )
                    )
                }
                else {
                    material = AnyMaterial(
                        DielectricMaterial(
                            refractionIndex: 1.5
                        )
                    )
                }
                list.append(
                    AnyHitable(
                        Sphere(
                            center: center,
                            radius: 0.2,
                            material: material
                        )
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
        world: AnyHitable(list)
    )
}


func makeChapter12Scene2() -> RenderScene {
    let list = HitableList()
    list.append(
        AnyHitable(
            Sphere(
                center: Vector3(x: 0, y: -1000, z: 0),
                radius: 1000,
                material: AnyMaterial(
                    LambertianMaterial(
                        albedo: Vector3(x: 0.5, y: 0.5, z: 0.5)
                    )
                )
            )
        )
    )
    
    let center = Vector3(x: 4, y: 1, z: 0)
    list.append(
        AnyHitable(
            Sphere(
                center: center,
                radius: 1.0,
                material: AnyMaterial(
                    DielectricMaterial(
                        refractionIndex: 1.5
                    )
                )
            )
        )
    )
    
    // Bubbles
    let r = RandomNumberGenerator()
    for _ in 0 ..< 15 {
        list.append(
            AnyHitable(
                Sphere(
                    center: center + (r.randomInUnitSphere() * 0.7),
                    radius: -(0.01 + (r.next() * 0.05)),
                    material: AnyMaterial(
                        DielectricMaterial(
                            refractionIndex: 1.5
                        )
                    )
                )
            )
        )
    }
    
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
                let material: AnyMaterial
                if chooseMaterial < 0.8 {
                    material = AnyMaterial(
                        MetalMaterial(
                            albedo: Vector3(x: 0.1 + (.random() * 0.1), y: 0.1, z: 0.1 + (.random() * 0.1)),
                            fuzz: 0.1
                        )
                    )
                }
                else if chooseMaterial < 0.95 {
                    material = AnyMaterial(
                        MetalMaterial(
                            albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
                            fuzz: 0.1
                        )
                    )
                }
                else {
                    material = AnyMaterial(
                        MetalMaterial(
                            albedo: Vector3(x: 1.2, y: 0.85, z: 0.3),
                            fuzz: 0.1
                        )
                    )
                }
                list.append(
                    AnyHitable(
                        Sphere(
                            center: center,
                            radius: 0.2,
                            material: material
                        )
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
        world: AnyHitable(list)
    )
}


func makeLightingScene() -> RenderScene {
    
    let whiteLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 5)
    )
    
    let redLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 4, z: 4)
    )
    
    let greenLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 5, z: 4)
    )
    
    let blueLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 4, z: 5)
    )
    
    let yellowLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 4)
    )

    let whiteMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9)
    )
    
    let silverMaterial = MetalMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
        fuzz: 0.1
    )
    
    let glassMaterial = DielectricMaterial(
        refractionIndex: 1.5
    )
    
    let skyEnvironment = SkyGradientEnvironment(
        colorA: Color(x: 0.1, y: 0.1, z: 0.3),
        colorB: Color(x: 0.25, y: 0.35, z: 0.5)
    )
    
//    let skyEnvironment = SkyGradientEnvironment()

    let list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: whiteMaterial.copy()
        ).copy()
    )
    
    let center = Vector3(x: 4, y: 1, z: 0)
    list.append(
        Sphere(
            center: center,
            radius: 1.0,
            material: glassMaterial.copy()
        ).copy()
    )
    list.append(
        Sphere(
            center: center,
            radius: 0.9,
            material: whiteMaterial.copy()
        ).copy()
    )

    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -5 ..< 5 {
        for b in -5 ..< 5 {
            var center = Vector3(
                x: Real(a) * 1.5 + 0.9 * .random(),
                y: 0.4, // + (0.5 * .random()),
                z: Real(b) * 1.5 + 0.9 * .random()
            )
            if simd_length(center - reference) > 0.9 {
                let chooseMaterial = Real.random()
                let material: AnyMaterial
                if chooseMaterial < 0.8 {
                    let color = Int(floor(Real.random() * 5))
                    switch color {
                    case 0:
                        material = redLightMaterial.copy()
                    case 1:
                        material = greenLightMaterial.copy()
                    case 2:
                        material = blueLightMaterial.copy()
                    case 3:
                        material = yellowLightMaterial.copy()
                    default:
                        material = whiteLightMaterial.copy()
                    }
                    center.y = 3.0
                }
                else {
                    material = silverMaterial.copy()
                }
                list.append(
                    Sphere(
                        center: center,
                        radius: 0.4,
                        material: material
                    ).copy()
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
        sky: skyEnvironment.copy(),
        world: list.copy()
    )
}


func makeRectanglesScene() -> RenderScene {
    
    let whiteLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 5)
    )
    
    let redLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 4, z: 4)
    )
    
    let greenLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 5, z: 4)
    )
    
    let blueLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 4, z: 5)
    )
    
    let yellowLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 4)
    )

    let whiteMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9)
    )
    
    let silverMaterial = MetalMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
        fuzz: 0.01
    )
    
    let goldMaterial = MetalMaterial(
        albedo: Vector3(x: 1.2, y: 0.85, z: 0.3),
        fuzz: 0.1
    )
    
    let redMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.99, y: 0.1, z: 0.1)
    )

    let glassMaterial = DielectricMaterial(
        refractionIndex: 1.5
    )
    
    let skyEnvironment = SkyGradientEnvironment()

    let list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: whiteMaterial.copy()
        ).copy()
    )
    
    let center = Vector3(x: 4, y: 1, z: 0)
    list.append(
        Sphere(
            center: center,
            radius: 1.0,
            material: glassMaterial.copy()
        ).copy()
    )
//    list.append(
//        Sphere(
//            center: center,
//            radius: 1.0,
//            material: glassMaterial.copy()
//        ).copy()
//    )

    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -7 ..< 7 {
        for b in -7 ..< 7 {
            let center = Vector3(
                x: Real(a) * 1, // + 0.9 * .random(),
                y: 0, // + (0.5 * .random()),
                z: Real(b) * 1 // + 0.9 * .random()
            )
            if simd_length(center - reference) > 2 {
                let material: AnyMaterial = whiteMaterial.copy()
                let h = 0.2 + (.random() * 0.1)
//                let m = Real.random()
//                if m < 0.8 {
//                    material = whiteMaterial.copy()
//                }
//                else if m < 0.9 {
//                    material = glassMaterial.copy()
//                }
//                else {
//                    material = silverMaterial.copy()
//                }
                list.append(
                    XYRectangle(
                        x0: center.x - 0.5,
                        x1: center.x + 0.5,
                        y0: center.y,
                        y1: center.y + h,
                        z: center.z - 0.5,
                        material: material
                    ).copy()
                )
                list.append(
                    XYRectangle(
                        x0: center.x - 0.5,
                        x1: center.x + 0.5,
                        y0: center.y,
                        y1: center.y + h,
                        z: center.z + 0.5,
                        material: material
                    ).copy()
                )
                list.append(
                    YZRectangle(
                        x: center.x + 0.5,
                        y0: center.y,
                        y1: center.y + h,
                        z0: center.z - 0.5,
                        z1: center.z + 0.5,
                        material: material
                    ).copy()
                )
                list.append(
                    YZRectangle(
                        x: center.x - 0.5,
                        y0: center.y,
                        y1: center.y + h,
                        z0: center.z - 0.5,
                        z1: center.z + 0.5,
                        material: material
                    ).copy()
                )
                list.append(
                    XZRectangle(
                        x0: center.x - 0.5,
                        x1: center.x + 0.5,
                        y: center.y + h,
                        z0: center.z - 0.5,
                        z1: center.z + 0.5,
                        material: material
                    ).copy()
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
        sky: skyEnvironment.copy(),
        world: list.copy()
    )
}


func makeLightingRectanglesScene() -> RenderScene {
    
    let whiteLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 5)
    )
    
    let redLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 4, z: 4)
    )
    
    let greenLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 5, z: 4)
    )
    
    let blueLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 4, z: 5)
    )
    
    let yellowLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 4)
    )

    let whiteMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9)
    )
    
    let silverMaterial = MetalMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
        fuzz: 0.1
    )
    
    let goldMaterial = MetalMaterial(
        albedo: simd_normalize(Vector3(x: 1.2, y: 0.85, z: 0.3)),
        fuzz: 0.1
    )
    
    let redMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.99, y: 0.1, z: 0.1)
    )

    let glassMaterial = DielectricMaterial(
        refractionIndex: 1.5
    )
    
    let skyEnvironment = SkyGradientEnvironment()

    let list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: whiteMaterial.copy()
        ).copy()
    )
    
    let center = Vector3(x: 4, y: 1, z: 0)
//    list.append(
//        Sphere(
//            center: center,
//            radius: 0.9,
//            material: goldMaterial.copy()
//        ).copy()
//    )
    list.append(
        Sphere(
            center: center,
            radius: 1.0,
            material: goldMaterial.copy()
        ).copy()
    )

    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -5 ..< 5 {
        for b in -5 ..< 5 {
            var center = Vector3(
                x: Real(a) * 1.5 + 0.9 * .random(),
                y: 0.4, // + (0.5 * .random()),
                z: Real(b) * 1.5 + 0.9 * .random()
            )
            if simd_length(center - reference) > 0.9 {
                let chooseMaterial = Real.random()
                let material: AnyMaterial
                if chooseMaterial < 0.9 {
                    let color = Int(floor(Real.random() * 5))
                    switch color {
                    case 0:
                        material = redLightMaterial.copy()
                    case 1:
                        material = greenLightMaterial.copy()
                    case 2:
                        material = blueLightMaterial.copy()
                    case 3:
                        material = yellowLightMaterial.copy()
                    default:
                        material = whiteLightMaterial.copy()
                    }
                    center.y = 3.0
                    list.append(
                        Sphere(
                            center: center,
                            radius: 0.4,
                            material: material
                        ).copy()
                    )
                }
                else {
                    let material: AnyMaterial = whiteMaterial.copy()
                    let h = Real(1)
                    list.append(
                        XYRectangle(
                            x0: center.x - 0.5,
                            x1: center.x + 0.5,
                            y0: center.y,
                            y1: center.y + h,
                            z: center.z - 0.5,
                            material: material
                        ).copy()
                    )
                    list.append(
                        XYRectangle(
                            x0: center.x - 0.5,
                            x1: center.x + 0.5,
                            y0: center.y,
                            y1: center.y + h,
                            z: center.z + 0.5,
                            material: material
                        ).copy()
                    )
                    list.append(
                        YZRectangle(
                            x: center.x + 0.5,
                            y0: center.y,
                            y1: center.y + h,
                            z0: center.z - 0.5,
                            z1: center.z + 0.5,
                            material: material
                        ).copy()
                    )
                    list.append(
                        YZRectangle(
                            x: center.x - 0.5,
                            y0: center.y,
                            y1: center.y + h,
                            z0: center.z - 0.5,
                            z1: center.z + 0.5,
                            material: material
                        ).copy()
                    )
                    list.append(
                        XZRectangle(
                            x0: center.x - 0.5,
                            x1: center.x + 0.5,
                            y: center.y + h,
                            z0: center.z - 0.5,
                            z1: center.z + 0.5,
                            material: material
                        ).copy()
                    )
                }
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
        sky: skyEnvironment.copy(),
        world: list.copy()
    )
}


func makeLightingRectanglesScene2() -> RenderScene {
    
    let lightMaterial = MonochromeLightMaterial(
        color: Color(x: 4.2, y: 4.2, z: 4)
    )

    let whiteMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9)
    )
    
    let silverMaterial = MetalMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
        fuzz: 0.1
    )

    let goldMaterial = MetalMaterial(
        albedo: simd_normalize(Vector3(x: 1.2, y: 0.85, z: 0.3)),
        fuzz: 0.1
    )
    
    let redMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.99, y: 0.1, z: 0.1)
    )

    let glassMaterial = DielectricMaterial(
        refractionIndex: 1.5
    )
    
    let skyEnvironment = SkyGradientEnvironment(
        colorA: Color(x: 0.25, y: 0.35, z: 0.5),
        colorB: Color(x: 0.0, y: 0.0, z: 0.1)
    )
//    let skyEnvironment = SkyGradientEnvironment()

    let list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: whiteMaterial.copy()
        ).copy()
    )
    
    let center = Vector3(x: 4, y: 1.0, z: 0)
    list.append(
        Sphere(
            center: center,
            radius: 0.5,
            material: lightMaterial.copy()
        ).copy()
    )
//    list.append(
//        Sphere(
//            center: center,
//            radius: 0.7,
//            material: glassMaterial.copy()
//        ).copy()
//    )

    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -5 ..< 5 {
        for b in -5 ..< 5 {
            let center = Vector3(
                x: Real(a) * 1.5 + 0.9 * .random(),
                y: -0.1, // + (0.5 * .random()),
                z: Real(b) * 1.5 + 0.9 * .random()
            )
            if simd_length(center - reference) > 2 {
                let material: AnyMaterial
                let size = Vector3(
                    x: 0.25,
                    y: 0.5 + (.random() * 1.0),
                    z: 0.25
                )
                let m = Real.random()
                if  m < 0.5 {
                    material = whiteMaterial.copy()
                }
                else {
                    material = silverMaterial.copy()
                }
                list.append(
                    XYRectangle(
                        x0: center.x - size.x,
                        x1: center.x + size.x,
                        y0: center.y,
                        y1: center.y + size.y,
                        z: center.z - size.z,
                        normal: Vector3(x: 0, y: 0, z: +1),
                        material: material
                    ).copy()
                )
                list.append(
                    XYRectangle(
                        x0: center.x - size.x,
                        x1: center.x + size.x,
                        y0: center.y,
                        y1: center.y + size.y,
                        z: center.z + size.z,
                        normal: Vector3(x: 0, y: 0, z: -1),
                        material: material
                    ).copy()
                )
                list.append(
                    YZRectangle(
                        x: center.x + size.x,
                        y0: center.y,
                        y1: center.y + size.y,
                        z0: center.z - size.z,
                        z1: center.z + size.z,
                        normal: Vector3(x: +1, y: 0, z: 0),
                        material: material
                    ).copy()
                )
                list.append(
                    YZRectangle(
                        x: center.x - size.x,
                        y0: center.y,
                        y1: center.y + size.y,
                        z0: center.z - size.z,
                        z1: center.z + size.z,
                        normal: Vector3(x: -1, y: 0, z: 0),
                        material: material
                    ).copy()
                )
                list.append(
                    XZRectangle(
                        x0: center.x - size.x,
                        x1: center.x + size.x,
                        y: center.y + size.y,
                        z0: center.z - size.z,
                        z1: center.z + size.z,
                        normal: Vector3(x: 0, y: +1, z: 0),
                        material: material
                    ).copy()
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
        sky: skyEnvironment.copy(),
        world: list.copy()
    )
}


func make2001Scene() -> RenderScene {
    
    let whiteLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 5)
    )
    
    let redLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 4, z: 4)
    )
    
    let greenMaterial = LambertianMaterial(
        albedo: Color(x: 0.2, y: 0.6, z: 0.3)
    )
    
    let blueLightMaterial = MonochromeLightMaterial(
        color: Color(x: 4, y: 4, z: 5)
    )
    
    let yellowLightMaterial = MonochromeLightMaterial(
        color: Color(x: 5, y: 5, z: 4)
    )

    let whiteMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9)
    )
    
    let silverMaterial = MetalMaterial(
        albedo: Vector3(x: 0.9, y: 0.9, z: 0.9),
        fuzz: 0.01
    )
    
    let goldMaterial = MetalMaterial(
        albedo: Vector3(x: 1.2, y: 0.85, z: 0.3),
        fuzz: 0.1
    )
    
    let redMaterial = LambertianMaterial(
        albedo: Vector3(x: 0.99, y: 0.1, z: 0.1)
    )

    let glassMaterial = DielectricMaterial(
        refractionIndex: 1.5
    )

    let airMaterial = DielectricMaterial(
        refractionIndex: -1.5
    )

    let blackMaterial = MetalMaterial(
        albedo: Vector3(x: 0.1, y: 0.1, z: 0.1),
        fuzz: 0.1
    )
    
    let skyEnvironment = SkyGradientEnvironment(
        colorA: Color(x: 0.1, y: 0.1, z: 0.3),
        colorB: Color(x: 0.25, y: 0.35, z: 0.5)
    )

    let list = HitableList()
    list.append(
        Sphere(
            center: Vector3(x: 0, y: -1000, z: 0),
            radius: 1000,
            material: greenMaterial.copy()
        ).copy()
    )
    
    let center = Vector3(x: 2, y: 0, z: 0)
    let size = Vector3(x: 0.8, y: 2.1, z: 0.3)
    let material = blackMaterial.copy()
    list.append(
        XYRectangle(
            x0: center.x - size.x,
            x1: center.x + size.x,
            y0: center.y,
            y1: center.y + size.y,
            z: center.z - size.z,
            material: material
        ).copy()
    )
    list.append(
        XYRectangle(
            x0: center.x - size.x,
            x1: center.x + size.x,
            y0: center.y,
            y1: center.y + size.y,
            z: center.z + size.z,
            material: material
        ).copy()
    )
    list.append(
        YZRectangle(
            x: center.x + size.x,
            y0: center.y,
            y1: center.y + size.y,
            z0: center.z - size.z,
            z1: center.z + size.z,
            material: material
        ).copy()
    )
    list.append(
        YZRectangle(
            x: center.x - size.x,
            y0: center.y,
            y1: center.y + size.y,
            z0: center.z - size.z,
            z1: center.z + size.z,
            material: material
        ).copy()
    )
    list.append(
        XZRectangle(
            x0: center.x - size.x,
            x1: center.x + size.x,
            y: center.y + size.y,
            z0: center.z - size.z,
            z1: center.z + size.z,
            material: material
        ).copy()
    )
    let reference = Vector3(x: 4, y: 0.2, z: 0)
    for a in -7 ..< 7 {
        for b in -7 ..< 7 {
            let center = Vector3(
                x: Real(a) * 1.2 + 0.9 * .random(),
                y: 0.2,
                z: Real(b) * 1.2 + 0.9 * .random()
            )
            if simd_length(center - reference) > 2 {
                list.append(
                    Sphere(center: center, radius: 0.2, material: whiteMaterial.copy()).copy()
                )
            }
        }
    }
    return RenderScene(
        camera: Camera(
            lookFrom: Vector3(x: 6, y: 1, z: 8),
            lookAt: Vector3(x: 0, y: 1, z: 0),
            vup: Vector3(x: 0, y: 1, z: 0),
            fieldOfView: 20,
            aspectRatio: 200.0 / 100.0,
            aperature: 0.1,
            focusDistance: 10
        ),
        sky: skyEnvironment.copy(),
        world: list.copy()
    )
}
