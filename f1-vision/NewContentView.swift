import SwiftUI
import RealityKit
import RealityKitContent

struct CommentaryEvent : Codable {
    let type: String
    let timestamp: Float
    let description: String
}

struct CommentaryEventWrapper : Codable {
    let event: CommentaryEvent
    let commentary: String
}

struct NewContentView: View {
    let eventDeployer: EventDeployer
    
    @State private var showRaceTrack: Bool = false
    
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    let raceEvents: [RaceEvent] = loadJSON("bahrain_events") ?? []
    let commentaryEvents: [CommentaryEventWrapper] = loadJSON("f1_commentary2") ?? []
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Welcome to F1 Vision!")
                    .font(.extraLargeTitle2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.leading, 20)
                
                TabView {
                    VStack {
                        Text("2024 Gulf Air Bahrain Grand Prix")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Image("bahrain_map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .padding(.leading, 20)
                            .tag(0)
                    }
                    
                    VStack {
                        Text("2024 Italian Grand Prix")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Image("italian_map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .padding(.leading, 20)
                            .tag(1)
                    }
                    
                    VStack {
                        Text("2024 Singapore Grand Prix")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Image("singapore_map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .padding(.leading, 20)
                            .tag(1)
                    }
                }
                .frame(width: 400, height: 500)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.leading, 20)
                
                Spacer()
                
                Button(action: {
                    Task {
                        for event in raceEvents {
                            await eventDeployer.subscribe(key: Int(event.time)) {
                                
                                if event.type == "Radio" {
                                    let radioMessageParts = event.message.split(separator: " ")
                                    let radioDriverId = Int(radioMessageParts[1].replacingOccurrences(of: ":", with: ""))
                                    let radioMessageID = radioMessageParts[2]
                                    
                                    DispatchQueue.main.async {
                                        openWindow(id: "radio", value: RadioViewProps(
                                            driver: "Driver: \(radioDriverId ?? -1)",
                                            audioURL: "https://livetiming.formula1.com/static/2024/2024-03-02_Bahrain_Grand_Prix/2024-03-02_Race/TeamRadio/\(radioMessageID).mp3")
                                        )
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        openWindow(id: "event-notif", value: NotificationViewProps(notificationMessage: event.message, displayDuration: 3.0))
                                    }
                                }
                            }
                        }
                        
                        for event_index in 0..<commentaryEvents.count {
                            let eventWrapper = commentaryEvents[event_index]
                            let timestamp = eventWrapper.event.timestamp
                            
                            if let url = Bundle.main.url(forResource: "\(event_index + 1)", withExtension: "mp4") {
                                await eventDeployer.subscribe(key: Int(timestamp)) {
                                    DispatchQueue.main.async {
                                        openWindow(id: "commentary-video", value: VideoViewProps(url: url))
                                    }
                                }
                            }
                        }
                        
                        await eventDeployer.run_loop()
                        
                        showRaceTrack.toggle()
                        if showRaceTrack {
                            openWindow(id: "race-video")
                        } else {
                            openWindow(id: "race-video")

                        }
                    }
                }) {
                    HStack {
                        Text("Immerse")
                            .font(.headline)
                            .padding(.vertical, 10)
                    }
                    .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 40)
                .padding(.bottom, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .cornerRadius(20)
    }
}

#Preview() {
    NewContentView(eventDeployer: EventDeployer())
        .frame(width: 600, height: 700)
}
