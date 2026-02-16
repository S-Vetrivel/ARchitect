import SwiftUI
import Combine

enum AppState: Equatable {
    case welcome
    case levelMap
    case lesson(Int) // 1 to 5
    case arExperience
}

@MainActor
class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var appState: AppState = .welcome
    @Published var currentLessonIndex: Int = 1
    
    // User Profile
    @AppStorage("userName") var userName: String = "Intern"
    @AppStorage("totalXP") var totalXP: Int = 0
    @AppStorage("unlockedBadgeIds") var unlockedBadgeIds: String = "" // Comma separated IDs
    @AppStorage("completedLessonIds") var completedLessonIds: String = "" // Comma separated IDs
    
    // Lesson Progress
    @Published var isTaskCompleted: Bool = false
    @Published var feedbackMessage: String = ""
    
    // Computed Properties
    var currentLevelInfo: LevelInfo {
        return levelThresholds.last { totalXP >= $0.xpRequired } ?? levelThresholds[0]
    }
    
    var progressToNextLevel: Float {
        let currentLevel = currentLevelInfo
        guard let nextLevel = levelThresholds.first(where: { $0.level == currentLevel.level + 1 }) else { return 1.0 }
        
        let range = Float(nextLevel.xpRequired - currentLevel.xpRequired)
        let progress = Float(totalXP - currentLevel.xpRequired)
        return progress / range
    }
    
    private init() {}
    
    func startLesson(_ lesson: Int) {
        currentLessonIndex = lesson
        appState = .lesson(lesson)
        isTaskCompleted = false
        feedbackMessage = ""
    }
    
    func completeTask() {
        if !isTaskCompleted {
            isTaskCompleted = true
            feedbackMessage = "Great job! Task Completed. ✅"
            addXP(50) // Base XP for completing a task
            markLessonComplete(id: currentLessonIndex)
        }
    }
    
    func addXP(_ amount: Int) {
        totalXP += amount
    }
    
    func unlockBadge(id: String) {
        var currentBadges = unlockedBadgeIds.split(separator: ",").map { String($0) }
        if !currentBadges.contains(id) {
            currentBadges.append(id)
            unlockedBadgeIds = currentBadges.joined(separator: ",")
            // Find badge to get XP reward
            if let badge = Badge.allBadges.first(where: { $0.id == id }) {
                addXP(badge.xpReward)
                feedbackMessage = "Badge Unlocked: \(badge.name)! 🏆"
            }
        }
    }
    
    func markLessonComplete(id: Int) {
        var completed = completedLessonIds.split(separator: ",").map { String($0) }
        let idStr = String(id)
        if !completed.contains(idStr) {
            completed.append(idStr)
            completedLessonIds = completed.joined(separator: ",")
        }
    }
    
    func isBadgeUnlocked(id: String) -> Bool {
        return unlockedBadgeIds.split(separator: ",").contains(Substring(id))
    }
    
    func isLessonCompleted(id: Int) -> Bool {
        return completedLessonIds.split(separator: ",").contains(Substring(String(id)))
    }
}
