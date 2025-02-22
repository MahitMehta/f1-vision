import SwiftUI
import AVKit

// Custom view for embedding the video
struct VideoPlayerView: View {
    let videoURL: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .frame(maxWidth: .infinity, maxHeight: 400)
            .cornerRadius(10)
            .padding()
            .aspectRatio(contentMode: .fit)
    }
}

struct IntroView: View {
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("F1 INTRO")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .padding(.bottom, 60)
                
                if let videoURL = Bundle.main.url(forResource: "F1-Intro", withExtension: "mp4") {
                    VideoPlayerView(videoURL: videoURL)
                } else {
                    Text("Video not found")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }
}

#Preview {
    IntroView()
}
