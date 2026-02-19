import SwiftUI
import CoreHaptics

// MARK: - Nebula Design System (Space Theme)

// MARK: - Nebula Colors
extension Color {
    // Backgrounds
    static let nebulaBackground = Color(red: 0.03, green: 0.03, blue: 0.08) // Deepest Void
    static let nebulaCard = Color(red: 0.08, green: 0.08, blue: 0.15).opacity(0.6) // Frosted Glass base
    
    // Accents
    static let starlight = Color.white
    static let nebulaAccent = Color(red: 0.4, green: 0.2, blue: 1.0) // Deep Purple
    static let nebulaCyan = Color(red: 0.0, green: 0.8, blue: 1.0) // Bright Cyan (UI Highlights)
    static let nebulaTeal = Color(red: 0.0, green: 0.9, blue: 0.7) // Success/Good
    static let nebulaWarning = Color(red: 1.0, green: 0.6, blue: 0.2) // Warning/Attention
    static let solarFlare = Color(red: 1.0, green: 0.3, blue: 0.1) // Error/Danger

    // Aliases for compatibility
    static let studioBackground = nebulaBackground
    static let studioAccent = nebulaCyan
    static let studioWarning = nebulaWarning
}

// MARK: - Nebula Typography
extension Font {
    // Reuse Studio fonts but mapped to space naming if needed
    static func nebulaTitle() -> Font {
        .system(size: 34, weight: .bold, design: .rounded)
    }
    
    static func nebulaHeadline() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func nebulaBody() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }
    
    static func nebulaCaption() -> Font {
        .system(size: 13, weight: .medium, design: .monospaced) // Monospaced feels techy in space
    }
    
    // Compatibility
    static func studioLargeTitle() -> Font { nebulaTitle() }
    static func studioHeadline() -> Font { nebulaHeadline() }
    static func studioBody() -> Font { nebulaBody() }
    static func studioCaption() -> Font { nebulaCaption() }
}


// MARK: - Haptics (Shared)
@MainActor
class HapticsManager {
    static let shared = HapticsManager()
    private init() {}
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
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

// MARK: - Nebula Components

// 1. Frosted Glass Card (Nebula Style)
struct NebulaCard: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial) // Native blur
            .background(Color.nebulaCard) // tint
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(LinearGradient(colors: [.white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: Color.nebulaAccent.opacity(0.2), radius: 15, x: 0, y: 5)
    }
}

// 2. Cosmic Button (Glows)
struct CosmicButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.nebulaHeadline())
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .background(
                LinearGradient(
                    colors: [Color.nebulaAccent, Color.blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.nebulaAccent.opacity(configuration.isPressed ? 0.3 : 0.6), radius: configuration.isPressed ? 5 : 10)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Compatibility extensions
extension View {
    func nebulaCard() -> some View {
        modifier(NebulaCard())
    }
    
    // Alias for existing usages
    func studioCard() -> some View {
        modifier(NebulaCard())
    }
}

// Alias
typealias StudioButtonStyle = CosmicButtonStyle
