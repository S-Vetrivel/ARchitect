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
    }
    
    // MARK: - Landscape Layout
    
    @ViewBuilder
    func landscapeLayout(geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            // Left: AR View + Tutorial Overlay
            ZStack {
                VStack {
                    // Mode Toggle (top)
                    Button(action: {
                        withAnimation { gameManager.toggleSimulationMode() }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: gameManager.isSimulationMode ? "video.slash.fill" : "video.fill")
                            Text(gameManager.isSimulationMode ? "SIM" : "LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(gameManager.isSimulationMode ? .orange : .green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    if gameManager.isTaskCompleted {
                        MissionSuccessBadge()
                            .padding(.bottom, 50)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                
                // Tutorial Overlay
                TutorialOverlayView()
                
                // Controls (bottom area)
                if gameManager.isSimulationMode {
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            Spacer()
                            
                            // Zoom Buttons (from Step 4+)
                            if gameManager.tutorialStep >= 4 {
                                VStack(spacing: 8) {
                                    ZoomButton(label: "+", zoomValue: 1)
                                    ZoomButton(label: "−", zoomValue: -1)
                                }
                                .padding(.trailing, 12)
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Joystick (from Step 3+)
                            if gameManager.tutorialStep >= 3 {
                                JoystickView()
                                    .padding(.trailing, 40)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .frame(width: geo.size.width * 0.65)
            
            // Right: Code Editor (only show from Step 6+)
            if gameManager.tutorialStep >= 6 {
                codeEditorPanel(geo: geo)
                    .frame(width: geo.size.width * 0.35)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
    }
    
    // MARK: - Portrait Layout
    
    @ViewBuilder
    func portraitLayout(geo: GeometryProxy) -> some View {
        ZStack {
            VStack(spacing: 0) {
                // Top HUD
                HStack {
                    Button(action: {
                        HapticsManager.shared.play(.light)
                        gameManager.appState = .levelMap
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Exit")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Mode Toggle
                    Button(action: {
                        withAnimation { gameManager.toggleSimulationMode() }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: gameManager.isSimulationMode ? "video.slash.fill" : "video.fill")
                                .font(.caption2)
                            Text(gameManager.isSimulationMode ? "SIM" : "LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(gameManager.isSimulationMode ? .orange : .green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }
                }
                .padding()
                
                Spacer()
                
                if gameManager.isTaskCompleted {
                    MissionSuccessBadge()
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Tutorial Overlay
            TutorialOverlayView()
            
            // Controls (bottom area)
            if gameManager.isSimulationMode {
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        Spacer()
                        
                        if gameManager.tutorialStep >= 4 {
                            VStack(spacing: 8) {
                                ZoomButton(label: "+", zoomValue: 1)
                                ZoomButton(label: "−", zoomValue: -1)
                            }
                            .padding(.trailing, 12)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        if gameManager.tutorialStep >= 3 {
                            JoystickView()
                                .padding(.trailing, 30)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 180)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Code Editor Drawer (only from Step 6+)
            if gameManager.tutorialStep >= 6 {
                CodeDrawer(showCode: $showCode, codeSnippet: $gameManager.codeSnippet)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
    }
    
    // MARK: - Code Editor Panel (Landscape)
    
    @ViewBuilder
    func codeEditorPanel(geo: GeometryProxy) -> some View {
        ZStack {
            if #available(iOS 15.0, *) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay(Color.blue.opacity(0.2))
                    .ignoresSafeArea()
            } else {
                Color.black.opacity(0.8)
                    .overlay(Color.blue.opacity(0.2))
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Code Editor")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        HapticsManager.shared.play(.light)
                        gameManager.appState = .levelMap
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                
                // Code snippet hint
                VStack(alignment: .leading, spacing: 8) {
                    Label("EDIT THE CODE", systemImage: "pencil")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow.opacity(0.9))
                    
                    Text("Change `color: .blue` to another color like `.red`, `.green`, or `.purple`, then tap your object!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.yellow.opacity(0.08))
                
                // Editor
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $gameManager.codeSnippet)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                    } else {
                        TextEditor(text: $gameManager.codeSnippet)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                    }
                }
                .padding()
            }
        }
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
            
            Button(action: {
                withAnimation { gameManager.appState = .levelMap }
            }) {
                Text("Back to Map")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
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
            
            if showCode {
                ZStack(alignment: .topLeading) {
                    if #available(iOS 15.0, *) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay(Color.blue.opacity(0.2))
                            .ignoresSafeArea()
                    } else {
                        Color.black.opacity(0.85)
                            .overlay(Color.blue.opacity(0.2))
                            .ignoresSafeArea()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Hint bar
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("Change color: .blue to .red, then tap your object!")
                                .font(.caption)
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.yellow.opacity(0.08))
                        
                        if #available(iOS 16.0, *) {
                            TextEditor(text: $codeSnippet)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .padding()
                        } else {
                            TextEditor(text: $codeSnippet)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .frame(height: 350)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

// MARK: - Zoom Button

struct ZoomButton: View {
    let label: String
    let zoomValue: Float
    @ObservedObject var gameManager = GameManager.shared
    @State private var isPressed = false
    
    var body: some View {
        Text(label)
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(Color.white.opacity(isPressed ? 0.3 : 0.15))
                    .overlay(
                        Circle()
                            .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            gameManager.zoomInput = zoomValue
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        gameManager.zoomInput = 0
                    }
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
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
