import SwiftUI

var selectedDriver: Int?

struct LeaderboardView: View {
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
        (1, "VER", "Red Bull Racing", "M", "disabled", 18, "0.000", "5:14.567", ["5:12.345", "5:30.456", "5:31.543"]),
        (11, "PER", "Red Bull Racing", "S", "pit", 5, "+5.123", "5:01.234", ["5:45.123", "5:50.456", "5:25.789"]),
        (44, "HAM", "Mercedes", "H", "on", 24, "+12.345", "5:30.234", ["5:34.567", "5:45.123", "5:50.345"]),
        (14, "ALO", "Aston Martin", "M", "off", 12, "+15.678", "5:12.567", ["5:01.789", "5:10.123", "5:00.789"]),
        (16, "LEC", "Ferrari", "I", "enabled", 27, "+20.234", "5:45.678", ["5:45.234", "5:50.345", "5:00.789"]),
        (4, "NOR", "McLaren", "W", "disabled", 9, "+25.789", "5:23.456", ["5:10.123", "5:12.567", "5:00.345"]),
        (55, "SAI", "Ferrari", "S", "pit", 30, "+30.123", "5:50.123", ["5:32.987", "5:45.567", "5:00.789"]),
        (63, "RUS", "Mercedes", "H", "on", 15, "+35.678", "5:45.234", ["5:50.678", "5:55.123", "5:00.567"]),
        (81, "PIA", "McLaren", "M", "off", 22, "+40.234", "5:01.567", ["5:12.345", "5:10.234", "5:00.789"]),
        (18, "STR", "Aston Martin", "W", "enabled", 3, "+45.123", "5:12.345", ["5:01.123", "5:12.567", "5:00.345"]),
        (10, "GAS", "Alpine", "I", "disabled", 6, "+50.567", "5:45.678", ["5:45.234", "5:10.123", "5:00.567"]),
        (31, "OCO", "Alpine", "S", "on", 11, "+55.234", "5:50.789", ["5:55.345", "5:45.123", "5:00.789"]),
        (23, "ALB", "Williams", "H", "pit", 25, "+60.345", "5:12.567", ["5:10.234", "5:12.345", "5:00.789"]),
        (22, "TSU", "RB Honda RBPT", "M", "off", 8, "+65.678", "5:20.234", ["5:20.567", "5:12.567", "5:00.345"]),
        (77, "BOT", "Kick Sauber", "W", "enabled", 21, "+70.123", "5:10.123", ["5:00.789", "5:10.345", "5:00.789"]),
        (27, "HUL", "Haas Ferrari", "S", "on", 13, "+75.678", "5:45.678", ["5:34.567", "5:12.789", "5:00.345"]),
        (23, "RIC", "RB", "H", "pit", 17, "+80.234", "5:45.234", ["5:45.123", "5:50.678", "5:00.789"]),
        (24, "ZHO", "Kick Sauber", "I", "disabled", 4, "+85.123", "5:50.123", ["5:50.789", "5:12.345", "5:00.567"]),
        (20, "MAG", "Haas", "M", "enabled", 19, "+90.678", "5:10.567", ["5:10.234", "5:10.678", "5:00.345"]),
        (30, "LAW", "RB", "W", "off", 2, "+95.345", "5:25.123", ["5:25.678", "5:10.123", "5:00.567"]),
        (2, "SAR", "Williams", "S", "on", 28, "+100.789", "5:45.789", ["5:34.123", "5:12.567", "5:00.789"])
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
        let overtakes: [Overtake] = loadJSON("overtake_data") ?? []
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
                        
                        Text("\(entry.8[2])")
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
            }
        }
        .padding()
        .background(Color(hex: "18191A"))
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.all)
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
