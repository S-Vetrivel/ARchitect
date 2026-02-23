import SwiftUI

struct ContentView: View {
    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var showContent = false
    @State private var holdTimer: Timer? = nil
    
    var body: some View {
        ZStack {
            // Background
            // Background
            if gameManager.isARActive {
                ARViewContainer()
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .id(gameManager.viewRecreationId) // Recreate ARView on mode toggle
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged { value in
                                // Only process if in Simulation Mode and Lesson allows it
                                guard gameManager.isSimulationMode else { return }
                                
                                if !gameManager.isJoystickActive {
                                    // 1. Detect Hold to Activate
                                    if holdTimer == nil {
                                        let startLocation = value.startLocation
                                        // Start the timer to activate joystick
                                        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                                            DispatchQueue.main.async {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    gameManager.joystickOrigin = startLocation
                                                    gameManager.isJoystickActive = true
                                                }
                                                HapticsManager.shared.play(.light)
                                            }
                                        }
                                    }
                                    
                                    // 2. Cancel if Dragged (Swipe/Pan detection)
                                    let dragDistance = sqrt(
                                        pow(value.translation.width, 2) +
                                        pow(value.translation.height, 2)
                                    )
                                    if dragDistance > 10 {
                                        holdTimer?.invalidate()
                                        holdTimer = nil
                                    }
                                } else {
                                    // 3. Joystick Logic (Active)
                                    let outerRadius: CGFloat = 60
                                    let innerRadius: CGFloat = 25
                                    let maxDistance = outerRadius - innerRadius
                                    
                                    let dx = value.location.x - gameManager.joystickOrigin.x
                                    let dy = value.location.y - gameManager.joystickOrigin.y
                                    let distance = sqrt(dx * dx + dy * dy)
                                    
                                    var x: Float = 0
                                    var y: Float = 0
                                    
                                    if distance <= maxDistance {
                                        x = Float(dx / maxDistance)
                                        y = Float(dy / maxDistance)
                                    } else {
                                        let scale = maxDistance / distance
                                        x = Float((dx * scale) / maxDistance)
                                        y = Float((dy * scale) / maxDistance)
                                    }
                                    
                                    gameManager.joystickInput = SIMD2<Float>(x, -y) // Invert Y
                                }
                            }
                            .onEnded { _ in
                                // Cleanup
                                holdTimer?.invalidate()
                                holdTimer = nil
                                
                                if gameManager.isJoystickActive {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        gameManager.isJoystickActive = false
                                        gameManager.joystickInput = .zero
                                    }
                                }
                            }
                    )
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
