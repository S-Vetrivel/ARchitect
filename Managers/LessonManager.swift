import Foundation

struct LessonStep {
    let icon: String
    let title: String
    let instruction: String
    let hint: String
    let showCodeEditor: Bool
    let goal: GoalType
    
    init(icon: String, title: String, instruction: String, hint: String = "", showCodeEditor: Bool = false, goal: GoalType = .none) {
        self.icon = icon
        self.title = title
        self.instruction = instruction
        self.hint = hint
        self.showCodeEditor = showCodeEditor
        self.goal = goal
    }
}

struct PreRequisiteEntity: Codable {
    let name: String
    let shape: String        // "sphere", "box", "belt"
    let color: String
    let radius: Float
    let positionX: Float
    let orbitRadius: Float?
    let orbitSpeed: Float?
    let parentName: String?  // if set, entity is a child of the named entity
    let count: Int?          // for procedural generation (belt); nil = 1 entity
}

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let conceptExplanation: String
    let codeSnippet: String
    let challenges: [Challenge]
    let steps: [LessonStep]
    let codeEditorStartStep: Int
    let prerequisites: [PreRequisiteEntity]
}

@MainActor
class LessonManager {
    static let shared = LessonManager()
    
    let lessons: [Lesson] = [
        
        // MARK: - Level 1: Starbirth
        Lesson(
            id: 1,
            title: "Starbirth",
            instruction: "Initialize a G-Type Main Sequence Star.",
            conceptExplanation: """
            **System Initialization**
            
            Welcome, Architect.
            We are in the Stellar Nursery.
            Your first task is to ignite a Star.
            
            Task:
            - ☀️ Create a **Sphere**
            - 📏 Radius: **0.5** (Large)
            - 🎨 Color: **.yellow** (G-Type)
            """,
            codeSnippet: """
            let radius: Float = 0.1
            let starColor: Color = .gray
            """,
            challenges: [Challenge(id: "ignition", description: "Ignite the Sun", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "power", title: "System Initialized...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Tap anywhere to spawn a protostar core.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Sun")),
                LessonStep(icon: "terminal.fill", title: "Open console. Change color to .yellow and radius to 0.5.", instruction: "", hint: "Edit code", showCodeEditor: true, goal: .modifyProperty(target: "Sun", requiredColor: "yellow", minRadius: 0.4))
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 2: Goldilocks Zone
        Lesson(
            id: 2,
            title: "Goldilocks Zone",
            instruction: "Place a habitable planet at a safe distance.",
            conceptExplanation: """
            **Habitable Zone Calculation**
            
            We need a planet capable of supporting life.
            It must optionally position itself away from the Sun.
            
            Task:
            - 🌍 Create Earth
            - 📍 Position: **x: 0.8** (80cm away)
            - 🎨 Color: **.blue**
            """,
            codeSnippet: """
            let positionX: Float = 0.0
            let positionY: Float = 0.0
            let positionZ: Float = 0.0
            """,
            challenges: [Challenge(id: "goldilocks", description: "Place Earth", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "power", title: "The Star is stable. We need a habitable planet...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Tap near the Star to spawn a planetary mass.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Earth")),
                LessonStep(icon: "terminal.fill", title: "Warning: Planet is too close to the Star! Open console and set positionX to 0.8.", instruction: "", hint: "Edit code", showCodeEditor: true, goal: .modifyPosition(target: "Earth", targetX: 0.8))
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil)
            ]
        ),
        
        // MARK: - Level 3: Orbital Mechanics
        Lesson(
            id: 3,
            title: "Orbital Mechanics",
            instruction: "Set the planet in motion around the Star.",
            conceptExplanation: """
            **Kepler's Laws**
            
            A static planet will fall into the star.
            We need **Orbital Velocity**.
            
            Task:
            - 🔄 Set **Orbit Radius** to match position (0.8)
            - ⏱️ Set **Orbit Speed** (1.0 = 1 radian/sec)
            """,
            codeSnippet: """
            let orbitRadius: Float = 0.0
            let orbitSpeed: Float = 0.0
            """,
            challenges: [Challenge(id: "orbit_stabilized", description: "Stabilize Orbit", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "exclamationmark.triangle.fill", title: "Warning: Planet is stationary. Gravity will pull it into the Star...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "terminal.fill", title: "Open the console and inject momentum. Set orbitRadius to 0.8 and orbitSpeed to 0.5.", instruction: "", hint: "Edit code", showCodeEditor: true, goal: .modifyOrbit(target: "Earth", targetRadius: 0.8, targetSpeed: 0.5)),
                LessonStep(icon: "hare.fill", title: "Orbit is stable but slow. Increase orbitSpeed to 2.0.", instruction: "", hint: "Speed it up", showCodeEditor: true, goal: .modifyOrbit(target: "Earth", targetRadius: 0.8, targetSpeed: 2.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "System Clock Active. Years are passing in seconds.", instruction: "Time is relative.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil)
            ]
        ),
        
        // MARK: - Level 4: Lunar Injection
        Lesson(
            id: 4,
            title: "Lunar Injection",
            instruction: "Create a Moon orbiting the Earth.",
            conceptExplanation: """
            **Satellite Deployment**
            
            Planets can have their own satellites.
            This moon will orbit Earth, while Earth orbits the Sun.
            This is a **Hierarchical Orbit**.
            
            Task:
            - 🌑 Create Moon (Small, Gray)
            - 🔄 Orbit Radius: **0.2** (Close to Earth)
            - 🏎️ Orbit Speed: **3.0** (Fast)
            """,
            codeSnippet: """
            let orbitRadius: Float = 0.0
            let orbitSpeed: Float = 0.0
            let radius: Float = 0.05
            """,
            challenges: [Challenge(id: "lunar_orbit", description: "Deploy Moon", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "moon.fill", title: "Earth is lonely. Initiate Lunar Injection.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "terminal.fill", title: "Open console. Set orbitRadius to 0.2 and orbitSpeed to 3.0.", instruction: "", hint: "Run the code", showCodeEditor: true, goal: .placeSatellite(parent: "Earth", name: "Moon", targetRadius: 0.2, targetSpeed: 3.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Tidal forces stabilized. Surfing is now possible.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil)
            ]
        ),
        
        // MARK: - Level 5: The Belt
        Lesson(
            id: 5,
            title: "The Belt",
            instruction: "Generate a field of debris.",
            conceptExplanation: """
            **Procedural Generation**
            
            We need thousands of rocks, not just one.
            We will use a loop to create a debris field.
            
            Task:
            - 🪨 Create **20** Asteroids
            - 🎨 Randomize colors (Gray/Brown)
            - 📏 Randomize sizes
            """,
            codeSnippet: """
            let count: Int = 0
            let orbitRadius: Float = 1.5
            """,
            challenges: [Challenge(id: "asteroid_belt", description: "Create Belt", targetCount: 20, xpReward: 300)],
            steps: [
                LessonStep(icon: "sparkles", title: "We need a barrier. Initiate debris field.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "loop", title: "Open console. Change count to 20 to generate the belt.", instruction: "", hint: "count: 20", showCodeEditor: true, goal: .generateBelt(target: "Sun", minCount: 20, targetRadius: 1.5)),
                LessonStep(icon: "checkmark.circle.fill", title: "Navigation is hazardous. Perfect defense system.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil)
            ]
        ),
        
        // MARK: - Level 6: Singularity
        Lesson(
            id: 6,
            title: "Singularity",
            instruction: "Controlling the fundamental forces of the universe.",
            conceptExplanation: """
            **Gravity Engine**
            
            Every world has gravity pulling objects down.
            Earth = **9.8** m/s². Deep space has none.
            
            Task:
            - 🌍 Default gravity is **9.8**
            - 🛸 Set to **0.0** for Anti-Gravity
            """,
            codeSnippet: """
            let gravity: Float = 9.8
            """,
            challenges: [Challenge(id: "gravity_mastery", description: "Zero Gravity", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "arrow.down.to.line.alt", title: "Place a Test Probe.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Test Probe")),
                LessonStep(icon: "exclamationmark.triangle.fill", title: "Warning: Deep space has no gravity. Open console and set gravity to 0.0.", instruction: "", hint: "gravity: 0.0", showCodeEditor: true, goal: .modifyGravity(targetGravity: 0.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Gravity deactivated. The probe floats gracefully...", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 7: Warp Drive
        Lesson(
            id: 7,
            title: "Warp Drive",
            instruction: "Moving objects through a vacuum using thrust.",
            conceptExplanation: """
            **Linear Impulses**
            
            We need to send a ship to the Outer Rim.
            Gravity is not enough. We need **Thrust**.
            
            Task:
            - 💨 Apply **Force Z: -15.0**
            - 🚀 Launch **Forward** (Negative Z is forward in ARKit)
            """,
            codeSnippet: """
            let forceY: Float = 5.0
            let forceZ: Float = 0.0
            """,
            challenges: [Challenge(id: "warp_drive", description: "Launch Ship", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "airplane", title: "Place a Starship.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Starship")),
                LessonStep(icon: "flame.fill", title: "Console shows upward thrust (forceY). Change forceY to 0.0, and forceZ to -15.0.", instruction: "", hint: "forceZ: -15.0", showCodeEditor: true, goal: .applyForce(target: "Starship", requiredZ: -15.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Warp engaged. Trajectory confirmed.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 8: Vacuum Drift
        Lesson(
            id: 8,
            title: "Vacuum Drift",
            instruction: "Understanding inertia in space.",
            conceptExplanation: """
            **Vacuum Physics**
            
            In space, there is no air resistance or friction.
            An object in motion stays in motion.
            
            Task:
            - 🧊 Set **Friction** to **0.0**
            - ⛸️ Watch it **glide forever**
            """,
            codeSnippet: """
            let friction: Float = 1.0
            """,
            challenges: [Challenge(id: "frictionless_space", description: "Zero Friction", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "cube.box", title: "Place a Supply Crate.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Crate")),
                LessonStep(icon: "stop.fill", title: "It stopped quickly due to friction. Change friction to 0.0 to simulate a vacuum.", instruction: "", hint: "friction: 0.0", showCodeEditor: true, goal: .modifyPhysics(target: "Crate", targetFriction: 0.0, targetMass: nil, targetRestitution: nil)),
                LessonStep(icon: "checkmark.circle.fill", title: "Friction systems offline. Eternal glide achieved.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 9: Kinetic Strike
        Lesson(
            id: 9,
            title: "Kinetic Strike",
            instruction: "Using heavy mass to clear blockades.",
            conceptExplanation: """
            **Kinetic Impact**
            
            A debris field is blocking our path.
            We need a heavy projectile to clear it.
            
            Task:
            - 🧱 Set **Mass** to **50.0**
            - 💥 **Smash** through lighter objects
            """,
            codeSnippet: """
            let mass: Float = 1.0
            """,
            challenges: [Challenge(id: "mass_impact", description: "Heavy Impact", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "sparkles", title: "Space Debris detected ahead.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "circle.dotted", title: "Spawn a standard Meteor core.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Meteor")),
                LessonStep(icon: "burst.fill", title: "Standard mass is too light. Increase mass to 50.0.", instruction: "", hint: "mass: 50.0", showCodeEditor: true, goal: .modifyPhysics(target: "Meteor", targetFriction: nil, targetMass: 50.0, targetRestitution: nil)),
                LessonStep(icon: "checkmark.circle.fill", title: "Impact successful. Path cleared.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 3,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 10: Deflector Shields
        Lesson(
            id: 10,
            title: "Deflector Shields",
            instruction: "Bounce projectiles away with shields.",
            conceptExplanation: """
            **Shield Generator**
            
            Meteors are incoming!
            We need a shield that reflects kinetic energy perfectly.
            
            Task:
            - 🛡️ Set **Restitution** to **1.0**
            - 💫 **Bounce** threats away without damage
            """,
            codeSnippet: """
            let restitution: Float = 0.1
            """,
            challenges: [Challenge(id: "perfect_bounce", description: "100% Bounciness", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "shield.slash.fill", title: "Place a Shield Generator.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Shield")),
                LessonStep(icon: "arrow.down", title: "Test asteroid absorbed damage. Change restitution to 1.0 for 100% reflection.", instruction: "", hint: "restitution: 1.0", showCodeEditor: true, goal: .modifyPhysics(target: "Shield", targetFriction: nil, targetMass: nil, targetRestitution: 1.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Asteroid deflected harmlessly. Sector secured.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 11: Orbital Outpost
        Lesson(
            id: 11,
            title: "Orbital Outpost",
            instruction: "Building a space station out of primitives.",
            conceptExplanation: """
            **Shape Composition**
            
            Complex structures are built from simple shapes.
            Let's build a modular space station.
            
            Task:
            - 🛠️ Use `shape: cylinder` or `box`
            - 📐 Scale them to form a core and solar panels
            - 🏗️ Place 3 primitive shapes together
            """,
            codeSnippet: """
            let shape: String = "cylinder"
            let scaleX: Float = 1.0
            let scaleY: Float = 3.0
            let scaleZ: Float = 1.0
            """,
            challenges: [Challenge(id: "modular_build", description: "Build Station", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "building.2.fill", title: "Construct the central cylinder core.", instruction: "", hint: "Shape: cylinder", showCodeEditor: true, goal: .buildOutpost(requiredParts: 1)),
                LessonStep(icon: "squareshape.fill", title: "Add two flat boxes for solar panels.", instruction: "", hint: "Scale flat", showCodeEditor: true, goal: .buildOutpost(requiredParts: 3)),
                LessonStep(icon: "checkmark.circle.fill", title: "Outpost Construction Complete.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        ),
        
        // MARK: - Level 12: Universe Sandbox
        Lesson(
            id: 12,
            title: "Universe Sandbox",
            instruction: "Total freedom.",
            conceptExplanation: """
            **Creative Mode**
            
            All systems unlocked.
            Build solar systems, outposts, or smash entire fleets.
            
            You have mastered the ARchitect Engine.
            """,
            codeSnippet: """
            // Unlocked Engine Parameters
            let shape: String = "sphere"
            let color: Color = .cyan
            let scaleX: Float = 1.0
            
            let mass: Float = 1.0
            let friction: Float = 0.5
            let restitution: Float = 0.5
            let gravity: Float = 9.8
            
            let forceZ: Float = 0.0
            let orbitRadius: Float = 0.0
            """,
            challenges: [Challenge(id: "sandbox_master", description: "Creative Mode Unlocked", targetCount: 1, xpReward: 500)],
            steps: [
                LessonStep(icon: "infinity", title: "Welcome to the Sandbox. Build anything.", instruction: "", hint: "Have fun", showCodeEditor: true, goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Moon", shape: "sphere", color: "gray", radius: 0.05, positionX: 0, orbitRadius: 0.2, orbitSpeed: 3.0, parentName: "Earth", count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 20)
            ]
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
