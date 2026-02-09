import SwiftUI
import SpriteKit

// MARK: - AdManager (Mock)
class AdManager {
    static let shared = AdManager()
    private init() {}

    func showInterstitial() {
        print("AdManager: Showing Interstitial Ad (Test ID: ca-app-pub-3940256099942544/1033173712)")
        // In a real app, you would integrate Google Mobile Ads SDK here
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State private var scene: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 800)
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        ZStack {
            // Game Scene
            SpriteView(scene: scene)
                .ignoresSafeArea()

            // UI Overlay
            VStack {
                // Score
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        Text("\(score)")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 30)

                Spacer()
            }

            // Game Over Overlay
            if isGameOver {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("GAME OVER")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundColor(.red)

                    Text("Final Score")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("\(score)")
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Button(action: restartGame) {
                        Text("RESTART")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .scoreChanged)) { notification in
            if let score = notification.userInfo?["score"] as? Int {
                self.score = score
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameOver)) { _ in
            withAnimation {
                self.isGameOver = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAd)) { _ in
            AdManager.shared.showInterstitial()
        }
        .preferredColorScheme(.dark)
    }

    func restartGame() {
        score = 0
        isGameOver = false

        // Re-initialize the scene
        let newScene = GameScene()
        newScene.size = CGSize(width: 400, height: 800)
        newScene.scaleMode = .resizeFill
        scene = newScene
    }
}
