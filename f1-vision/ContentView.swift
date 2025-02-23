import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    let eventDeployer: EventDeployer
    
    @State private var showRaceTrack: Bool = false
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    let raceEvents : [RaceEvent] = loadJSON("bahrain_events") ?? []
    
    var body: some View {
        VStack {
            Text("F1 - Vision")
            Toggle("Show Race Track", isOn: $showRaceTrack)
                .onChange(of: showRaceTrack) { value in
                    Task {
                        for event in raceEvents {
                            await eventDeployer.subscribe(key: Int(event.time)) {
                                
                                if event.type == "Radio" {
                                    let radioMessageParts = event.message.split(separator: " ")
                                    let radioDriverId = Int(radioMessageParts[1].replacingOccurrences(of: ":", with: ""))
                                    let radioMessageID = radioMessageParts[2]
                                    
                                    DispatchQueue.main.async {
                                        openWindow(id: "radio", value: RadioViewProps(
                                            driver: "Driver: \(String(describing: radioDriverId))",
                                            audioURL: "https://livetiming.formula1.com/static/2024/2024-03-02_Bahrain_Grand_Prix/2024-03-02_Race/TeamRadio/\(radioMessageID).mp3")
                                        )
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        openWindow(id: "event-notif")
                                    }
                                }
                            }
                        }
                        await eventDeployer.run_loop()
                        
                        if value {
                            openWindow(id: "race-track")
                        } else {
                            dismissWindow(id: "race-track")
                        }
                    }
                }
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(eventDeployer: EventDeployer.init())
        .environment(AppModel())
}
