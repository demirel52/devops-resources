import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        // Prepare sessions
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: Failed to set audio session")
        }
    }

    func playSound(_ name: String) {
        // In a real app, you'd load actual files.
        // Mocking the behavior:
        print("SoundManager: Playing \(name).mp3")
    }

    func playVibration(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
