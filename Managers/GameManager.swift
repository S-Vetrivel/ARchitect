import SwiftUI
import Combine
import ARKit
import RealityKit

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
    @Published var codeSnippet: String = ""
    @Published var isSimulationMode: Bool = false
    @Published var viewRecreationId: Int = 0 // Forces ARView recreation on toggle
    
    // Tutorial/Lesson Step State
    @Published var tutorialStep: Int = 0  // Used for ALL lessons now: 0=not started, 1+=active steps
    @Published var tutorialWalkDistance: Float = 0
    @Published var joystickInput: SIMD2<Float> = .zero
    @Published var zoomInput: Float = 0 // +1 = zoom in, -1 = zoom out (for buttons)
    @Published var placedObjectCount: Int = 0 // Track objects placed in current lesson
    @Published var customGravity: Float = 9.8 // Adjustable gravity (0 = float, 9.8 = Earth, 20 = heavy)
    
    // Joystick State (Global for gesture/visual sync)
    @Published var isJoystickActive: Bool = false
    @Published var joystickOrigin: CGPoint = .zero
    
    // Console Execution State Bridge
    @Published var triggerConsoleExecution: Bool = false
    
    // Computed Properties
    
    var isARActive: Bool {
        if case .lesson(_) = appState { return true }
        if case .arExperience = appState { return true }
        return false
    }
    
    var currentLesson: Lesson? {
        LessonManager.shared.getLesson(id: currentLessonIndex)
    }
    
    /// Total steps for the current lesson
    var currentStepCount: Int {
        return currentLesson?.steps.count ?? 0
    }

    var highestUnlockedLevelIndex: Int {
        let completed = completedLessonIds.split(separator: ",").compactMap { Int($0) }
        let maxCompleted = completed.max() ?? 0
        return min(maxCompleted + 1, LessonManager.shared.lessons.count)
    }
    
    /// Whether the current step should show the code editor
    var shouldShowCodeEditor: Bool {
        guard let lesson = currentLesson else { return false }
        if tutorialStep < lesson.steps.count {
            return lesson.steps[tutorialStep].showCodeEditor
        }
        return false
    }
    
    /// Whether the code editor should be available (any step from codeEditorStartStep onward)
    var isCodeEditorAvailable: Bool {
        guard let lesson = currentLesson else { return false }
        return tutorialStep >= lesson.codeEditorStartStep
    }
    
    private init() {
        // Auto-detect Simulation Mode for non-AR devices
        #if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
        isSimulationMode = true
        #else
        isSimulationMode = !ARWorldTrackingConfiguration.isSupported
        #endif
    }
    
    func toggleSimulationMode() {
        isSimulationMode.toggle()
        viewRecreationId += 1 // Forces ARView to be destroyed and recreated
        // Re-enter the lesson to reset state
        if case .lesson(let id) = appState {
            startLesson(id)
        }
    }
    
    func startLesson(_ lesson: Int) {
        currentLessonIndex = lesson
        appState = .lesson(lesson)
        isTaskCompleted = false
        feedbackMessage = ""
        tutorialStep = 0
        tutorialWalkDistance = 0
        placedObjectCount = 0
        if let lessonData = LessonManager.shared.getLesson(id: lesson) {
            codeSnippet = lessonData.codeSnippet
        }
    }
    
    func advanceTutorial() {
        let maxSteps = currentStepCount
        guard tutorialStep < maxSteps else { return }
        tutorialStep += 1
        HapticsManager.shared.notify(.success)
        
        if tutorialStep >= maxSteps {
            // Lesson complete!
            completeTask()
        }
    }
    
    func resetTutorial() {
        tutorialStep = 0
        tutorialWalkDistance = 0
        placedObjectCount = 0
        isTaskCompleted = false
    }
    
    func completeTask() {
        if !isTaskCompleted {
            isTaskCompleted = true
            feedbackMessage = "Great job! Task Completed. ✅"
            addXP(50) // Base XP for completing a task
            markLessonComplete(id: currentLessonIndex)
            
            // Award badges based on lesson
            switch currentLessonIndex {
            case 1: unlockBadge(id: "first_steps")
            case 2: unlockBadge(id: "star_forge")
            case 3: unlockBadge(id: "orbital_architect")
            case 5: unlockBadge(id: "kessler_syndrome")
            case 6: unlockBadge(id: "gravity_master")
            case 10: unlockBadge(id: "shield_tactician")
            default: break
            }
            
            // Check if all 10 levels are complete
            let allLessonIds = Array(1...10)
            let allComplete = allLessonIds.allSatisfy { isLessonCompleted(id: $0) }
            if allComplete {
                unlockBadge(id: "completionist")
            }
        }
    }
    
    // Evaluate if the current AR scene satisfies the current step's goal
    func evaluateCurrentGoal(context: Any) {
        guard let arView = context as? ARView,
              let lesson = currentLesson,
              tutorialStep < lesson.steps.count else { return }
        
        // Don't evaluate if we are already transitioning or task is completed
        guard !isTaskCompleted else { return }
        
        let currentGoal = lesson.steps[tutorialStep].goal
        switch currentGoal {
        case .none, .any:
            // Handled explicitly by UI continuation or Tap gestures
            break
            
        case .placeEntity, .modifyProperty, .modifyPosition, .modifyOrbit, .placeSatellite, .generateBelt, .modifyGravity, .applyForce, .modifyPhysics, .buildOutpost:
            // Handled by handleTap or evaluateConsoleExecution in ARViewContainer
            break
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
    
    func isLessonUnlocked(id: Int) -> Bool {
        if id == 1 { return true }
        return isLessonCompleted(id: id - 1)
    }

    func isLessonCompleted(id: Int) -> Bool {
        return completedLessonIds.split(separator: ",").contains(Substring(String(id)))
    }
}
