import Foundation
import SwiftUI

// MARK: - XP & Leveling
// Rank system removed as per user request.
// Keeping totalXP for internal tracking/badges if needed.


// MARK: - Badges
struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let xpReward: Int
    var isUnlocked: Bool = false
    
    static let allBadges: [Badge] = [
        // Chapter 1: Foundations (1-4)
        Badge(id: "first_steps", name: "First Steps", description: "Complete the tutorial.", iconName: "shoeprints.fill", xpReward: 50),
        Badge(id: "physics_beginner", name: "Physics Beginner", description: "Learn gravity & mass.", iconName: "arrow.down.to.line.alt", xpReward: 75),
        Badge(id: "bounce_master", name: "Bounce Master", description: "Master restitution & collisions.", iconName: "basketball.fill", xpReward: 100),
        Badge(id: "force_wielder", name: "Force Wielder", description: "Control impulse forces.", iconName: "wind", xpReward: 125),
        // Chapter 2: Building Blocks (5-9)
        Badge(id: "scale_artist", name: "Scale Artist", description: "Master object scaling.", iconName: "arrow.up.left.and.arrow.down.right", xpReward: 100),
        Badge(id: "color_wizard", name: "Color Wizard", description: "Paint the AR world.", iconName: "paintpalette.fill", xpReward: 100),
        Badge(id: "shape_master", name: "Shape Master", description: "Build with all shapes.", iconName: "cube.fill", xpReward: 100),
        Badge(id: "sharpshooter", name: "Sharpshooter", description: "Hit targets with projectiles.", iconName: "target", xpReward: 150),
        Badge(id: "demolition_expert", name: "Demolition Expert", description: "Topple physics towers.", iconName: "square.stack.3d.up.fill", xpReward: 150),
        // Chapter 3: Physics Mastery (10-17)
        Badge(id: "physics_master", name: "Physics Master", description: "Complete Physics Mastery.", iconName: "atom", xpReward: 200),
        // Chapter 4: Shooting Range (18-25)
        Badge(id: "marksman", name: "Elite Marksman", description: "Complete the Shooting Range.", iconName: "scope", xpReward: 200),
        // Chapter 5: Architecture (26-33)
        Badge(id: "master_builder", name: "Master Builder", description: "Complete Architecture.", iconName: "building.2.fill", xpReward: 200),
        // Chapter 6: Creative Studio (34-41)
        Badge(id: "creative_genius", name: "Creative Genius", description: "Complete Creative Studio.", iconName: "paintbrush.pointed.fill", xpReward: 200),
        // Chapter 7: Master Challenges (42-49)
        Badge(id: "grand_master", name: "Grand Master", description: "Complete Master Challenges.", iconName: "crown.fill", xpReward: 300),
        // Free Build + Completionist
        Badge(id: "free_builder", name: "Free Builder", description: "Unlock sandbox mode.", iconName: "wand.and.stars", xpReward: 200),
        Badge(id: "completionist", name: "Certified ARchitect", description: "Complete all 50 lessons.", iconName: "checkmark.seal.fill", xpReward: 500)
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
