import SwiftUI

struct ContentView: View {
    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
                .grayscale(gameManager.appState == .welcome ? 1.0 : 0.0)
                .blur(radius: gameManager.appState == .welcome ? 10 : 0)
            
            // UI Overlay
            Group {
                switch gameManager.appState {
                case .welcome:
                    WelcomeView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                case .lesson(_):
                    LessonView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                case .arExperience:
                    EmptyView()
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameManager.appState)
        }
    }
}
