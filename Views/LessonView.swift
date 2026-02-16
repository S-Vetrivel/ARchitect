import SwiftUI

struct LessonView: View {
    @ObservedObject var gameManager = GameManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    
    var currentLesson: Lesson? {
        LessonManager.shared.getLesson(id: gameManager.currentLessonIndex)
    }
    
    var body: some View {
        VStack {
            // Top Bar
            HStack {
                Text(currentLesson?.title ?? "Lesson")
                    .font(.headline)
                    .foregroundColor(themeManager.text)
                    .padding()
                    .background(themeManager.secondaryBackground.opacity(0.8))
                    .cornerRadius(10)
                Spacer()
                Button("Exit") {
                    gameManager.appState = .welcome
                }
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top, 40)
            .padding(.horizontal)
            
            Spacer()
            
            // Feedback Overlay
            if gameManager.isTaskCompleted {
                VStack(spacing: 15) {
                    Text("✅ Task Completed!")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                    
                    if gameManager.currentLessonIndex < 5 {
                        Button("Next Lesson") {
                            gameManager.startLesson(gameManager.currentLessonIndex + 1)
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    } else {
                        Text("Course Completed! 🎉")
                            .font(.title3)
                            .foregroundColor(themeManager.text)
                    }
                }
                .padding()
                .background(themeManager.background.opacity(0.9))
                .cornerRadius(15)
                .padding(.bottom, 20)
            } else {
                // Instruction & Code
                VStack(alignment: .leading, spacing: 10) {
                    Text("Instruction:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(currentLesson?.instruction ?? "Task")
                        .font(.body.bold())
                        .foregroundColor(themeManager.text)
                    
                    Divider()
                    
                    Text("Code Behind:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(currentLesson?.codeSnippet ?? "// Code")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.cyan)
                        .padding(10)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(5)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.secondaryBackground.opacity(0.9))
                .cornerRadius(15)
                .padding()
            }
        }
    }
}
