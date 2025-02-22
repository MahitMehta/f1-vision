import SwiftUI
import AVFoundation

struct RadioView: View {
    var driver: String
    var audioUrl: String
    @State private var audioPlayer: AVAudioPlayer?
    @Environment(\.dismissWindow) private var dismissWindow // Access to dismiss window action

    var body: some View {
        ZStack {
            // Background color
            Color(hex: "18191A")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .trailing, spacing: 10) {
                // Driver's Last Name
                Text(driver.split(separator: " ").last?.uppercased() ?? "")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "00A19B"))
                    .multilineTextAlignment(.trailing)
                    .padding(.top, 20)
                
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
            setupAudioSession() // Set up audio session
            playAudio() // Play the audio when the view appears
        }
    }
    
    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            print("Audio session set up successfully.")
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    private func playAudio() {
        guard let remoteURL = URL(string: audioUrl) else {
            print("Invalid audio URL")
            return
        }

        // Download the audio file locally
        let task = URLSession.shared.downloadTask(with: remoteURL) { localURL, response, error in
            if let error = error {
                print("Error downloading audio: \(error.localizedDescription)")
                return
            }

            guard let localURL = localURL else {
                print("No local URL for downloaded audio")
                return
            }

            // Check if the file exists and can be played
            do {
                print("Audio file downloaded to: \(localURL)")

                // Play the audio from the local URL
                audioPlayer = try AVAudioPlayer(contentsOf: localURL)
                audioPlayer?.prepareToPlay()
                
                // Debug: Ensure the player is ready
                if let player = audioPlayer, player.prepareToPlay() {
                    print("Audio player prepared.")
                } else {
                    print("Audio player not prepared correctly.")
                }

                audioPlayer?.play()

                // Start checking progress with a while loop
                checkAudioProgress()

                print("Audio is playing.")
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }

        task.resume() // Start the download task
    }

    private func checkAudioProgress() {
        guard let player = audioPlayer else {
            print("Audio player is not set up.")
            return
        }

        // Debug: Print initial state of audio player
        print("Audio duration: \(player.duration) seconds")
        print("Audio player is playing: \(player.isPlaying)")

        // Block the thread to check audio progress in a while loop
        while player.currentTime < player.duration {
            // Print the current time for debugging purposes
            print("Current time: \(player.currentTime) seconds")

            // Sleep to prevent locking the UI thread
            usleep(100000) // sleep for 0.1 seconds (100,000 microseconds)

            if player.currentTime >= player.duration - 0.1 { // A small margin to handle floating point precision
                print("Audio finished playing, dismissing window.")
                break
            }
        }
        
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
        dismissWindow(id: "radio")
    }
}
