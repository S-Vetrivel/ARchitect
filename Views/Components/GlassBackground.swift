import SwiftUI

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var shadowRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.2), radius: shadowRadius, x: 0, y: 5)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
    }
}

extension View {
    func glass(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
}

struct GlassCard<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .glass()
    }
}
