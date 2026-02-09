import Foundation
import CoreGraphics

enum ShapeType: CaseIterable {
    case square, line, lShape, jShape, tShape, sShape, zShape, smallL, dot

    var blocks: [(x: Int, y: Int)] {
        switch self {
        case .square: return [(0,0), (1,0), (0,1), (1,1)]
        case .line: return [(0,0), (0,1), (0,2), (0,3)]
        case .lShape: return [(0,0), (0,1), (0,2), (1,0)]
        case .jShape: return [(1,0), (1,1), (1,2), (0,0)]
        case .tShape: return [(0,0), (1,0), (2,0), (1,1)]
        case .sShape: return [(0,0), (1,0), (1,1), (2,1)]
        case .zShape: return [(0,1), (1,1), (1,0), (2,0)]
        case .smallL: return [(0,0), (1,0), (0,1)]
        case .dot: return [(0,0)]
        }
    }

    var colorName: String {
        switch self {
        case .square: return "red"
        case .line: return "cyan"
        case .lShape: return "orange"
        case .jShape: return "blue"
        case .tShape: return "purple"
        case .sShape: return "green"
        case .zShape: return "yellow"
        case .smallL: return "red"
        case .dot: return "cyan"
        }
    }
}

class BlockShape: Identifiable, Equatable {
    let id: UUID
    let type: ShapeType
    let blocks: [(x: Int, y: Int)]
    let colorName: String

    init(type: ShapeType) {
        self.id = UUID()
        self.type = type
        self.blocks = type.blocks
        self.colorName = type.colorName
    }

    static func random() -> BlockShape {
        BlockShape(type: ShapeType.allCases.randomElement()!)
    }

    static func == (lhs: BlockShape, rhs: BlockShape) -> Bool {
        lhs.id == rhs.id
    }
}
