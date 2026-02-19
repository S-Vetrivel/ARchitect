import SwiftUI

struct LessonView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var showCode = false
    
    var currentLesson: Lesson? {
        LessonManager.shared.getLesson(id: gameManager.currentLessonIndex)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if geo.size.width > geo.size.height {
                    landscapeLayout(geo: geo)
                } else {
                    portraitLayout(geo: geo)
                }
            }
        }
        .onAppear {
            VolumeManager.shared.start()
        }
        .onDisappear {
            VolumeManager.shared.stop()
        }
    }
    
    // MARK: - Landscape Layout
    
    @ViewBuilder
    func landscapeLayout(geo: GeometryProxy) -> some View {
        ZStack {
            // 1. Top Controls (HUD) - Top Left / Center
            VStack {
                HStack(spacing: 12) {
                    CyberpunkBackButton()
                    
                    // Mode Toggle
                    Button(action: {
                        withAnimation { gameManager.toggleSimulationMode() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: gameManager.isSimulationMode ? "cube.transparent" : "camera.fill")
                                .font(.system(size: 12))
                            Text(gameManager.isSimulationMode ? "SIMULATION" : "AR LIVE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(gameManager.isSimulationMode ? .orange : .cyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .background(gameManager.isSimulationMode ? Color.orange.opacity(0.1) : Color.cyan.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(gameManager.isSimulationMode ? Color.orange.opacity(0.3) : Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                
                if gameManager.isTaskCompleted {
                    MissionSuccessBadge()
                        .padding(.top, 20)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
            }
            // ZIndex 2 ensures HUD is clickable
            .zIndex(2)
            
            // 2. Tutorial Overlay - Top Left (floating below header)
            if gameManager.currentLessonIndex == 1 {
                VStack {
                    Spacer().frame(height: 100)
                    HStack {
                        TutorialOverlayView()
                            .frame(width: 380) // Fixed width card
                            .padding(.leading, 30)
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(1)
            } else {
                LessonOverlayView()
                    .zIndex(1)
            }
            
            // 3. Joystick Visuals (Overlay)
            JoystickVisuals()
                .zIndex(3)
                .transition(.opacity)
            
            // 4. Code Editor - Floating Right Panel
            if gameManager.isCodeEditorAvailable && !gameManager.isTaskCompleted {
                HStack {
                    Spacer()
                    codeEditorPanel(geo: geo)
                        .frame(width: 350) // Floating panel width
                        .padding(.trailing, 20)
                        .padding(.vertical, 40)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
                .zIndex(4)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
    }
    
    // MARK: - Portrait Layout
    
    @ViewBuilder
    func portraitLayout(geo: GeometryProxy) -> some View {
        ZStack {
            // 1. Controls Layer
            VStack(spacing: 0) {
                // Top HUD
                HStack(spacing: 12) {
                    CyberpunkBackButton()
                    
                    // Mode Toggle
                    Button(action: {
                        withAnimation { gameManager.toggleSimulationMode() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: gameManager.isSimulationMode ? "cube.transparent" : "camera.fill")
                                .font(.system(size: 12))
                            Text(gameManager.isSimulationMode ? "SIM" : "AR")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(gameManager.isSimulationMode ? .orange : .cyan)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .background(gameManager.isSimulationMode ? Color.orange.opacity(0.1) : Color.cyan.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(gameManager.isSimulationMode ? Color.orange.opacity(0.3) : Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 10)
                
                // Tutorial / Lesson Overlay - AT TOP
                if gameManager.currentLessonIndex == 1 {
                    TutorialOverlayView()
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .frame(height: 300, alignment: .top) // Allocate top space
                } else {
                    LessonOverlayView()
                }
                
                Spacer()
                
                // Mission Badge
                if gameManager.isTaskCompleted {
                    MissionSuccessBadge()
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .zIndex(1)
            
            // 2. Joystick Visuals (Overlay)
            JoystickVisuals()
                .zIndex(2)
                .transition(.opacity)
            
            // 3. Code Drawer - Bottom Sheet
            if gameManager.isCodeEditorAvailable && !gameManager.isTaskCompleted {
                CodeDrawer(showCode: $showCode, codeSnippet: $gameManager.codeSnippet)
                    .zIndex(3)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
    }
    
    // MARK: - Code Editor Panel (Floating Glass)
    
    @ViewBuilder
    func codeEditorPanel(geo: GeometryProxy) -> some View {
        ZStack {
            // Glass Background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.6))
                .overlay(
                     RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 20) {
                // Header / Intro
                VStack(spacing: 8) {
                    Text("Mission: Color Change")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Change the color of your object to proceed.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)
                
                // Editor
                ModernCodeEditor(text: $gameManager.codeSnippet, showCode: $showCode)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Code Hint Box
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Hint: Change `.blue` to `.red`")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


// MARK: - Components

struct ModernCodeEditor: View {
    @Binding var text: String
    @Binding var showCode: Bool // To close/minimize if needed
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar / Header
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Circle().fill(Color.yellow).frame(width: 10, height: 10)
                    Circle().fill(Color.green).frame(width: 10, height: 10)
                }
                .onTapGesture {
                    withAnimation { showCode = false }
                }
                
                Spacer()
                
                Text("main.swift")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    // Simulate "Run" action
                    HapticsManager.shared.play(.medium)
                    isFocused = false // Dismiss keyboard
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                        Text("RUN")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(red: 0.15, green: 0.15, blue: 0.17))
            
            Divider().background(Color.white.opacity(0.1))
            
            // Editor Area
            ZStack(alignment: .topLeading) {
                Color(red: 0.11, green: 0.11, blue: 0.13) // Dark Background
                
                HStack(alignment: .top, spacing: 0) {
                    // Line Numbers
                    Text(lineNumbers)
                        .font(.system(size: 14, design: .monospaced)) // Match Editor font
                        .foregroundColor(.gray.opacity(0.5))
                        .multilineTextAlignment(.trailing)
                        .padding(.top, 8) // Match TextEditor padding default roughly
                        .padding(.leading, 12)
                        .padding(.trailing, 8)
                        .frame(minWidth: 30, alignment: .trailing)
                        .background(Color(red: 0.13, green: 0.13, blue: 0.15))
                    
                    // Code Input
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $text)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .focused($isFocused)
                            .padding(.top, 0) // Align with line numbers
                    } else {
                        TextEditor(text: $text)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white)
                            .focused($isFocused)
                            .padding(.top, 0)
                    }
                }
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = false
                }
            }
        }
    }
    
    var lineNumbers: String {
        let count = text.split(separator: "\n", omittingEmptySubsequences: false).count
        return (1...max(1, count)).map { "\($0)" }.joined(separator: "\n")
    }
}

// MARK: - Components

struct MissionSuccessBadge: View {
    @ObservedObject var gameManager = GameManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.white)
                .symbolRenderingMode(.hierarchical)
            
            Text("Tutorial Complete!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // Back to Map
                Button(action: {
                    withAnimation { gameManager.appState = .levelMap }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 20))
                        Text("Map")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 80, height: 60)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Next Mission (Primary)
                Button(action: {
                    withAnimation {
                        let nextLevel = gameManager.currentLessonIndex + 1
                        if nextLevel <= 50 { // Max levels
                            gameManager.startLesson(nextLevel)
                        } else {
                            gameManager.appState = .levelMap
                        }
                    }
                }) {
                    HStack {
                        Text("Next Mission")
                            .font(.headline)
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .cyan.opacity(0.5), radius: 8)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .background(Color.blue.opacity(0.3))
        .cornerRadius(24)
        .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 40)
    }
}

struct CodeDrawer: View {
    @Binding var showCode: Bool
    @Binding var codeSnippet: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Drawer Tab
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showCode.toggle()
                }
            }) {
                HStack {
                    Text("Code Editor")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.up")
                        .rotationEffect(.degrees(showCode ? 180 : 0))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(16, corners: [.topLeft, .topRight])
            }
            .opacity(showCode ? 0 : 1) // Hide tab when open, or keep it? Let's hide it effectively or just transition it. 
            // Actually, keep the tab logic simple. If open, we show the full editor which has its own header.
            
            if showCode {
                ZStack(alignment: .top) {
                    if #available(iOS 15.0, *) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay(Color.black.opacity(0.8))
                            .ignoresSafeArea()
                    } else {
                        Color.black.opacity(0.9)
                            .ignoresSafeArea()
                    }
                    
                    VStack(spacing: 0) {
                        // Hint bar
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("Hint: Change .blue to .red")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.8))
                            Spacer()
                            Button(action: { withAnimation { showCode = false } }) {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.05))
                        
                        ModernCodeEditor(text: $codeSnippet, showCode: $showCode)
                            .padding()
                            .frame(maxHeight: 400)
                    }
                }
                .frame(height: 450)
                .transition(.move(edge: .bottom))
            }
        }
    }
}



// MARK: - Utilities

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Back Button

struct CyberpunkBackButton: View {
    @ObservedObject var gameManager = GameManager.shared
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.play(.light)
            withAnimation {
                gameManager.appState = .levelMap
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                Text("EXIT")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .background(Color.red.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
            )
        }
    }
}
