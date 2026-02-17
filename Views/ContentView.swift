import SwiftUI

struct ContentView: View {
    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background
            // Background
            if gameManager.isARActive {
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .id(gameManager.viewRecreationId) // Recreate ARView on mode toggle
            } else {
                // Static Background for non-AR screens to save battery
                LinearGradient(
                    colors: [Color.black, Color(uiColor: .darkGray)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            // UI Overlay
            Group {
                switch gameManager.appState {
                case .welcome:
                    WelcomeView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .scale(scale: 1.2).combined(with: .opacity)
                        ))
                case .levelMap:
                    LevelMapView()
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity
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
