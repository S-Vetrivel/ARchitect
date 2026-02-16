import SwiftUI
import CoreHaptics

// MARK: - Tactical Colors
extension Color {
    static let voidBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let tacticalAmber = Color(red: 1.0, green: 0.75, blue: 0.0) // Amber CRT
    static let alertRed = Color(red: 0.9, green: 0.1, blue: 0.1)
    static let gunmetal = Color(red: 0.2, green: 0.25, blue: 0.3)
    static let terminalGreen = Color(red: 0.1, green: 0.8, blue: 0.1)
    static let darkPanel = Color(red: 0.1, green: 0.12, blue: 0.15)
}

// MARK: - Tactical Typography
extension Font {
    static func tacticalHeader(size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .monospaced)
    }
    
    static func tacticalBody(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
    
    static func tacticalData(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }
}

// MARK: - Haptics
@MainActor
class HapticsManager {
    static let shared = HapticsManager()
    private init() {}
    
    func play(_ feedback: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: feedback)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

// MARK: - Tactical Components
struct TacticalBorder: ViewModifier {
    var color: Color = .tacticalAmber
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    // Corner Brackets
                    HStack {
                        VStack {
                            CornerPiece()
                            Spacer()
                            CornerPiece().rotationEffect(.degrees(-90))
                        }
                        Spacer()
                        VStack {
                            CornerPiece().rotationEffect(.degrees(90))
                            Spacer()
                            CornerPiece().rotationEffect(.degrees(180))
                        }
                    }
                    
                    // Scanline
                    Rectangle()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                }
            )
    }
}

struct CornerPiece: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 15, y: 0))
        }
        .stroke(Color.tacticalAmber, lineWidth: 3)
        .frame(width: 15, height: 15)
    }
}

extension View {
    func tacticalBorder(color: Color = .tacticalAmber) -> some View {
        modifier(TacticalBorder(color: color))
    }
}
