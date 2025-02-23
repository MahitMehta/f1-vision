import SwiftUI
import AVFoundation

struct RadioViewProps : Decodable, Encodable, Hashable {
    let driver: String
    let audioURL: String?
}

struct RadioView: View {
    let RADIO_DURATION_PADDING = 0.0
    
    var driverProps: RadioViewProps?
    
    @State private var audioPlayer: AVAudioPlayer?
    @State private var radioPlayer: AVPlayer? // AVPlayer for streaming remote audio
    @State private var isLocalAudioFinished = false
    @Environment(\.dismissWindow) private var dismissWindow // Access to dismiss window action

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .trailing, spacing: 10) {
                // Driver's Last Name
                if let driver = driverProps?.driver {
                    Text(driver)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "00A19B"))
                        .multilineTextAlignment(.trailing)
                        .padding(.top, 20)
                }
               
                // Static Text "RADIO"
                Text("RADIO")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                
                // Sound Waves Image
                Image("sound_waves") // Ensure you have this image in your assets
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            playLocalAudio()
        }
    }

    // Play local radio.mp3 from the app bundle
    private func playLocalAudio() {
        if let filePath = Bundle.main.path(forResource: "radio", ofType: "mp3"), let url = URL(string: filePath) {
            do {
                // Initialize the AVAudioPlayer with the local file
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay() // Prepare the audio player for playback
                audioPlayer?.play() // Play the audio
                print("Local audio is playing.")
                
                // Set up a Timer to check if the local audio finished playing
                startTimer()
            } catch {
                print("Error playing local audio: \(error.localizedDescription)")
            }
        } else {
            print("radio.mp3 not found in bundle.")
        }
    }
    
    // Timer to check if local audio has finished
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let player = self.audioPlayer {
                if player.currentTime >= player.duration - 0.1 {
                    print("Local audio finished.")
                    self.isLocalAudioFinished = true
                    self.playRemoteAudio()
                }
            }
        }
    }
    
    // Play remote audio from the provided URL after local audio finishes
    public func playRemoteAudio() {
        guard let remoteURL = URL(string: driverProps?.audioURL ?? "") else {
            print("Invalid audio URL: \(driverProps?.audioURL ?? "nil")")
            return
        }

        // Create AVPlayer for streaming
        print("Starting to stream remote audio from URL: \(remoteURL.absoluteString)")
        radioPlayer = AVPlayer(url: remoteURL)
        
        // Start playing the remote radio stream
        radioPlayer?.play()
        print("Remote audio should now be playing.")
        
      
       
        Task {
            if let duration = try? await radioPlayer?.currentItem?.asset.load(.duration) {
                let seconds = CMTimeGetSeconds(duration)
                try? await Task.sleep(nanoseconds: UInt64((seconds + RADIO_DURATION_PADDING) * 1_000_000_000))
            }
 
            DispatchQueue.main.async {
                dismissWindow(id: "radio")
            }
        }
    }
}

