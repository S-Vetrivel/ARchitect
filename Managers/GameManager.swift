import SwiftUI
import Combine

enum AppState: Equatable {
    case welcome
    case lesson(Int) // 1 to 5
    case arExperience
}

@MainActor
class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var appState: AppState = .welcome
    @Published var currentLessonIndex: Int = 1
    
    // User Profile
    @AppStorage("userName") var userName: String = "Student"
    
    // Lesson Progress
    @Published var isTaskCompleted: Bool = false
    @Published var feedbackMessage: String = ""
    
    private init() {}
    
    func startLesson(_ lesson: Int) {
        currentLessonIndex = lesson
        appState = .lesson(lesson)
        isTaskCompleted = false
        feedbackMessage = ""
    }
    
    func completeTask() {
        isTaskCompleted = true
        feedbackMessage = "Great job! Task Completed. ✅"
    }
}
