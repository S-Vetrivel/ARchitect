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
                    // Top Controls
                    HStack(spacing: 12) {
                        CyberpunkBackButton()
                        
                        // Mode Toggle (grouped with back button for cleaner UI)
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
                            .padding(.bottom, 50)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                
                // Lesson Overlay
                if gameManager.currentLessonIndex == 1 {
                    TutorialOverlayView()
                } else {
                    LessonOverlayView()
                }
                
                // Controls (bottom area)
                if gameManager.isSimulationMode {
                    VStack {
                        HStack(alignment: .bottom) {
                            Spacer()
                            
                            // Zoom Buttons (Level 1: from Step 4+ / Levels 2+: always)
                            if gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 4 {
                                VStack(spacing: 8) {
                                    ZoomButton(label: "+", zoomValue: 1)
                                    ZoomButton(label: "−", zoomValue: -1)
                                }
                                .padding(.trailing, 12)
                                .transition(.scale.combined(with: .opacity))
                            }
                            
                            // Joystick (Level 1: from Step 3+ / Levels 2+: always)
                            if gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 3 {
                                JoystickView()
                                    .padding(.trailing, 40)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
            .frame(width: geo.size.width * 0.65)
            
            // Right: Code Editor
            if gameManager.isCodeEditorAvailable {
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
                
                Spacer()
                
                if gameManager.isTaskCompleted {
                    MissionSuccessBadge()
                        .padding(.bottom, 20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            // Lesson Overlay
            if gameManager.currentLessonIndex == 1 {
                TutorialOverlayView()
            } else {
                LessonOverlayView()
            }
            
            // Controls (bottom area)
            if gameManager.isSimulationMode {
                VStack {
                    HStack(alignment: .bottom) {
                        Spacer()
                        
                        if gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 4 {
                            VStack(spacing: 8) {
                                ZoomButton(label: "+", zoomValue: 1)
                                ZoomButton(label: "−", zoomValue: -1)
                            }
                            .padding(.trailing, 12)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        if gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 3 {
                            JoystickView()
                                .padding(.trailing, 30)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 180)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Code Editor Drawer
            if gameManager.isCodeEditorAvailable {
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
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
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
                .padding(.top, 40)
                
                // Editor
                ModernCodeEditor(text: $gameManager.codeSnippet, showCode: $showCode)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                // Code Hint Box
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Try changing `.blue` to `.red`, `.green`, or `.orange`.")
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
