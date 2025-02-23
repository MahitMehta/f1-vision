import SwiftUI
import AVKit

import SwiftUI
import AVKit

struct VideoViewProps : Decodable, Encodable, Hashable {
    let url: URL
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
    @Environment(\.openWindow) private var openWindow // Access to dismiss window action
    
    var videoURL: URL
    
    var body: some View {
        ZStack {
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
 
            VideoPlayerView(videoURL: videoURL)
                .onAppear {
                    openWindow(id: "dashboard")
                    openWindow(id: "race-track")
                }
      
        }
    }
}
