import Foundation

struct LessonStep {
    let icon: String
    let title: String
    let instruction: String
    let hint: String
    let showCodeEditor: Bool
    let autoAdvance: Bool  // If true, step advances via interaction detection, not tap
    
    init(icon: String, title: String, instruction: String, hint: String = "", showCodeEditor: Bool = false, autoAdvance: Bool = false) {
        self.icon = icon
        self.title = title
        self.instruction = instruction
        self.hint = hint
        self.showCodeEditor = showCodeEditor
        self.autoAdvance = autoAdvance
    }
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let conceptExplanation: String
    let codeSnippet: String
    let challenges: [Challenge]
    let steps: [LessonStep]
    let codeEditorStartStep: Int  // Step index from which code editor is available
}

@MainActor
class LessonManager {
    static let shared = LessonManager()
    
    let lessons: [Lesson] = [
        
        // MARK: - Level 1: Welcome Tutorial
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
            ],
            steps: [], // Level 1 uses TutorialOverlayView's hardcoded steps
            codeEditorStartStep: 6
        ),
        
        // MARK: - Level 2: Gravity & Mass
        Lesson(
            id: 2,
            title: "Gravity & Mass",
            instruction: "Learn how gravity and mass affect objects in AR.",
            conceptExplanation: """
            **Newton's First Lesson**
            
            In the real world, objects fall because of gravity.
            In AR, objects float unless you give them physics!
            
            You'll learn:
            - ⬇️ How to enable **gravity** on objects
            - ⚖️ How **mass** changes fall behavior
            - 📦 How to make objects **solid** with collision
            """,
            codeSnippet: """
            // Physics Properties
            // Change mass to see different effects!
            // mass: 1.0  (try 0.1, 5.0, 20.0)
            // color: .cyan
            // shape: box
            
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: 1.0),
                material: .default,
                mode: .dynamic
            )
            entity.components[PhysicsBodyComponent.self] = physics
            """,
            challenges: [
                Challenge(id: "gravity_drop", description: "Drop an object with gravity", targetCount: 1, xpReward: 75)
            ],
            steps: [
                LessonStep(
                    icon: "arrow.down.to.line.alt",
                    title: "Welcome to Physics!",
                    instruction: "In this lesson, you'll learn how gravity\nworks in augmented reality.\nTap to begin!",
                    hint: "Gravity pulls objects down"
                ),
                LessonStep(
                    icon: "cube.fill",
                    title: "Step 1: Place a Box",
                    instruction: "Tap on the floor to place a static box.\nNotice it just sits there — no physics yet!",
                    hint: "Tap the floor!",
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "Step 2: Read the Code",
                    instruction: "Open the code editor.\nThis code adds a PhysicsBody to your object.\n`mass: 1.0` controls how heavy it is.",
                    hint: "Swipe up the code editor",
                    showCodeEditor: true
                ),
                LessonStep(
                    icon: "arrow.down.circle.fill",
                    title: "Step 3: Enable Gravity!",
                    instruction: "Tap your box to apply physics.\nWatch it fall with gravity! 🎉",
                    hint: "Tap your placed object",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "scalemass.fill",
                    title: "Step 4: Change the Mass",
                    instruction: "In the code editor, change\n`mass: 1.0` to `mass: 10.0`\nPlace a new box and apply physics.\nSee the difference!",
                    hint: "Heavier objects look the same but interact differently",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "checkmark.circle.fill",
                    title: "Level Complete! 🎉",
                    instruction: "You've learned basic gravity!\nObjects need PhysicsBody to be affected\nby gravity and collisions.",
                    hint: ""
                )
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Level 3: Bounce & Collide
        Lesson(
            id: 3,
            title: "Bounce & Collide",
            instruction: "Discover how objects bounce and collide.",
            conceptExplanation: """
            **Elastic Worlds**
            
            When objects hit the ground, do they stop or bounce?
            That depends on **restitution** — the bounciness factor!
            
            You'll learn:
            - 🏀 How **restitution** controls bounce
            - 🔵 How to create **spheres** that roll
            - 💥 How objects **collide** with each other
            """,
            codeSnippet: """
            // Bounce Physics
            // restitution: 0.8  (0=no bounce, 1=perfect bounce)
            // mass: 1.0
            // color: .orange
            // shape: sphere
            
            let material = PhysicsMaterialResource.generate(
                staticFriction: 0.5,
                dynamicFriction: 0.5,
                restitution: 0.8
            )
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: 1.0),
                material: material,
                mode: .dynamic
            )
            """,
            challenges: [
                Challenge(id: "bounce_object", description: "Make an object bounce", targetCount: 1, xpReward: 100)
            ],
            steps: [
                LessonStep(
                    icon: "basketball.fill",
                    title: "Welcome to Bouncing!",
                    instruction: "Objects can bounce when they collide.\nIt all depends on their bounciness.\nTap to begin!",
                    hint: "restitution = bounciness"
                ),
                LessonStep(
                    icon: "circle.fill",
                    title: "Step 1: Place a Sphere",
                    instruction: "Tap the floor to place a bouncy sphere.\nIt will drop with gravity and bounce!",
                    hint: "Tap the floor!",
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "eye.fill",
                    title: "Step 2: Watch it Bounce!",
                    instruction: "See how the sphere bounces?\nThe code has `restitution: 0.8`\nwhich means 80% bounce energy.\nTap to continue.",
                    hint: "Higher restitution = more bounce",
                    showCodeEditor: true
                ),
                LessonStep(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "Step 3: Max Bounce!",
                    instruction: "Change `restitution: 0.8` to\n`restitution: 1.0` in the code.\nPlace another sphere to see\na perfect bounce!",
                    hint: "1.0 = no energy lost",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Step 4: No Bounce",
                    instruction: "Now try `restitution: 0.0`\nPlace another sphere —\nit should thud and stop!",
                    hint: "0.0 = all energy absorbed",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "checkmark.circle.fill",
                    title: "Level Complete! 🎉",
                    instruction: "You now understand restitution!\n0 = dead stop, 1 = perfect bounce.\nReal-world rubber is about 0.8.",
                    hint: ""
                )
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Level 4: Forces & Impulse
        Lesson(
            id: 4,
            title: "Forces & Impulse",
            instruction: "Learn to push objects with code-driven forces.",
            conceptExplanation: """
            **Push & Launch**
            
            Gravity pulls things down, but forces can push
            objects in ANY direction!
            
            You'll learn:
            - 💨 How to apply **impulse** forces
            - ➡️ How **direction vectors** work (x, y, z)
            - 🎯 How to aim and launch objects
            """,
            codeSnippet: """
            // Force Control
            // Edit the force vector to change direction!
            // forceX: 0.0  (left/right)
            // forceY: 5.0  (up/down)
            // forceZ: -3.0 (forward/back)
            // mass: 1.0
            // color: .green
            // shape: box
            
            let force = SIMD3<Float>(0.0, 5.0, -3.0)
            entity.addForce(force, relativeTo: nil)
            """,
            challenges: [
                Challenge(id: "launch_object", description: "Launch an object with force", targetCount: 1, xpReward: 125)
            ],
            steps: [
                LessonStep(
                    icon: "wind",
                    title: "Welcome to Forces!",
                    instruction: "In this lesson, you'll launch objects\nusing force vectors.\nTap to begin!",
                    hint: "F = m × a"
                ),
                LessonStep(
                    icon: "cube.fill",
                    title: "Step 1: Place an Object",
                    instruction: "Tap the floor to place your launch pad.\nThis will be your projectile!",
                    hint: "Tap the floor!",
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "chevron.left.forwardslash.chevron.right",
                    title: "Step 2: Read the Force Code",
                    instruction: "The code defines a force vector:\n`forceY: 5.0` pushes UP\n`forceZ: -3.0` pushes FORWARD\nTap to continue.",
                    hint: "Positive Y = up, Negative Z = forward",
                    showCodeEditor: true
                ),
                LessonStep(
                    icon: "arrow.up.forward",
                    title: "Step 3: Launch It!",
                    instruction: "Tap your object to apply the force!\nWatch it fly! 🚀",
                    hint: "Tap the object you placed",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "pencil.circle.fill",
                    title: "Step 4: Change Direction",
                    instruction: "Edit the code:\n`forceY: 10.0` for higher launch\n`forceZ: -8.0` for further reach\nPlace and launch again!",
                    hint: "Bigger numbers = stronger force",
                    showCodeEditor: true,
                    autoAdvance: true
                ),
                LessonStep(
                    icon: "checkmark.circle.fill",
                    title: "Level Complete! 🎉",
                    instruction: "You can now control forces!\nForce vectors (x, y, z) let you\npush objects in any direction.",
                    hint: ""
                )
            ],
            codeEditorStartStep: 2
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
