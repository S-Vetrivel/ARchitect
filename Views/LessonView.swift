
import SwiftUI

struct LessonView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var showCode = false // For portrait drawer
    
    var currentLesson: Lesson? {
        LessonManager.shared.getLesson(id: gameManager.currentLessonIndex)
    }
    
    var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if isLandscape {
                    // Background - Clean AR view pass-through or subtle gradient
                    // Color.black.ignoresSafeArea() // REMOVED to show AR Feed
                        // MARK: - Landscape / iPad Layout (Split Screen)
                        HStack(spacing: 0) {
                            // Left Side: Code Editor (35% width)
                            ZStack {
                                if #available(iOS 15.0, *) {
                                    Rectangle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(Color.blue.opacity(0.2)) // Blue Tint
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
                                    
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 24) {
                                            // Objective
                                            VStack(alignment: .leading, spacing: 8) {
                                                Label("OBJECTIVE", systemImage: "target")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                Text(currentLesson?.title ?? "Unknown Lesson")
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            // Instructions
                                            VStack(alignment: .leading, spacing: 8) {
                                                Label("INSTRUCTIONS", systemImage: "list.bullet")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white.opacity(0.7))
                                                
                                                Text(currentLesson?.instruction ?? "No instructions provided.")
                                                    .font(.body)
                                                    .foregroundColor(.white.opacity(0.9))
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            
                                            Divider()
                                                .overlay(Color.white.opacity(0.2))
                                            
                                            // Code Editor
                                            VStack(alignment: .leading, spacing: 12) {
                                                Label("SWIFT SNIPPET", systemImage: "chevron.left.forwardslash.chevron.right")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white.opacity(0.7))
                                                
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
                                                            .frame(minHeight: 300)
                                                    } else {
                                                        TextEditor(text: $gameManager.codeSnippet)
                                                            .font(.system(.body, design: .monospaced))
                                                            .foregroundColor(.white)
                                                            .padding(12)
                                                            .frame(minHeight: 300)
                                                    }
                                                }
                                            }
                                        }
                                        .padding()
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.35)
                            
                            // Right Side: AR View Overlay (Just Success Badge)
                            ZStack {
                                VStack {
                                    Spacer()
                                    if gameManager.isTaskCompleted {
                                        MissionSuccessBadge()
                                            .padding(.bottom, 50)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .frame(width: geo.size.width * 0.65)
                        }
                        
                    } else {
                        // MARK: - Portrait Layout (Glass Sheet Overlay)
                        ZStack {
                            VStack(spacing: 0) {
                                // Top HUD - Floating Glass Pill
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
                                        .background(Color.blue.opacity(0.2)) // Tint
                                        .cornerRadius(20)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Lesson \(currentLesson?.id ?? 0)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .background(Color.blue.opacity(0.2)) // Tint
                                        .cornerRadius(20)
                                }
                                .padding()
                                
                                // Instruction Card
                                VStack(alignment: .leading, spacing: 8) {
                                    Label("TASK", systemImage: "checkmark.circle")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(currentLesson?.instruction ?? "")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                                .background(Color.blue.opacity(0.15)) // Tint
                                .cornerRadius(16)
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                if gameManager.isTaskCompleted {
                                    MissionSuccessBadge()
                                        .padding(.bottom, 20)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            // Bottom Code Sheet
                            CodeDrawer(showCode: $showCode, codeSnippet: $gameManager.codeSnippet)
                        }
                    }
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
                .padding(.bottom, 4)
            
            Text("Lesson Complete!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if gameManager.currentLessonIndex < 5 {
                Button(action: {
                    HapticsManager.shared.notify(.success)
                    withAnimation {
                        gameManager.startLesson(gameManager.currentLessonIndex + 1)
                    }
                }) {
                    Text("Next Lesson")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            } else {
                Button(action: {
                    withAnimation { gameManager.appState = .levelMap }
                }) {
                    Text("Finish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .background(Color.blue.opacity(0.3)) // Stronger Tint for Success
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
            
            // Drawer Handle / Header
            Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showCode.toggle() } }) {
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
                .background(Color.blue.opacity(0.2)) // Tint
                .cornerRadius(16, corners: [.topLeft, .topRight])
            }
            .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
            
            if showCode {
                ZStack(alignment: .topLeading) {
                    if #available(iOS 15.0, *) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .overlay(Color.blue.opacity(0.2)) // Tint
                            .ignoresSafeArea()
                    } else {
                        Color.black.opacity(0.85)
                            .overlay(Color.blue.opacity(0.2))
                            .ignoresSafeArea()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
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
