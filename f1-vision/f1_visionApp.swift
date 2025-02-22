import SwiftUI

@main
struct f1_visionApp: App {
    var body: some Scene {
        WindowGroup(id: "radio") {
            RadioView(
                driver: "Lewis Hamilton",
                audioUrl: "https://livetiming.formula1.com/static/2023/2023-09-17_Singapore_Grand_Prix/2023-09-15_Practice_1/TeamRadio/SERPER01_11_20230915_113201.mp3"
            )
        }
        .defaultSize(width: 325, height: 250)
        .windowStyle(.plain)
        
        WindowGroup(id: "content") {
            ContentView()
        }
    }

}
