//
//  LiottaApp.swift
//  Shared
//
//  Created by Luke Van In on 2022/08/12.
//

import SwiftUI

@main
struct LiottaApp: App {
    
    let renderController = RenderController(
        manager: RenderManager(
            concurrency: 2,
//            scene: makeOneSphereScene(),
//            scene: makeTwoSpheresScene(),
//            scene: makeChapter9Scene(),
//            scene: makeChapter10Scene(),
//            scene: makeChapter11Scene(),
//            scene: makeChapter12Scene(),
//            scene: makeChapter12Scene2(),
            scene: makeLightingTestScene(),
            viewport: Viewport(width: 400, height: 200),
            configuration: {
                let configuration = Renderer.Configuration()
                configuration.samplesPerPixel = 10000
                configuration.samplesPerIteration = 10
                configuration.maximumBounces = 100
                return configuration
            }()
        )
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(renderController)
        }
    }
}
