import SwiftUI

actor EventDeployer {
    private var events: [Int : [() -> Void]]
    private var handle: Task<(), Never>?
    private var loopStartTime = 0.0;
    private var elapsedTime: Double = 0.0
    
    init() {
        events = [:]
    }
    
    func subscribe(key: Int, _ event: @escaping () -> Void) async {        
        if events[key] == nil {
            events[key] = [event]
        } else {
            events[key]?.append(event)
        }
    }
    
    func getElapsedTime() -> Double {
        return self.elapsedTime
    }
 
    func run_loop() {
        self.loopStartTime = Date().timeIntervalSince1970
        
        let handle = Task {
            // 1 second freq.
            while true {
                self.elapsedTime = Date().timeIntervalSince1970 - self.loopStartTime

                let intRepresentationOfTime = Int(self.elapsedTime);
                
                if let cbs = events[intRepresentationOfTime] {
                    for cb in cbs {
                        cb()
                    }
                }
                
                try? await Task.sleep(nanoseconds: UInt64(1 * 1_000_000_000))
            }
        }
        self.handle = handle
    }
}

struct RaceEvent : Codable {
    let type: String
    let time: Float
    let message: String
}

@main
struct f1_visionApp: App {
    var eventDeployer: EventDeployer = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView(eventDeployer: eventDeployer)
                .frame(width: 600, height: 700)
        }
        WindowGroup(id: "dashboard") {
            LeaderboardView(eventDeployer: eventDeployer)
        }
        WindowGroup(id: "race-track") {
            RaceTrackView()
        }.windowStyle(.volumetric)
        
        // Radio Window
        WindowGroup(id: "radio", for: RadioViewProps.self) { data in
            RadioView(
                driverProps: data.wrappedValue ?? nil
            )
        }
        .defaultSize(width: 325, height: 250)
        .windowStyle(.plain)
        
        WindowGroup(id: "driver-details") {
            DriverDetailsView(
                driverId: selectedDriver ?? 1,
                carStats: CarStatistics(speed: 315, brake: 0, n_gear: 8, rpm: 11141, throttle: 99, drs: 12)
            )
        }
        .defaultSize(width: 400, height: 600)
        
        WindowGroup(id: "event-notif", for: NotificationViewProps.self) { data in
            NotificationView(
                contentProps: data.wrappedValue ?? nil
            )
        }
        
        WindowGroup(id: "video", for: VideoViewProps.self) { data in
            VideoView(
                videoContent: data.wrappedValue ?? nil
            )
        }
        
    }
}
