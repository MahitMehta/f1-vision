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
        WindowGroup(id: "home") {
            NewContentView(eventDeployer: eventDeployer)
        }
        // Radio Window
        WindowGroup(id: "radio", for: RadioViewProps.self) { data in
            RadioView(
                driverProps: data.wrappedValue ?? nil
            )
        }
        .defaultSize(width: 325, height: 250)
        .windowStyle(.plain)
        .defaultWindowPlacement { content, context in
            guard let dashboard = context.windows.first(where: { $0.id == "race-video" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.leading(dashboard))
        }
        
        WindowGroup(id: "driver-details") {
            DriverDetailsView(
                driverId: selectedDriver ?? 1,
                carStats: CarStatistics(speed: 315, brake: 0, n_gear: 8, rpm: 11141, throttle: 99, drs: 12)
            )
        }
        .defaultSize(width: 400, height: 600)
        /*.defaultWindowPlacement { content, context in
            guard let dashboard = context.windows.first(where: { $0.id == "race-video" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.trailing(dashboard))
        }*/
        
        WindowGroup(id: "event-notif", for: NotificationViewProps.self) { data in
            NotificationView(
                contentProps: data.wrappedValue ?? nil
            )
            .frame(minWidth: 500, idealWidth: 500, maxWidth: 600, minHeight: 40)
        }
        .defaultSize(width: 500, height: 40)
        .windowStyle(.plain)
        .defaultWindowPlacement { content, context in
            guard let radio = context.windows.first(where: { $0.id == "radio" }) else {
                guard let dashboard = context.windows.first(where: { $0.id == "race-video" }) else {
                    return WindowPlacement(nil)
                }
                return WindowPlacement(.leading(dashboard))
            }
            return WindowPlacement(.below(radio))
        }
        WindowGroup(id: "commentary-video", for: VideoViewProps.self) { data in
            if let val = data.wrappedValue {
                VideoView(videoURL: val.url)
            } else {
                EmptyView()
            }
        }
        .defaultWindowPlacement { content, context in
            guard let video = context.windows.first(where: { $0.id == "race-video" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.above(video))
        }
        WindowGroup(id: "race-video") {
            if let url = Bundle.main.url(forResource: "race", withExtension: "mp4") {
                VideoView(videoURL: url)
            } else {
                EmptyView()
            }
        }
        .windowStyle(.automatic)
        .defaultWindowPlacement { content, context in
            guard let home = context.windows.first(where: { $0.id == "home" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.replacing(home))
        }
        
        WindowGroup(id: "race-track") {
            RaceTrackView()
        }
        .windowStyle(.volumetric)
        .defaultWindowPlacement { content, context in
            guard let dashboard = context.windows.first(where: { $0.id == "race-video" }) else { return WindowPlacement(nil)
            }
            return WindowPlacement(.below(dashboard))
        }
        WindowGroup(id: "dashboard") {
            LeaderboardView(eventDeployer: eventDeployer)
        }
        .defaultSize(width: 1100, height: 1500)
        .defaultWindowPlacement { content, context in
            guard let raceVideo = context.windows.first(where: { $0.id == "race-video" }) else {
                return WindowPlacement(nil)
            }
            return WindowPlacement(.trailing(raceVideo))
        }
    }
}
