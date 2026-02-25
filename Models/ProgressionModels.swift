import Foundation
import SwiftUI

// MARK: - XP & Leveling
// Rank system removed as per user request.
// Keeping totalXP for internal tracking/badges if needed.


// MARK: - Goals
enum GoalType: Equatable {
    case none
    case placeEntity(name: String)
    case modifyProperty(target: String, requiredColor: String, minRadius: Float)
    case modifyPosition(target: String, targetX: Float)
    case modifyOrbit(target: String, targetRadius: Float, targetSpeed: Float)
    case placeSatellite(parent: String, name: String, targetRadius: Float, targetSpeed: Float)
    case generateBelt(target: String, minCount: Int, targetRadius: Float)
    case modifyGravity(targetGravity: Float)
    case applyForce(target: String, requiredZ: Float)
    case modifyPhysics(target: String, targetFriction: Float?, targetMass: Float?, targetRestitution: Float?)
    case buildOutpost(requiredParts: Int)
    case any
    case sandbox
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
