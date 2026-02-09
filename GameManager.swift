import SwiftUI
import Observation

@Observable
class GameManager {
    var score: Int = 0
    var highScore: Int = 0
    var isGameOver: Bool = false
    var lastComboText: String = ""
    var showCombo: Bool = false

    private let highScoreKey = "BlockBlastHighScore"

    init() {
        self.highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func updateScore(_ newScore: Int) {
        score = newScore
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }

    func setGameOver() {
        isGameOver = true
    }

    func triggerCombo(_ text: String) {
        lastComboText = text
        showCombo = true

        // Hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showCombo = false
        }
    }

    func restart() {
        score = 0
        isGameOver = false
        showCombo = false
    }
}
