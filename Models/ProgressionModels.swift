import Foundation
import SwiftUI

// MARK: - XP & Leveling
struct LevelInfo {
    let level: Int
    let title: String
    let xpRequired: Int
}

let levelThresholds: [LevelInfo] = [
    LevelInfo(level: 1, title: "Intern", xpRequired: 0),
    LevelInfo(level: 2, title: "Draftsman", xpRequired: 100),
    LevelInfo(level: 3, title: "Surveyor", xpRequired: 300),
    LevelInfo(level: 4, title: "Engineer", xpRequired: 600),
    LevelInfo(level: 5, title: "Architect", xpRequired: 1000),
    LevelInfo(level: 6, title: "Master Builder", xpRequired: 1500)
]

// MARK: - Badges
struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let xpReward: Int
    var isUnlocked: Bool = false
    
    static let allBadges: [Badge] = [
        Badge(id: "first_steps", name: "First Steps", description: "Complete the tutorial.", iconName: "shoeprints.fill", xpReward: 50),
        Badge(id: "completionist", name: "Certified ARchitect", description: "Complete all lessons.", iconName: "checkmark.seal.fill", xpReward: 500)
    ]
}

// MARK: - Challenges
struct Challenge: Identifiable, Codable {
    let id: String
    let description: String
    let targetCount: Int
    var currentCount: Int = 0
    let xpReward: Int
    
    var isCompleted: Bool {
        return currentCount >= targetCount
    }
    
    var progress: Float {
        return Float(currentCount) / Float(targetCount)
    }
}
