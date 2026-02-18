import Foundation

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let conceptExplanation: String
    let codeSnippet: String
    let challenges: [Challenge]
}

@MainActor
class LessonManager {
    static let shared = LessonManager()
    
    let lessons: [Lesson] = [
        Lesson(
            id: 1,
            title: "Welcome to ARchitect",
            instruction: "Follow the interactive guide to learn the controls.",
            conceptExplanation: """
            **Your Virtual Studio**
            
            ARchitect lets you build 3D worlds using code and gestures.
            
            In this tutorial, you'll learn:
            - 👀 How to **look around** (swipe/drag)
            - 🚶 How to **walk** (joystick)
            - 🔍 How to **zoom** (pinch/scroll)
            - 📦 How to **place objects** (tap)
            - 💻 How to **edit code** (code editor)
            """,
            codeSnippet: """
            // Change the values below and tap!
            // Try: .red, .green, .yellow, .purple
            // width: 0.15, height: 0.05, chamfer: 0.02
            // color: .blue
            
            let anchor = AnchorEntity(world: transform)
            let mesh = MeshResource.generateBox(
                size: [0.15, 0.05, 0.15],
                cornerRadius: 0.02
            )
            var mat = SimpleMaterial(
                color: .blue,
                isMetallic: true
            )
            arView.scene.addAnchor(anchor)
            """,
            challenges: [
                Challenge(id: "tutorial_complete", description: "Complete the tutorial", targetCount: 1, xpReward: 100)
            ]
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
