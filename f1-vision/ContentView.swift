//
//  ContentView.swift
//  f1-vision
//
//  Created by Nivan Gujral on 2/21/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showRaceTrack: Bool = false
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    let raceEvents : [RaceEvent] = loadJSON("bahrain_events") ?? []
    var eventDeployer: EventDeployer = .init()
    
    var body: some View {
        VStack {
            Text("F1 - Vision")
            Toggle("Show Race Track", isOn: $showRaceTrack)
                .onChange(of: showRaceTrack) { value in
                    Task {
                        for event in raceEvents {
                            await eventDeployer.subscribe(key: Int(event.time)) {
                                DispatchQueue.main.async {
                                    openWindow(id: "event-notif")
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
    ContentView()
        .environment(AppModel())
}
