import SwiftUI

struct LessonView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var showCode = false
    
    var currentLesson: Lesson? {
        LessonManager.shared.getLesson(id: gameManager.currentLessonIndex)
    }
    
    var body: some View {
        ZStack {
            VStack {
                // HUD Top Bar
                HStack {
                    Button(action: {
                        HapticsManager.shared.play(.medium)
                        gameManager.appState = .levelMap
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("ABORT")
                        }
                        .font(.tacticalData(size: 14))
                        .foregroundColor(.alertRed)
                        .padding(8)
                        .background(Color.darkPanel)
                        .border(Color.alertRed.opacity(0.5), width: 1)
                    }
                    
                    Spacer()
                    
                    Text("OBJECTIVE: \(currentLesson?.title.uppercased() ?? "UNKNOWN")")
                        .font(.tacticalData(size: 12))
                        .foregroundColor(.tacticalAmber)
                        .padding(8)
                        .background(Color.darkPanel)
                        .border(Color.tacticalAmber.opacity(0.5), width: 1)
                }
                .padding()
                
                // Mission Parameters
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PARAMETERS:")
                            .font(.tacticalData(size: 10))
                            .foregroundColor(.gray)
                        
                        Text(currentLesson?.instruction ?? "AWAITING ORDERS")
                            .font(.tacticalBody(size: 16))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1)
                    }
                    .padding()
                    .background(Color.darkPanel.opacity(0.8))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if gameManager.isTaskCompleted {
                    VStack(spacing: 20) {
                        Text("MISSION SUCCESS")
                            .font(.tacticalHeader(size: 30))
                            .foregroundColor(.terminalGreen)
                            .shadow(color: .terminalGreen, radius: 10)
                            .scaleEffect(1.1)
                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: true)
                        
                        if gameManager.currentLessonIndex < 5 {
                            Button(action: {
                                HapticsManager.shared.notify(.success)
                                withAnimation {
                                    gameManager.startLesson(gameManager.currentLessonIndex + 1)
                                }
                            }) {
                                Text("NEXT OPERATION >>")
                                    .font(.tacticalData(size: 18))
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.terminalGreen)
                                    .cornerRadius(2)
                                    .shadow(color: .terminalGreen, radius: 10)
                            }
                        } else {
                            Button("RETURN TO BASE") {
                                withAnimation { gameManager.appState = .levelMap }
                            }
                            .font(.tacticalData(size: 16))
                            .foregroundColor(.tacticalAmber)
                            .padding()
                            .border(Color.tacticalAmber, width: 2)
                        }
                    }
                    .padding(40)
                    .background(Color.voidBlack.opacity(0.9))
                    .border(Color.terminalGreen, width: 2)
                }
                
                Spacer()
                
                // Code Terminal
                VStack(spacing: 0) {
                    Button(action: { withAnimation { showCode.toggle() } }) {
                        HStack {
                            Text("> VIEW_SOURCE_CODE")
                                .font(.tacticalData(size: 12))
                                .foregroundColor(.tacticalAmber)
                            Spacer()
                            Image(systemName: showCode ? "chevron.down" : "chevron.up")
                                .foregroundColor(.tacticalAmber)
                        }
                        .padding()
                        .background(Color.voidBlack)
                        .border(Color.tacticalAmber.opacity(0.3), width: 1)
                    }
                    
                    if showCode {
                        ScrollView {
                            Text(currentLesson?.codeSnippet ?? "")
                                .font(.tacticalData(size: 12))
                                .foregroundColor(.terminalGreen)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 200)
                        .background(Color.black.opacity(0.95))
                    }
                }
            }
        }
    }
}
