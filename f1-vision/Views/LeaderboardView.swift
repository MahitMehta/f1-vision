import SwiftUI

var selectedDriver: Int?

struct DriverLapsData : Codable, Identifiable {
    let id: Int
    let positions: [[Float]]
}

struct LeaderboardView: View {
    let driversLapsData: [DriverLapsData] = loadJSON("bahrain_lap_data") ?? []
    let overtakes: [Overtake] = loadJSON("overtake_data") ?? []
    
    var eventDeployer: EventDeployer
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var trackTime = "00:00:00.000"
    @State private var elapsedTime: Double = 0.0
    
    
    // Temporary track data
    
    var rainPercentage = 0
    var windSpeed = 1.2
    var trackTemp = 26.5
    var airTemp = 18.9
    
    func formatElapsedTime(elapsedTime: Double) -> String {
            let hours = Int(elapsedTime) / 3600
            let minutes = (Int(elapsedTime) % 3600) / 60
            let seconds = Int(elapsedTime) % 60
            let milliseconds = Int((elapsedTime - Double(Int(elapsedTime))) * 1000)
            
            return String(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
        }
    
    typealias LeaderboardEntry = (Int, String, String, String, String, Int, String, String, [String])
    
    @State private var leaderboard: [LeaderboardEntry] = [
        (1, "VER", "Red Bull Racing", "M", "disabled", 0, "0.000", "00.000", ["00.000", "00.000"]),
        (11, "PER", "Red Bull Racing", "S", "pit", 0, "+5.123", "00.000", ["00.000", "00.000"]),
        (44, "HAM", "Mercedes", "H", "on", 0, "+12.345", "00.000", ["00.000", "00.000", "00.000"]),
        (14, "ALO", "Aston Martin", "M", "off", 0, "+15.678", "00.000", ["00.000", "00.000"]),
        (16, "LEC", "Ferrari", "I", "enabled", 0, "+20.234", "00.000", ["00.000", "00.000"]),
        (4, "NOR", "McLaren", "W", "disabled", 0, "+25.789", "00.000", ["00.000", "00.000"]),
        (55, "SAI", "Ferrari", "S", "pit", 0, "+30.123", "00.000", ["00.000", "00.000"]),
        (63, "RUS", "Mercedes", "H", "on", 0, "+35.678", "00.000", ["00.000", "00.000"]),
        (81, "PIA", "McLaren", "M", "off", 0, "+40.234", "00.000", ["00.000", "00.000"]),
        (18, "STR", "Aston Martin", "W", "enabled", 0, "+45.123", "00.000", ["00.000", "00.000"]),
        (10, "GAS", "Alpine", "I", "disabled", 0, "+50.567", "00.000", ["00.000", "00.000"]),
        (31, "OCO", "Alpine", "S", "on", 0, "+55.234", "00.000", ["00.000", "00.000"]),
        (23, "ALB", "Williams", "H", "pit", 0, "+60.345", "00.000", ["00.000", "00.000"]),
        (22, "TSU", "RB Honda RBPT", "M", "off", 0, "+65.678", "00.000", ["00.000", "00.000"]),
        (77, "BOT", "Kick Sauber", "W", "enabled", 0, "+70.123", "00.000", ["00.000", "00.000"]),
        (27, "HUL", "Haas Ferrari", "S", "on", 0, "+75.678", "00.000", ["00.000", "00.000"]),
        (23, "RIC", "RB", "H", "pit", 0, "+80.234", "00.000", ["00.000", "00.000"]),
        (24, "ZHO", "Kick Sauber", "I", "disabled", 4, "+85.123", "00.000", ["00.000", "00.000"]),
        (20, "MAG", "Haas", "M", "enabled", 0, "+90.678", "00.000", ["00.000", "00.000"]),
        (30, "LAW", "RB", "W", "off", 0, "+95.345", "00.000", ["00.000", "00.000"]),
        (2, "SAR", "Williams", "S", "on", 0, "+100.789", "00.000", ["00.000", "00.000"])
    ]
    
    func overtake(car1: Int, car2: Int) {
        guard let index1 = leaderboard.firstIndex(where: { $0.0 == car1 }),
              let index2 = leaderboard.firstIndex(where: { $0.0 == car2 }) else {
            return
        }
        
        withAnimation {
            leaderboard.swapAt(index1, index2)
        }
    }
    
    @State private var lastOvertakeIndex = 0
    
    func startOvertakeRefresh() {
        Task {
            while true {
                self.elapsedTime = self.eventDeployer.getElapsedTime()
                self.trackTime = self.formatElapsedTime(elapsedTime: self.elapsedTime)
                await refreshOvertakeData()
                
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }

    func refreshOvertakeData() async {
        let elapsedTime = eventDeployer.getElapsedTime()
            for index in lastOvertakeIndex..<overtakes.count {
                let overtake = overtakes[index]

                if let overtakerID = Int(overtake.overtaker), let overtakenID = Int(overtake.overtaken) {
                    self.overtake(car1: overtakerID, car2: overtakenID)
                    lastOvertakeIndex = index + 1
                } else {
                    break
                }
            }
        }
    
    //    func refreshDriverData()
    
    let teamHexcode: [String: String] = [
        "Red Bull Racing": "3671C6",
        "Ferrari": "E8002D",
        "Mercedes": "27F4D2",
        "Aston Martin": "229971",
        "McLaren": "FF8000",
        "Haas F1 Team": "B6BABD",
        "RB": "6692FF",
        "Williams": "64C4FF",
        "Kick Sauber": "52E252",
        "Alpine": "FF87BC"
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Title section
            
            HStack {
                Image("Flag-Bahrain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                
                Text("Gulf Air Bahrain Grand Prix")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
            }
            .padding(.leading, 20)
            
            // Track conditions
            
            HStack {
                Text(trackTime)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 20)
                
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 40)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                
                Text("\(rainPercentage)%")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.trailing, 5)
                
                Image("Rain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)
                
                Text(String(format: "%.2f", windSpeed) + " m/s")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.trailing, 5)
                
                Image("Wind")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)
                
                Text(String(format: "%.1f", trackTemp) + "°C")
                    .font(.title)
                    .fontWeight(.bold)
                
                Image("TRC")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 20)
                
                Text(String(format: "%.1f", airTemp) + "°C")
                    .font(.title)
                    .fontWeight(.bold)
                
                Image("Air")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 50)
                
            }
            
            Spacer().frame(height: 20)
            
            // Leaderboard section
            
            List(Array(leaderboard.enumerated()), id: \.element.0) { index, entry in
                
                Button(action: {
                    selectedDriver = entry.0
                    openWindow(id: "driver-details")
                }) {
                    
                    HStack {
                        
                        // Position Number
                        
                        Text("\(index + 1)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.trailing, 20)
                            .frame(width: 60)
                        
                        // Driver Name
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: teamHexcode[entry.2] ?? "000000"))
                                .frame(width: 110, height: 60)
                                .cornerRadius(10)
                                .opacity(0.45)
                            
                            Text(entry.1)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 30)
                        }
                        
                        // DRS / PIT
                        
                        let textWidth: CGFloat = 50
                        
                        if (entry.4 == "enabled") {
                            Text("DRS")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: textWidth, alignment: .leading)
                                .padding(.leading, 30)
                                .foregroundColor(.white)
                        } else if (entry.4 == "disabled") {
                            Text("DRS")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: textWidth, alignment: .leading)
                                .padding(.leading, 30)
                                .foregroundColor(Color(hex: "4D4D4D"))
                        } else if (entry.4 == "on") {
                            Text("DRS")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: textWidth, alignment: .leading)
                                .padding(.leading, 30)
                                .foregroundColor(Color(hex: "52E252"))
                        } else if (entry.4 == "pit") {
                            Text("PIT")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: textWidth, alignment: .leading)
                                .padding(.leading, 30)
                                .foregroundColor(Color(hex: "64C4FF"))
                        } else {
                            Text("")
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: textWidth, alignment: .leading)
                                .padding(.leading, 30)
                                .foregroundColor(Color(hex: "64C4FF"))
                        }
                        
                        // Tire type
                        
                        Image(entry.3)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(.leading, 20)
                        
                        // Tire laps
                        
                        Text("L\(entry.5)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 20)
                            .frame(width: 100, alignment: .leading)
                        
                        // Fastest Laps
                        
                        Text("\(entry.6)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 5)
                            .frame(width: 120, alignment: .leading)
                            .foregroundColor(Color(hex: "52E252"))
                        
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 2, height: 40)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                        
                        // Current Laps
                        
                        Text("\(entry.7)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 5)
                            .frame(width: 170, alignment: .leading)
                            .foregroundColor(Color(hex: "FFFFFF"))
                        
                        // Sector Laps
                        
                        Text("\(entry.8[0])")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 130, alignment: .leading)
                            .foregroundColor(Color(hex: "767676"))
                        
                        Text("\(entry.8[1])")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 130, alignment: .leading)
                            .foregroundColor(Color(hex: "767676"))
                        
                    }
                    .listRowBackground(Color(hex: "18191A"))
                }
                .padding(.leading, 20)
            }
        }
        .onAppear {
            Task {
                startOvertakeRefresh()
                await loadLeaderBoardEvents()
            }
        }
        .padding()
        .background(Color(hex: "18191A"))
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.all)
    }
    
    func loadLeaderBoardEvents() async {
        for driverLapData in driversLapsData {
            for lap in driverLapData.positions {
                let lapNumber = Float(lap[0])
                let section1 = Float(lap[1])
                let section2 = Float(lap[2])
                let section3 = Float(lap[3])
                let lapTime = Float(lap[4])
                let totalTime = Float(lap[5])
                
        
                // Section 1
                let section1Delay = section1 + totalTime
                await eventDeployer.subscribe(key: Int(section1Delay)) {
                    DispatchQueue.main.async {
                        guard let idx = leaderboard.firstIndex(where: { $0.0 == driverLapData.id }) else {
                            return
                        }
                        leaderboard[idx].8[0] = "\(section1)"
                    }
                }
                
                // Section 2
                let section2Delay = section1Delay + section2
                await eventDeployer.subscribe(key: Int(section2Delay)) {
                    DispatchQueue.main.async {
                        guard let idx = leaderboard.firstIndex(where: { $0.0 == driverLapData.id }) else {
                            return
                        }
                        leaderboard[idx].8[1] = "\(section2)"
                    }
                }
                
                // Lap done
                await eventDeployer.subscribe(key: Int(lapTime)) {
                    DispatchQueue.main.async {
                        guard let idx = leaderboard.firstIndex(where: { $0.0 == driverLapData.id }) else {
                            return
                        }
                        leaderboard[idx].8[0] = "00.000"
                        leaderboard[idx].8[1] = "00.000"
                        
                        leaderboard[idx].7 = "\(lapTime)"
                        leaderboard[idx].5 = Int(lapNumber)
                    }
                }
            }
        }
    }
}

struct Overtake: Decodable {
    let time: Double
    let overtaken: String
    let overtaker: String
}

#Preview(windowStyle: .automatic) {

    LeaderboardView(eventDeployer: EventDeployer.init())
}
