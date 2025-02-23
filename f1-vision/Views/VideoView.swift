import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct VideoViewProps : Decodable, Encodable, Hashable {
    let videoDestination: String
}

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        VideoPlayer(player: player)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(10)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                let avPlayer = AVPlayer(url: videoURL)
                player = avPlayer
                avPlayer.play()
                
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: .main) { _ in
                    dismissWindow(id: "video")
                }
            }
    }
}

struct VideoView: View {
    let videoContent: VideoViewProps?
    
    var videoURL: URL? {
        guard let videoDestination = videoContent?.videoDestination else {
            return nil
        }
        return Bundle.main.url(forResource: videoDestination, withExtension: "mp4")
    }
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            if let videoURL = videoURL {
                VideoPlayerView(videoURL: videoURL)
            } else {
                Text("Video not found")
                    .foregroundColor(.white)
            }
        }
    }
}
