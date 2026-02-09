import SwiftUI
import SpriteKit

// MARK: - AdManager (Mock)
class AdManager {
    static let shared = AdManager()
    private init() {}

    func showInterstitial() {
        print("AdManager: [INTERSTITIAL] ca-app-pub-3940256099942544/1033173712")
        // Real implementation would use GADInterstitialAd.load
    }
}

// MARK: - ContentView
struct ContentView: View {
    @State private var manager = GameManager()
    @State private var sceneID = UUID()
    @State private var gameScene: GameScene?

    // Create scene and connect callbacks
    private func createScene() -> GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 850)
        scene.scaleMode = .aspectFill

        // Connect callbacks
        scene.onScoreUpdate = { score in
            manager.updateScore(score)
        }
        scene.onGameOver = {
            manager.setGameOver()
            AdManager.shared.showInterstitial()
        }
        scene.onCombo = { text in
            manager.triggerCombo(text)
        }

        return scene
    }

    var body: some View {
        ZStack {
            // Background Gradient
            GameTheme.background
                .ignoresSafeArea()

            // SpriteKit Layer
            if let scene = gameScene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .id(sceneID)
                    .ignoresSafeArea()
            }

            // HUD
            VStack {
                HeaderView(score: manager.score, highScore: manager.highScore)
                    .padding(.top, 40)

                Spacer()

                // Combo Pop-up
                if manager.showCombo {
                    Text(manager.lastComboText)
                        .font(.system(size: 44, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 4)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                        .offset(y: -100)
                }
            }
            .padding()

            // Overlays
            if manager.isGameOver {
                GameOverOverlay(score: manager.score, highScore: manager.highScore) {
                    restartGame()
                }
            }
        }
        .onAppear {
            if gameScene == nil {
                gameScene = createScene()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func restartGame() {
        withAnimation {
            manager.restart()
            gameScene = createScene()
            sceneID = UUID() // Refresh SpriteView
        }
    }
}

// MARK: - Subviews
struct HeaderView: View {
    let score: Int
    let highScore: Int

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BEST SCORE")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                Text("\(highScore)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("SCORE")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.gray)
                Text("\(score)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(GameTheme.accent)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct GameOverOverlay: View {
    let score: Int
    let highScore: Int
    let onRestart: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("GAME OVER")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 10) {
                    Text("YOUR SCORE")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text("\(score)")
                        .font(.system(size: 70, weight: .black, design: .rounded))
                        .foregroundStyle(GameTheme.accent)
                }

                if score >= highScore && score > 0 {
                    Text("NEW RECORD!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Capsule().fill(Color.yellow.opacity(0.2)))
                }

                Button(action: onRestart) {
                    Text("PLAY AGAIN")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 15, x: 0, y: 10)
                }
                .padding(.top, 20)
            }
        }
    }
}
