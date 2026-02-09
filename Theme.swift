import SwiftUI

struct GameTheme {
    static let background = Color(hex: "1A1A2E")
    static let gridBackground = Color(hex: "16213E").opacity(0.8)
    static let cellEmpty = Color(hex: "0F3460").opacity(0.4)

    // Vibrant block colors (Candy Crush style)
    static let blockColors: [String: Color] = [
        "red": Color(hex: "E94560"),
        "blue": Color(hex: "4E89AE"),
        "green": Color(hex: "43D8C4"),
        "yellow": Color(hex: "FFCC29"),
        "purple": Color(hex: "95389E"),
        "orange": Color(hex: "F08A5D"),
        "cyan": Color(hex: "08D9D6")
    ]

    static let accent = Color(hex: "FF2E63")

    static func skColor(_ color: Color) -> UIColor {
        return UIColor(color)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
