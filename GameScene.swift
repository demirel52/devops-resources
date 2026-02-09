import SpriteKit
import SwiftUI

class GameScene: SKScene {

    // MARK: - Constants
    private let gridSize = 8
    private let cellSize: CGFloat = 44
    private let gridSpacing: CGFloat = 4
    private let touchOffset: CGFloat = 80

    // MARK: - Properties
    private var gridNodes: [[SKShapeNode]] = []
    private var gridData: [[Bool]] = Array(repeating: Array(repeating: false, count: 8), count: 8)
    private var spawnedShapes: [SKNode] = []

    private var activeNode: SKNode?
    private var originalPosition: CGPoint?

    // State reporting
    var onScoreUpdate: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    var onCombo: ((String) -> Void)?

    private var score: Int = 0 {
        didSet { onScoreUpdate?(score) }
    }

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
    }

    private func setupScene() {
        backgroundColor = .clear // Let SwiftUI handle background
        setupGrid()
        spawnNewShapes()
    }

    private func setupGrid() {
        let totalSize = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * gridSpacing
        let startX = (size.width - totalSize) / 2
        let startY = (size.height - totalSize) / 2 + 80

        for row in 0..<gridSize {
            var rowNodes: [SKShapeNode] = []
            for col in 0..<gridSize {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: 6)
                cell.fillColor = GameTheme.skColor(GameTheme.cellEmpty)
                cell.strokeColor = .clear

                let posX = startX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2
                let posY = startY + CGFloat(row) * (cellSize + gridSpacing) + cellSize / 2

                cell.position = CGPoint(x: posX, y: posY)
                addChild(cell)
                rowNodes.append(cell)
            }
            gridNodes.append(rowNodes)
        }
    }

    // MARK: - Shape Management
    func spawnNewShapes() {
        guard spawnedShapes.isEmpty else { return }

        let spawnY: CGFloat = 160
        let spacings: [CGFloat] = [size.width * 0.22, size.width * 0.5, size.width * 0.78]

        for i in 0..<3 {
            let shape = BlockShape.random()
            let container = createShapeNode(from: shape)
            container.position = CGPoint(x: spacings[i], y: spawnY)
            container.setScale(0)

            addChild(container)
            spawnedShapes.append(container)

            container.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.15),
                SKAction.customAction(withDuration: 0) { _, _ in
                    self.triggerFeedback(.light)
                },
                SKAction.scale(from: 0, to: 0.6, duration: 0.4, usingSpringWithDamping: 0.7)
            ]))
        }
    }

    private func createShapeNode(from shape: BlockShape) -> SKNode {
        let container = SKNode()
        container.name = "shape"
        container.userData = ["data": shape]

        let color = GameTheme.skColor(GameTheme.blockColors[shape.colorName] ?? .gray)

        for block in shape.blocks {
            let node = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 6)
            node.fillColor = color
            node.strokeColor = .white.withAlphaComponent(0.3)
            node.lineWidth = 1.5

            node.position = CGPoint(
                x: CGFloat(block.x) * (cellSize + gridSpacing),
                y: CGFloat(block.y) * (cellSize + gridSpacing)
            )
            container.addChild(node)
        }

        // Center blocks inside container
        let bounds = container.calculateAccumulatedFrame()
        container.children.forEach {
            $0.position.x -= bounds.width / 2 - cellSize / 2
            $0.position.y -= bounds.height / 2 - cellSize / 2
        }

        return container
    }

    // MARK: - Touch Interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            let target = (node.name == "shape") ? node : node.parent
            if target?.name == "shape" {
                activeNode = target
                originalPosition = target?.position

                target?.zPosition = 1000
                target?.run(SKAction.scale(to: 1.1, duration: 0.15))
                target?.position = CGPoint(x: location.x, y: location.y + touchOffset)

                triggerFeedback(.light)
                break
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = activeNode else { return }
        let location = touch.location(in: self)
        node.position = CGPoint(x: location.x, y: location.y + touchOffset)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = activeNode, let originalPos = originalPosition else { return }

        if let gridPos = findValidGridPosition(for: node) {
            placeShape(node: node, at: gridPos)
        } else {
            node.zPosition = 0
            node.run(SKAction.group([
                SKAction.move(to: originalPos, duration: 0.3),
                SKAction.scale(from: 1.1, to: 0.6, duration: 0.3, usingSpringWithDamping: 0.8)
            ]))
            triggerFeedback(.soft)
        }

        activeNode = nil
        originalPosition = nil
    }

    // MARK: - Game Logic
    private func findValidGridPosition(for node: SKNode) -> (Int, Int)? {
        guard let shape = node.userData?["data"] as? BlockShape else { return nil }

        var closest: (row: Int, col: Int)?
        var minDistance: CGFloat = cellSize * 0.8

        for r in 0..<gridSize {
            for c in 0..<gridSize {
                let cellPos = gridNodes[r][c].position
                let d = hypot(node.position.x - cellPos.x, node.position.y - cellPos.y)
                if d < minDistance {
                    minDistance = d
                    closest = (r, c)
                }
            }
        }

        guard let pos = closest else { return nil }

        for b in shape.blocks {
            let tr = pos.row + b.y
            let tc = pos.col + b.x
            if tr < 0 || tr >= gridSize || tc < 0 || tc >= gridSize || gridData[tr][tc] {
                return nil
            }
        }

        return pos
    }

    private func placeShape(node: SKNode, at pos: (Int, Int)) {
        guard let shape = node.userData?["data"] as? BlockShape else { return }
        let color = GameTheme.skColor(GameTheme.blockColors[shape.colorName] ?? .gray)

        for b in shape.blocks {
            let r = pos.0 + b.y
            let c = pos.1 + b.x
            gridData[r][c] = true

            let gridCell = gridNodes[r][c]
            gridCell.fillColor = color
            gridCell.strokeColor = .white.withAlphaComponent(0.5)

            // Placement animation
            gridCell.run(SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]))
        }

        triggerFeedback(.medium)

        if let idx = spawnedShapes.firstIndex(of: node) {
            spawnedShapes.remove(at: idx)
        }
        node.removeFromParent()

        score += shape.blocks.count * 10
        checkLines()

        if spawnedShapes.isEmpty {
            spawnNewShapes()
        }

        checkGameOver()
    }

    private func checkLines() {
        var rows: [Int] = []
        var cols: [Int] = []

        for r in 0..<gridSize {
            if gridData[r].allSatisfy({ $0 }) { rows.append(r) }
        }

        for c in 0..<gridSize {
            var full = true
            for r in 0..<gridSize { if !gridData[r][c] { full = false; break } }
            if full { cols.append(c) }
        }

        if !rows.isEmpty || !cols.isEmpty {
            clearLines(rows: rows, cols: cols)
        }
    }

    private func clearLines(rows: [Int], cols: [Int]) {
        var targets: Set<[Int]> = []
        for r in rows { for c in 0..<gridSize { targets.insert([r, c]) } }
        for c in cols { for r in 0..<gridSize { targets.insert([r, c]) } }

        for t in targets {
            let r = t[0], c = t[1]
            gridData[r][c] = false
            let node = gridNodes[r][c]

            // Particle effect
            createParticles(at: node.position, color: node.fillColor)

            node.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 0, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3)
                ]),
                SKAction.run {
                    node.fillColor = GameTheme.skColor(GameTheme.cellEmpty)
                    node.strokeColor = .clear
                    node.alpha = 1.0
                    node.setScale(1.0)
                }
            ]))
        }

        let comboCount = rows.count + cols.count
        let bonus = comboCount * 100 * comboCount
        score += bonus

        triggerFeedback(.heavy)

        if comboCount >= 2 {
            showComboEffect(count: comboCount)
        }
    }

    private func createParticles(at pos: CGPoint, color: SKColor) {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(image: UIImage(systemName: "sparkle")!)
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.5
        emitter.particlePositionRange = CGVector(dx: 20, dy: 20)
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -1.0
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0

        emitter.position = pos
        addChild(emitter)

        emitter.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }

    private func showComboEffect(count: Int) {
        let texts = ["GOOD!", "GREAT!", "AMAZING!", "EXCELLENT!", "UNBELIEVABLE!"]
        let text = texts[min(count - 2, texts.count - 1)]
        onCombo?(text)
    }

    private func checkGameOver() {
        for node in spawnedShapes {
            if canFit(node: node) { return }
        }
        onGameOver?()
    }

    private func canFit(node: SKNode) -> Bool {
        guard let shape = node.userData?["data"] as? BlockShape else { return false }
        for r in 0..<gridSize {
            for c in 0..<gridSize {
                var possible = true
                for b in shape.blocks {
                    let tr = r + b.y, tc = c + b.x
                    if tr < 0 || tr >= gridSize || tc < 0 || tc >= gridSize || gridData[tr][tc] {
                        possible = false; break
                    }
                }
                if possible { return true }
            }
        }
        return false
    }

    private func triggerFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        SoundManager.shared.playVibration(style: style)

        switch style {
        case .light: SoundManager.shared.playSound("tap")
        case .medium: SoundManager.shared.playSound("place")
        case .heavy: SoundManager.shared.playSound("clear")
        default: break
        }
    }
}

// MARK: - Spring Animation Helper
extension SKAction {
    static func scale(from start: CGFloat, to end: CGFloat, duration: TimeInterval, usingSpringWithDamping damping: CGFloat) -> SKAction {
        let steps = 30
        var keyframes: [SKAction] = []
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            // Damped harmonic oscillation formula (simplified)
            let dampingFactor = exp(-t * 5)
            let oscillation = cos(t * 10)
            let multiplier = 1 - dampingFactor * oscillation
            let currentScale = start + (end - start) * multiplier
            keyframes.append(SKAction.scale(to: currentScale, duration: duration / Double(steps)))
        }
        return SKAction.sequence(keyframes)
    }
}
