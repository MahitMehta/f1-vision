import SwiftUI

struct LeaderboardView: View {
    // Temporary track data
    
    var trackTime = "00:00:00.000"
    var rainPercentage = 100
    var windSpeed = 1.2
    var trackTemp = 2
    var airTemp = 2
    
    let leaderboard = [
        ("VER", "Red Bull Racing Honda RBPT", "M", "enabled", 18, "0.000", "5:14.567", ["5:12.345", "5:30.456", "5:31.543"]),
        ("PER", "Red Bull Racing Honda RBPT", "S", "pit", 5, "+5.123", "5:01.234", ["5:45.123", "5:50.456", "5:25.789"]),
        ("HAM", "Mercedes", "H", "on", 24, "+12.345", "5:30.234", ["5:34.567", "5:45.123", "5:50.345"]),
        ("ALO", "Aston Martin Aramco Mercedes", "M", "off", 12, "+15.678", "5:12.567", ["5:01.789", "5:10.123", "5:00.789"]),
        ("LEC", "Ferrari", "I", "enabled", 27, "+20.234", "5:45.678", ["5:45.234", "5:50.345", "5:00.789"]),
        ("NOR", "McLaren Mercedes", "W", "disabled", 9, "+25.789", "5:23.456", ["5:10.123", "5:12.567", "5:00.345"]),
        ("SAI", "Ferrari", "S", "pit", 30, "+30.123", "5:50.123", ["5:32.987", "5:45.567", "5:00.789"]),
        ("RUS", "Mercedes", "H", "on", 15, "+35.678", "5:45.234", ["5:50.678", "5:55.123", "5:00.567"]),
        ("PIA", "McLaren Mercedes", "M", "off", 22, "+40.234", "5:01.567", ["5:12.345", "5:10.234", "5:00.789"]),
        ("STR", "Aston Martin Aramco Mercedes", "W", "enabled", 3, "+45.123", "5:12.345", ["5:01.123", "5:12.567", "5:00.345"]),
        ("GAS", "Alpine Renault", "I", "disabled", 6, "+50.567", "5:45.678", ["5:45.234", "5:10.123", "5:00.567"]),
        ("OCO", "Alpine Renault", "S", "on", 11, "+55.234", "5:50.789", ["5:55.345", "5:45.123", "5:00.789"]),
        ("ALB", "Williams Mercedes", "H", "pit", 25, "+60.345", "5:12.567", ["5:10.234", "5:12.345", "5:00.789"]),
        ("TSU", "RB Honda RBPT", "M", "off", 8, "+65.678", "5:20.234", ["5:20.567", "5:12.567", "5:00.345"]),
        ("BOT", "Kick Sauber Ferrari", "W", "enabled", 21, "+70.123", "5:10.123", ["5:00.789", "5:10.345", "5:00.789"]),
        ("HUL", "Haas Ferrari", "S", "on", 13, "+75.678", "5:45.678", ["5:34.567", "5:12.789", "5:00.345"]),
        ("RIC", "RB Honda RBPT", "H", "pit", 17, "+80.234", "5:45.234", ["5:45.123", "5:50.678", "5:00.789"]),
        ("ZHO", "Kick Sauber Ferrari", "I", "disabled", 4, "+85.123", "5:50.123", ["5:50.789", "5:12.345", "5:00.567"]),
        ("MAG", "Haas Ferrari", "M", "enabled", 19, "+90.678", "5:10.567", ["5:10.234", "5:10.678", "5:00.345"]),
        ("LAW", "RB Honda RBPT", "W", "off", 2, "+95.345", "5:25.123", ["5:25.678", "5:10.123", "5:00.567"]),
        ("SAR", "Williams Mercedes", "S", "on", 28, "+100.789", "5:45.789", ["5:34.123", "5:12.567", "5:00.789"])
    ]


    let teamHexcode: [String: String] = [
        "Red Bull Racing Honda RBPT": "3671C6",
        "Ferrari": "E8002D",
        "Mercedes": "27F4D2",
        "Aston Martin Aramco Mercedes": "229971",
        "McLaren Mercedes": "FF8000",
        "Haas Ferrari": "B6BABD",
        "RB Honda RBPT": "6692FF",
        "Williams Mercedes": "64C4FF",
        "Kick Sauber Ferrari": "52E252",
        "Alpine Renault": "FF87BC"
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
                            .fill(Color(hex: teamHexcode[entry.1] ?? "000000"))
                            .frame(width: 110, height: 60)
                            .cornerRadius(10)
                            .opacity(0.45)
                        
                        Text(entry.0)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading, 30)
                    }
                    
                    // DRS / PIT
                    
                    let textWidth: CGFloat = 50
                    
                    if (entry.3 == "enabled") {
                        Text("DRS")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: textWidth, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(.white)
                    } else if (entry.3 == "disabled") {
                        Text("DRS")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: textWidth, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(Color(hex: "4D4D4D"))
                    } else if (entry.3 == "on") {
                        Text("DRS")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: textWidth, alignment: .leading)
                            .padding(.leading, 30)
                            .foregroundColor(Color(hex: "52E252"))
                    } else if (entry.3 == "pit") {
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
                    
                    Image(entry.2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.leading, 20)
                    
                    // Tire laps
                    
                    Text("L\(entry.4)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .frame(width: 100, alignment: .leading)
                    
                    // Fastest Laps
                    
                    Text("\(entry.5)")
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
                    
                    Text("\(entry.6)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading, 5)
                        .frame(width: 170, alignment: .leading)
                        .foregroundColor(Color(hex: "FFFFFF"))
                    
                    // Sector Laps
                    
                    Text("\(entry.7[0])")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: 130, alignment: .leading)
                        .foregroundColor(Color(hex: "767676"))
                    
                    Text("\(entry.7[1])")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: 130, alignment: .leading)
                        .foregroundColor(Color(hex: "767676"))
                    
                    Text("\(entry.7[2])")
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(width: 130, alignment: .leading)
                        .foregroundColor(Color(hex: "767676"))
                    
                }
                .listRowBackground(Color(hex: "18191A"))
            }
            .padding(.leading, 20)
            
        }
        .padding()
        .background(Color(hex: "18191A"))
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview(windowStyle: .automatic) {
    LeaderboardView()
}
