import SwiftUI

struct LeaderboardView: View {
    // Temporary track data
    
    var trackTime = "00:00:00.000"
    var rainPercentage = 100
    var windSpeed = 1.2
    var trackTemp = 2
    var airTemp = 2
    
    let leaderboard = [
        ("VER", "Red Bull Racing Honda RBPT", "M", "enabled"),
        ("PER", "Red Bull Racing Honda RBPT", "S", "pit"),
        ("HAM", "Mercedes", "H", "on"),
        ("ALO", "Aston Martin Aramco Mercedes", "M", "off"),
        ("LEC", "Ferrari", "I", "enabled"),
        ("NOR", "McLaren Mercedes", "W", "disabled"),
        ("SAI", "Ferrari", "S", "pit"),
        ("RUS", "Mercedes", "H", "on"),
        ("PIA", "McLaren Mercedes", "M", "off"),
        ("STR", "Aston Martin Aramco Mercedes", "W", "enabled"),
        ("GAS", "Alpine Renault", "I", "disabled"),
        ("OCO", "Alpine Renault", "S", "on"),
        ("ALB", "Williams Mercedes", "H", "pit"),
        ("TSU", "RB Honda RBPT", "M", "off"),
        ("BOT", "Kick Sauber Ferrari", "W", "enabled"),
        ("HUL", "Haas Ferrari", "S", "on"),
        ("RIC", "RB Honda RBPT", "H", "pit"),
        ("ZHO", "Kick Sauber Ferrari", "I", "disabled"),
        ("MAG", "Haas Ferrari", "M", "enabled"),
        ("LAW", "RB Honda RBPT", "W", "off"),
        ("SAR", "Williams Mercedes", "S", "on")
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
                    
                    // Tire type
                    
                    Image(entry.2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(.leading, 20)
                    
                    
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
