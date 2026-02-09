import Foundation
import CoreGraphics

enum ShapeType: CaseIterable {
    case square, line, lShape, jShape, tShape, sShape, zShape

    var blocks: [(x: Int, y: Int)] {
        switch self {
        case .square:
            return [(0,0), (1,0), (0,1), (1,1)]
        case .line:
            return [(0,0), (0,1), (0,2), (0,3)]
        case .lShape:
            return [(0,0), (0,1), (0,2), (1,0)]
        case .jShape:
            return [(1,0), (1,1), (1,2), (0,0)]
        case .tShape:
            return [(0,0), (1,0), (2,0), (1,1)]
        case .sShape:
            return [(0,0), (1,0), (1,1), (2,1)]
        case .zShape:
            return [(0,1), (1,1), (1,0), (2,0)]
        }
    }
}

struct BlockShape: Identifiable {
    let id = UUID()
    let type: ShapeType
    let blocks: [(x: Int, y: Int)]
    var colorName: String

    init(type: ShapeType) {
        self.type = type
        self.blocks = type.blocks

        // Assign colors based on shape or random
        switch type {
        case .square: self.colorName = "blue"
        case .line: self.colorName = "cyan"
        case .lShape: self.colorName = "orange"
        case .jShape: self.colorName = "darkBlue"
        case .tShape: self.colorName = "purple"
        case .sShape: self.colorName = "green"
        case .zShape: self.colorName = "red"
        }
    }

    static func random() -> BlockShape {
        let allTypes = ShapeType.allCases
        let randomType = allTypes.randomElement() ?? .square
        return BlockShape(type: randomType)
    }
}
