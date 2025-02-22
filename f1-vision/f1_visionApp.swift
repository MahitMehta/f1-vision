//
//  f1_visionApp.swift
//  f1-vision
//
//  Created by Nivan Gujral on 2/21/25.
//

import SwiftUI

@main
struct f1_visionApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        // Main ContentView Window
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        // Separate LeaderboardView Window
        WindowGroup("Leaderboard") {
            LeaderboardView()
                .environment(appModel) // Pass the same environment if needed
        }

        // Immersive Space
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}

