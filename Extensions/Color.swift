import SwiftUI
import UIKit

extension Color {

    static let secondaryColor = Color("secondaryColor")
    static let primaryColor = Color("Primary")

    static let addPostBtnColor = Color("addPostBtnColor")
    static let slabColor = Color("slabColor")
    static let gradient1 = Color(hex: "#2A6FFA")
    static let gradient2 = Color(hex: "#6717CE")
    static let dropShadow = Color(hex: "aeaec0").opacity(0.4)
    static let dropLight = Color(hex: "ffffff")
    static let offWhite = Color("offwhite")
    
    static var goodGray: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .gray // Change to your desired dark mode color
        } else {
            return Color(.systemGray3) // Default light mode color
        }
    }
    
    static let lightmodebg = LinearGradient(colors: [Color.gradient1, Color.gradient2], startPoint: .leading, endPoint: .trailing)
    
    static var mainColor: Color {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .green // Change to your desired dark mode color
        } else {
            return .green // Default light mode color
        }
    }
    
    
    static let selectedColor = Color("selectedColor")
    
    
    init?(uiColor: UIColor?) {
        guard let uiColor else {
            return nil
        }
        self.init(uiColor: uiColor)
    }
    
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
    
    var uiColor: UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        }
        let components = components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
    
    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}


struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.3).opacity(0.8), // Dark blue hue
                Color.black
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .edgesIgnoringSafeArea(.all) // Extend the gradient to the entire screen
    }
}

struct RainbowGradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .red, .orange, .yellow, .green, .blue, .purple
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .edgesIgnoringSafeArea(.all) // Extend the gradient to the entire screen
    }
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
