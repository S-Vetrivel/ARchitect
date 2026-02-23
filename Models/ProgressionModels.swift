import Foundation
import SwiftUI

// MARK: - XP & Leveling
// Rank system removed as per user request.
// Keeping totalXP for internal tracking/badges if needed.


// MARK: - Goals
enum GoalType: Equatable {
    case none
    case placeCelestialBody(mass: Float)
    case achieveOrbit(targetSpeed: Float)
    case destructObstacle
    case deflectAsteroid
    case any
}

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
        Badge(id: "star_forge", name: "Star Forge", description: "Ignite a new star.", iconName: "sparkles", xpReward: 100),
        Badge(id: "orbital_architect", name: "Orbital Architect", description: "Master planetary motion.", iconName: "arrow.2.circlepath", xpReward: 150),
        Badge(id: "kessler_syndrome", name: "Kessler Syndrome", description: "Create an asteroid belt.", iconName: "moon.stars.fill", xpReward: 200),
        Badge(id: "gravity_master", name: "Gravity Master", description: "Control the forces of gravity.", iconName: "arrow.down.to.line.alt", xpReward: 250),
        Badge(id: "shield_tactician", name: "Shield Tactician", description: "Deflect incoming threats.", iconName: "shield.fill", xpReward: 300),
        Badge(id: "completionist", name: "Cosmic ARchitect", description: "Complete the cosmic curriculum.", iconName: "checkmark.seal.fill", xpReward: 500)
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
