import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(10)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }
}

struct VideoView: View {
    let videoURL: URL
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
                
            VideoPlayerView(videoURL: videoURL)
        }
    }
}

#Preview {
    if let videoURL = Bundle.main.url(forResource: "F1-Intro", withExtension: "mp4") {
        VideoView(videoURL: videoURL)
    } else {
        Text("Video not found")
    }
}
