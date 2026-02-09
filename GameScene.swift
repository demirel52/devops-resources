import SpriteKit
import SwiftUI

class GameScene: SKScene {

    // MARK: - Properties
    let gridSize = 8
    let cellSize: CGFloat = 40
    let gridSpacing: CGFloat = 4

    var gridNodes: [[SKShapeNode]] = []
    var gridData: [[Bool]] = Array(repeating: Array(repeating: false, count: 8), count: 8)

    var score: Int = 0 {
        didSet {
            // Notify SwiftUI
            NotificationCenter.default.post(name: .scoreChanged, object: nil, userInfo: ["score": score])
        }
    }

    var isGameOver = false {
        didSet {
            if isGameOver {
                NotificationCenter.default.post(name: .gameOver, object: nil)
            }
        }
    }

    // Spawned shapes container
    var spawnedShapes: [SKNode] = []

    // Interaction
    var activeNode: SKNode?
    var originalPosition: CGPoint?
    let touchOffset: CGFloat = 70 // Offset so user can see the shape under their finger

    // MARK: - Initialization
    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupGrid()
        spawnNewShapes()
    }

    func setupGrid() {
        let totalGridSize = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * gridSpacing
        let startX = (size.width - totalGridSize) / 2
        let startY = (size.height - totalGridSize) / 2 + 100 // Offset upwards

        for row in 0..<gridSize {
            var rowNodes: [SKShapeNode] = []
            for col in 0..<gridSize {
                let cell = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: 4)
                cell.fillColor = SKColor.darkGray.withAlphaComponent(0.3)
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

    func spawnNewShapes() {
        guard spawnedShapes.isEmpty else { return }

        let spawnY: CGFloat = 150
        let spacings: [CGFloat] = [size.width * 0.25, size.width * 0.5, size.width * 0.75]

        for i in 0..<3 {
            let shapeData = BlockShape.random()
            let container = SKNode()
            container.name = "shapeContainer"
            container.userData = ["data": shapeData]

            for block in shapeData.blocks {
                let blockNode = SKShapeNode(rectOf: CGSize(width: cellSize - 2, height: cellSize - 2), cornerRadius: 4)
                blockNode.fillColor = getColor(name: shapeData.colorName)
                blockNode.strokeColor = .white
                blockNode.lineWidth = 1

                blockNode.position = CGPoint(
                    x: CGFloat(block.x) * (cellSize + 2),
                    y: CGFloat(block.y) * (cellSize + 2)
                )
                container.addChild(blockNode)
            }

            // Center the container
            let bounds = container.calculateAccumulatedFrame()
            container.children.forEach { $0.position.x -= bounds.width / 2; $0.position.y -= bounds.height / 2 }

            container.position = CGPoint(x: spacings[i], y: spawnY)
            container.setScale(0) // Start small for animation

            addChild(container)
            spawnedShapes.append(container)

            container.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.1),
                SKAction.scale(to: 0.6, duration: 0.2)
            ]))
        }
    }

    func getColor(name: String) -> SKColor {
        switch name {
        case "blue": return .systemBlue
        case "cyan": return .systemTeal
        case "orange": return .systemOrange
        case "darkBlue": return .blue
        case "purple": return .systemPurple
        case "green": return .systemGreen
        case "red": return .systemRed
        default: return .gray
        }
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "shapeContainer" || node.parent?.name == "shapeContainer" {
                activeNode = (node.name == "shapeContainer") ? node : node.parent
                originalPosition = activeNode?.position

                activeNode?.zPosition = 100
                activeNode?.run(SKAction.scale(to: 1.0, duration: 0.1))

                // Set initial position with offset
                activeNode?.position = CGPoint(x: location.x, y: location.y + touchOffset)
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
            snapToGrid(node: node, gridPos: gridPos)
        } else {
            // Return to base
            node.zPosition = 0
            node.run(SKAction.group([
                SKAction.move(to: originalPos, duration: 0.2),
                SKAction.scale(to: 0.6, duration: 0.2)
            ]))
        }

        activeNode = nil
        originalPosition = nil
    }

    // MARK: - Game Logic
    func findValidGridPosition(for node: SKNode) -> (Int, Int)? {
        guard let shapeData = node.userData?["data"] as? BlockShape else { return nil }

        // Find the closest grid cell for the container's center
        var closestCell: (row: Int, col: Int)?
        var minDistance: CGFloat = cellSize

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let cellPos = gridNodes[row][col].position
                let distance = hypot(node.position.x - cellPos.x, node.position.y - cellPos.y)

                if distance < minDistance {
                    minDistance = distance
                    closestCell = (row, col)
                }
            }
        }

        guard let cell = closestCell else { return nil }

        // Check if all blocks of the shape fit and cells are empty
        for block in shapeData.blocks {
            let targetRow = cell.row + block.y
            let targetCol = cell.col + block.x

            if targetRow < 0 || targetRow >= gridSize || targetCol < 0 || targetCol >= gridSize {
                return nil
            }

            if gridData[targetRow][targetCol] {
                return nil
            }
        }

        return (cell.row, cell.col)
    }

    func snapToGrid(node: SKNode, gridPos: (Int, Int)) {
        guard let shapeData = node.userData?["data"] as? BlockShape else { return }

        for block in shapeData.blocks {
            let r = gridPos.0 + block.y
            let c = gridPos.1 + block.x

            gridData[r][c] = true
            gridNodes[r][c].fillColor = getColor(name: shapeData.colorName)
            gridNodes[r][c].strokeColor = .white

            // Animation for placing
            gridNodes[r][c].run(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.05),
                SKAction.scale(to: 1.0, duration: 0.05)
            ]))
        }

        // Feedback
        triggerFeedback(style: .medium)

        // Remove from spawned list and scene
        if let index = spawnedShapes.firstIndex(of: node) {
            spawnedShapes.remove(at: index)
        }
        node.removeFromParent()

        // Increase score
        score += shapeData.blocks.count * 10

        // Check for completed lines
        checkAndClearLines()

        // Spawn new if tray is empty
        if spawnedShapes.isEmpty {
            spawnNewShapes()
        }

        // Check game over
        checkGameOver()
    }

    func triggerFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func checkAndClearLines() {
        var rowsToClear: [Int] = []
        var colsToClear: [Int] = []

        // Check rows
        for r in 0..<gridSize {
            if gridData[r].allSatisfy({ $0 == true }) {
                rowsToClear.append(r)
            }
        }

        // Check columns
        for c in 0..<gridSize {
            var isFull = true
            for r in 0..<gridSize {
                if !gridData[r][c] {
                    isFull = false
                    break
                }
            }
            if isFull {
                colsToClear.append(c)
            }
        }

        if !rowsToClear.isEmpty || !colsToClear.isEmpty {
            clearLines(rows: rowsToClear, cols: colsToClear)
        }
    }

    func clearLines(rows: [Int], cols: [Int]) {
        var nodesToAnimate: [SKShapeNode] = []

        for r in rows {
            for c in 0..<gridSize {
                nodesToAnimate.append(gridNodes[r][c])
                gridData[r][c] = false
            }
        }

        for c in cols {
            for r in 0..<gridSize {
                if !nodesToAnimate.contains(gridNodes[r][c]) {
                    nodesToAnimate.append(gridNodes[r][c])
                }
                gridData[r][c] = false
            }
        }

        // Animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleDown])

        for node in nodesToAnimate {
            node.run(group) {
                node.fillColor = SKColor.darkGray.withAlphaComponent(0.3)
                node.strokeColor = .clear
                node.alpha = 1.0
                node.setScale(1.0)
            }
        }

        // Feedback
        triggerFeedback(style: .heavy)

        // Score bonus
        let linesCount = rows.count + cols.count
        score += linesCount * 100 * linesCount
    }

    func checkGameOver() {
        for node in spawnedShapes {
            if canPieceFitAnywhere(node: node) {
                return // Found at least one piece that fits
            }
        }

        // No pieces fit
        isGameOver = true

        // Call AdManager (Implementation in ContentView.swift or separate)
        // Since we need to follow the user's specific request for AdManager.shared.showInterstitial()
        // We'll assume AdManager is defined somewhere accessible.
        NotificationCenter.default.post(name: .showAd, object: nil)
    }

    func canPieceFitAnywhere(node: SKNode) -> Bool {
        guard let shapeData = node.userData?["data"] as? BlockShape else { return false }

        for r in 0..<gridSize {
            for c in 0..<gridSize {
                var canFit = true

                for block in shapeData.blocks {
                    let tr = r + block.y
                    let tc = c + block.x

                    if tr < 0 || tr >= gridSize || tc < 0 || tc >= gridSize || gridData[tr][tc] {
                        canFit = false
                        break
                    }
                }

                if canFit {
                    return true
                }
            }
        }

        return false
    }
}

extension Notification.Name {
    static let scoreChanged = Notification.Name("scoreChanged")
    static let gameOver = Notification.Name("gameOver")
    static let showAd = Notification.Name("showAd")
}
