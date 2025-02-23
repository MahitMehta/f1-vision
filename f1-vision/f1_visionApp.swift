import SwiftUI

@main
struct f1_visionApp: App {
    var body: some Scene {
        
        WindowGroup() {
            LeaderboardView()
        }
        WindowGroup(id: "race-track") {
            RaceTrackView()
        }.windowStyle(.volumetric)
        
        // Radio Window
        WindowGroup(id: "radio") {
            RadioView(
                driver: "Lewis Hamilton",
                audioUrl: "https://livetiming.formula1.com/static/2023/2023-09-17_Singapore_Grand_Prix/2023-09-15_Practice_1/TeamRadio/SERPER01_11_20230915_113201.mp3"
            )
        }
        .defaultSize(width: 325, height: 250)
        .windowStyle(.plain)
        
        WindowGroup(id: "driver-details") {
            DriverDetailsView(
                driver: selectedDriver ?? Driver(name: "Unknown", number: "0", nationality: "Unknown", position: 0, photo: "default"),
                    carStats: CarStatistics(speed: 315, brake: 0, n_gear: 8, rpm: 11141, throttle: 99, drs: 12)
            )
        }
        .defaultSize(width: 400, height: 600)
        .windowStyle(.plain)
       
    }
}
