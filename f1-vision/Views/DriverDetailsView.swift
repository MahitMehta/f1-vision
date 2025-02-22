import SwiftUI

struct DriverDetailsView: View {
    var driver: Driver
    var carStats: CarStatistics

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 16) {
                    // Driver Image
                    Image(driver.photo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(driver.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Number: \(driver.number)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            // Display Nationality Flag
                            Image(driver.nationality.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 20)
                        }
                        
                        Text("Position: #\(driver.position)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                // Speedometer
                VStack {
                    Text("Current Speed")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    SpeedometerView(currentSpeed: carStats.speed)
                        .frame(width: 150, height: 150)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                
                // Braking Indicator
                VStack {
                    Text("Braking")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    ProgressBar(value: carStats.brake)
                        .frame(height: 15)
                        .padding(.horizontal)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                // Additional Stats
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional Stats")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Gear: \(carStats.n_gear)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("RPM: \(carStats.rpm)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("Throttle: \(carStats.throttle)%")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("DRS: \(carStats.drs)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}

// Speedometer View
struct SpeedometerView: View {
    var currentSpeed: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 15)
                .opacity(0.3)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(currentSpeed / 350, 1.0)))
                .stroke(Color.green, lineWidth: 15)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: currentSpeed)
            
            Text("\(Int(currentSpeed)) km/h")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

// Progress Bar View for Braking
struct ProgressBar: View {
    var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Rectangle()
                    .frame(width: min(CGFloat(value) / 100 * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.red)
            }
            .cornerRadius(10)
        }
    }
}

struct Driver {
    var name: String
    var number: String
    var nationality: String
    var position: Int
    var photo: String
}

struct CarStatistics {
    var speed: Double
    var brake: Double
    var n_gear: Int
    var rpm: Int
    var throttle: Double
    var drs: Int
}

#Preview() {
    DriverDetailsView(driver: Driver(name: "Lewis Hamilton", number: "44", nationality: "GB", position: 1, photo: "lewis_hamilton"), carStats: CarStatistics(speed: 315, brake: 0, n_gear: 8, rpm: 11141, throttle: 99, drs: 12))
        .frame(width: 400, height: 600)
}
