import SwiftUI

struct TrackView: View {
    let trackName: String
    let trackImage: String // Image name or URL
    let flagImage: String // Flag image name
    let width: CGFloat // Width of the screen to match the slide size
    
    var body: some View {
        VStack {
            // Track Name
            Text(trackName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            // Track Map Image
            Image(trackImage)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.8, height: 200) // Adjust image width relative to screen width
                .cornerRadius(10)
                .padding(.bottom, 10)
            
            // Flag Image
            Image(flagImage)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
        }
        .frame(width: width) // Set width to match screen size
        .padding()
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

struct WelcomeView: View {
    let tracks = [
        ("Monaco Grand Prix", "monaco_map", "monaco_flag"),
        ("British Grand Prix", "silverstone_map", "uk_flag"),
        ("Japanese Grand Prix", "suzuka_map", "japan_flag"),
        ("Bahrain Grand Prix", "bahrain_map", "bahrain_flag")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Select F1 Race to Experience")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(tracks, id: \.0) { track in
                                TrackView(trackName: track.0, trackImage: track.1, flagImage: track.2, width: geometry.size.width)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .frame(height: 400)
            }
        }
        .cornerRadius(20)
    }
}

#Preview(windowStyle: .automatic) {
    WelcomeView()
}
