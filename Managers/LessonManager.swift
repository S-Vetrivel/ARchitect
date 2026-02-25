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
    let category: String
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
    
    static let categories = ["Stellar Genesis", "Force & Motion", "Engineering", "Advanced Systems", "Mastery"]
    
    let lessons: [Lesson] = [
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - ★ CATEGORY 1: STELLAR GENESIS (Levels 1–5)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // MARK: - Level 1: Starbirth
        Lesson(
            id: 1,
            title: "Starbirth",
            category: "Stellar Genesis",
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
            category: "Stellar Genesis",
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
            category: "Stellar Genesis",
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
            category: "Stellar Genesis",
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
            category: "Stellar Genesis",
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
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - ★ CATEGORY 2: FORCE & MOTION (Levels 6–10)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // MARK: - Level 6: Singularity
        Lesson(
            id: 6,
            title: "Singularity",
            category: "Force & Motion",
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
            let shape: String = "box"
            let gravity: Float = 9.8
            """,
            challenges: [Challenge(id: "gravity_mastery", description: "Zero Gravity", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "arrow.down.to.line.alt", title: "Gravity Engine online. Testing gravitational pull...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Place a Test Probe.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Test Probe")),
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
            category: "Force & Motion",
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
            let shape: String = "cone"
            let forceY: Float = 5.0
            let forceZ: Float = 0.0
            """,
            challenges: [Challenge(id: "warp_drive", description: "Launch Ship", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "airplane", title: "Warp Drive system initializing...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Place a Starship.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Starship")),
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
            category: "Force & Motion",
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
            let shape: String = "box"
            let friction: Float = 1.0
            """,
            challenges: [Challenge(id: "frictionless_space", description: "Zero Friction", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "cube.box", title: "Vacuum conditions detected. Testing inertia...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Place a Supply Crate.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Crate")),
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
            category: "Force & Motion",
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
            codeEditorStartStep: 2,
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
            category: "Force & Motion",
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
            let shape: String = "cylinder"
            let restitution: Float = 0.1
            """,
            challenges: [Challenge(id: "perfect_bounce", description: "100% Bounciness", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "shield.slash.fill", title: "Incoming projectiles detected. Shield systems offline...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Place a Shield Generator.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Shield")),
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
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - ★ CATEGORY 3: ENGINEERING (Levels 11–15)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // MARK: - Level 11: Orbital Outpost
        Lesson(
            id: 11,
            title: "Orbital Outpost",
            category: "Engineering",
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
            let gravity: Float = 0.0
            """,
            challenges: [Challenge(id: "modular_build", description: "Build Station", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "building.2.fill", title: "Outpost blueprint loaded. Ready for construction.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hammer.fill", title: "Construct the central cylinder core.", instruction: "", hint: "Shape: cylinder", showCodeEditor: true, goal: .buildOutpost(requiredParts: 1)),
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
        
        // MARK: - Level 12: Red Dwarf
        Lesson(
            id: 12,
            title: "Red Dwarf",
            category: "Engineering",
            instruction: "Create a compact red star.",
            conceptExplanation: """
            **Stellar Classification**
            
            Not all stars are yellow G-type.
            Red Dwarfs are smaller and cooler, but far more common.
            
            Task:
            - 🔴 Color: **.red**
            - 📏 Radius: **0.2** (Compact)
            - ⭐ Create a red star
            """,
            codeSnippet: """
            let radius: Float = 0.1
            let starColor: Color = .gray
            """,
            challenges: [Challenge(id: "red_dwarf", description: "Ignite Red Dwarf", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "star.fill", title: "Scanning for low-mass stellar candidates...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Tap to spawn a protostellar core.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Red Star")),
                LessonStep(icon: "terminal.fill", title: "Set color to .red and radius to 0.2 to form a Red Dwarf.", instruction: "", hint: "color: .red, radius: 0.2", showCodeEditor: true, goal: .modifyProperty(target: "Red Star", requiredColor: "red", minRadius: 0.15)),
                LessonStep(icon: "checkmark.circle.fill", title: "Red Dwarf ignited. It will burn for trillions of years.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 13: Twin Worlds
        Lesson(
            id: 13,
            title: "Twin Worlds",
            category: "Engineering",
            instruction: "Position a second planet in the system.",
            conceptExplanation: """
            **Multi-Planet Systems**
            
            Most star systems have multiple planets.
            Let's add Mars to our solar system.
            
            Task:
            - 🔴 Create Mars
            - 📍 Position: **x: 1.2** (Farther out)
            - 🎨 Color: **.red** (Iron oxide surface)
            """,
            codeSnippet: """
            let positionX: Float = 0.0
            let positionY: Float = 0.0
            let positionZ: Float = 0.0
            """,
            challenges: [Challenge(id: "twin_worlds", description: "Deploy Mars", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "globe.americas", title: "Earth needs a neighbor. Scanning habitable zones...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Tap to spawn a planetary mass for Mars.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Mars")),
                LessonStep(icon: "terminal.fill", title: "Mars is too close. Set positionX to 1.2 to establish proper spacing.", instruction: "", hint: "positionX: 1.2", showCodeEditor: true, goal: .modifyPosition(target: "Mars", targetX: 1.2)),
                LessonStep(icon: "checkmark.circle.fill", title: "Binary planetary system established. Stable configuration.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Earth", shape: "sphere", color: "blue", radius: 0.08, positionX: 0.8, orbitRadius: 0.8, orbitSpeed: 2.0, parentName: nil, count: nil)
            ]
        ),
        
        // MARK: - Level 14: Space Dock
        Lesson(
            id: 14,
            title: "Space Dock",
            category: "Engineering",
            instruction: "Build a large orbital construction facility.",
            conceptExplanation: """
            **Modular Construction**
            
            Space stations are built module by module.
            Build a larger facility with 4 parts.
            
            Task:
            - 🏗️ Place **4** structural modules
            - 🔧 Mix shapes: cylinders + boxes
            - ⚖️ Zero gravity environment
            """,
            codeSnippet: """
            let shape: String = "box"
            let scaleX: Float = 2.0
            let scaleY: Float = 1.0
            let scaleZ: Float = 1.0
            let gravity: Float = 0.0
            """,
            challenges: [Challenge(id: "space_dock", description: "Build Space Dock", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "wrench.and.screwdriver", title: "Space Dock construction authorized. Zero-G environment.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hammer.fill", title: "Place the first hull segment.", instruction: "", hint: "Tap to place", showCodeEditor: true, goal: .buildOutpost(requiredParts: 1)),
                LessonStep(icon: "square.grid.2x2", title: "Continue building. Place 3 more structural modules.", instruction: "", hint: "Place 3 more", showCodeEditor: true, goal: .buildOutpost(requiredParts: 4)),
                LessonStep(icon: "checkmark.circle.fill", title: "Space Dock operational. Ready for fleet deployment.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: []
        ),
        
        // MARK: - Level 15: Debris Sweep
        Lesson(
            id: 15,
            title: "Debris Sweep",
            category: "Engineering",
            instruction: "Launch a cleanup probe to sweep debris.",
            conceptExplanation: """
            **Orbital Cleanup**
            
            Space junk is a real problem.
            Launch a high-speed probe to push debris out of orbit.
            
            Task:
            - 🚀 Apply **Force Z: -20.0** (Maximum thrust)
            - 🧹 Clear the orbital lane
            """,
            codeSnippet: """
            let shape: String = "cone"
            let forceY: Float = 0.0
            let forceZ: Float = 0.0
            """,
            challenges: [Challenge(id: "debris_sweep", description: "Launch Sweep Probe", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "tornado", title: "Orbital debris critical. Initiating cleanup protocol.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Deploy the Sweep Probe.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Sweep Probe")),
                LessonStep(icon: "flame.fill", title: "Maximum thrust needed. Set forceZ to -20.0.", instruction: "", hint: "forceZ: -20.0", showCodeEditor: true, goal: .applyForce(target: "Sweep Probe", requiredZ: -20.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Debris cleared. Orbital lane is safe.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: [
                PreRequisiteEntity(name: "Sun", shape: "sphere", color: "yellow", radius: 0.5, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil),
                PreRequisiteEntity(name: "Asteroid", shape: "belt", color: "gray", radius: 0.04, positionX: 0, orbitRadius: 1.5, orbitSpeed: 1.0, parentName: "Sun", count: 10)
            ]
        ),
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - ★ CATEGORY 4: ADVANCED SYSTEMS (Levels 16–20)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // MARK: - Level 16: Featherfall
        Lesson(
            id: 16,
            title: "Featherfall",
            category: "Advanced Systems",
            instruction: "Simulating lunar gravity.",
            conceptExplanation: """
            **Variable Gravity**
            
            The Moon's gravity is only **1.6 m/s²**.
            Objects fall 6x slower than on Earth.
            
            Task:
            - 🌑 Set gravity to **1.6** (Moon gravity)
            - 🪶 Watch objects fall in slow motion
            """,
            codeSnippet: """
            let shape: String = "sphere"
            let gravity: Float = 9.8
            """,
            challenges: [Challenge(id: "lunar_gravity", description: "Moon Gravity", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "moon.fill", title: "Entering lunar orbit. Adjusting gravity field...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Drop a test mass.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Lunar Probe")),
                LessonStep(icon: "arrow.down", title: "Too fast! We're on the Moon. Set gravity to 1.6.", instruction: "", hint: "gravity: 1.6", showCodeEditor: true, goal: .modifyGravity(targetGravity: 1.6)),
                LessonStep(icon: "checkmark.circle.fill", title: "Lunar gravity active. Every step covers 6x the distance.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 17: Ring World
        Lesson(
            id: 17,
            title: "Ring World",
            category: "Advanced Systems",
            instruction: "Create a planetary ring system.",
            conceptExplanation: """
            **Planetary Rings**
            
            Saturn has thousands of ice and rock particles in orbit.
            Create a dense ring around a planet.
            
            Task:
            - 💍 Generate **30** particles
            - 📏 Orbit Radius: **0.3** (Close ring)
            - 🪐 Ring around the planet
            """,
            codeSnippet: """
            let count: Int = 0
            let orbitRadius: Float = 0.3
            """,
            challenges: [Challenge(id: "ring_world", description: "Create Ring System", targetCount: 30, xpReward: 350)],
            steps: [
                LessonStep(icon: "circle.dashed", title: "Scanning for ring material... Ice and rock detected.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "loop", title: "Set count to 30 to generate the planetary ring.", instruction: "", hint: "count: 30", showCodeEditor: true, goal: .generateBelt(target: "Saturn", minCount: 30, targetRadius: 0.3)),
                LessonStep(icon: "checkmark.circle.fill", title: "Magnificent! A complete ring system, just like Saturn.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: [
                PreRequisiteEntity(name: "Saturn", shape: "sphere", color: "orange", radius: 0.3, positionX: 0, orbitRadius: nil, orbitSpeed: nil, parentName: nil, count: nil)
            ]
        ),
        
        // MARK: - Level 18: Neutron Core
        Lesson(
            id: 18,
            title: "Neutron Core",
            category: "Advanced Systems",
            instruction: "Create an ultra-dense stellar remnant.",
            conceptExplanation: """
            **Neutron Star Physics**
            
            When a massive star collapses, its core becomes incredibly dense.
            A teaspoon of neutron star weighs as much as a mountain.
            
            Task:
            - ⚛️ Set **Mass** to **100.0** (Ultra-dense)
            - 📏 Keep it small (default radius)
            """,
            codeSnippet: """
            let mass: Float = 1.0
            """,
            challenges: [Challenge(id: "neutron_core", description: "Create Neutron Core", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "atom", title: "Stellar collapse detected. Core density increasing...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Spawn the collapsing stellar core.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Neutron")),
                LessonStep(icon: "burst.fill", title: "More mass needed! Set mass to 100.0 for neutron density.", instruction: "", hint: "mass: 100.0", showCodeEditor: true, goal: .modifyPhysics(target: "Neutron", targetFriction: nil, targetMass: 100.0, targetRestitution: nil)),
                LessonStep(icon: "checkmark.circle.fill", title: "Neutron core stable. Gravitational lensing detected.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 19: Cosmic Pinball
        Lesson(
            id: 19,
            title: "Cosmic Pinball",
            category: "Advanced Systems",
            instruction: "Perfect bounce with zero friction.",
            conceptExplanation: """
            **Elastic Collisions**
            
            Combine maximum bounce with zero friction.
            Objects will ricochet forever in this environment.
            
            Task:
            - 🏐 **Restitution: 1.0** (Perfect bounce)
            - 🧊 **Friction: 0.0** (No drag)
            """,
            codeSnippet: """
            let shape: String = "sphere"
            let friction: Float = 0.5
            let restitution: Float = 0.5
            """,
            challenges: [Challenge(id: "cosmic_pinball", description: "Cosmic Pinball", targetCount: 1, xpReward: 350)],
            steps: [
                LessonStep(icon: "circle.grid.cross", title: "Initializing pinball physics chamber...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hand.tap.fill", title: "Place a bouncing probe.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Pinball")),
                LessonStep(icon: "sparkles", title: "Set restitution to 1.0 AND friction to 0.0. Eternal bounce!", instruction: "", hint: "restitution: 1.0, friction: 0.0", showCodeEditor: true, goal: .modifyPhysics(target: "Pinball", targetFriction: 0.0, targetMass: nil, targetRestitution: 1.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Perpetual motion achieved. Physics is beautiful.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 20: Fleet Deploy
        Lesson(
            id: 20,
            title: "Fleet Deploy",
            category: "Advanced Systems",
            instruction: "Build a fleet of 5 ships.",
            conceptExplanation: """
            **Mass Production**
            
            One ship won't defend the system.
            Construct a fleet of 5 vessels for the defense grid.
            
            Task:
            - 🚀 Build **5** ship modules
            - 🔧 Use any shape combination
            - ⚖️ Zero gravity for orbital assembly
            """,
            codeSnippet: """
            let shape: String = "cone"
            let scaleX: Float = 1.0
            let scaleY: Float = 2.0
            let scaleZ: Float = 1.0
            let gravity: Float = 0.0
            """,
            challenges: [Challenge(id: "fleet_deploy", description: "Deploy Fleet", targetCount: 5, xpReward: 400)],
            steps: [
                LessonStep(icon: "shield.fill", title: "Fleet authorization granted. Begin construction.", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "hammer.fill", title: "Build the first ship. Tap to place hull segments.", instruction: "", hint: "Tap to build", showCodeEditor: true, goal: .buildOutpost(requiredParts: 2)),
                LessonStep(icon: "square.grid.3x3", title: "More ships needed! Deploy 3 more vessels.", instruction: "", hint: "Place 3 more", showCodeEditor: true, goal: .buildOutpost(requiredParts: 5)),
                LessonStep(icon: "checkmark.circle.fill", title: "Fleet operational! The system is defended.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1,
            prerequisites: []
        ),
        
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - ★ CATEGORY 5: MASTERY (Levels 21–22)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        
        // MARK: - Level 21: Architect's Trial
        Lesson(
            id: 21,
            title: "Architect's Trial",
            category: "Mastery",
            instruction: "Prove your mastery. Build a complete mini solar system.",
            conceptExplanation: """
            **Final Examination**
            
            Combine everything you've learned.
            Build a star, place a planet, set its orbit, and add a moon.
            
            Task:
            - ☀️ Create a Star
            - 🌍 Place a Planet
            - 🔄 Set planet orbit
            - 🌑 Add a Moon
            """,
            codeSnippet: """
            let radius: Float = 0.1
            let starColor: Color = .gray
            """,
            challenges: [Challenge(id: "architects_trial", description: "Complete Trial", targetCount: 1, xpReward: 500)],
            steps: [
                LessonStep(icon: "crown.fill", title: "The Architect's Trial begins. Show us what you've learned.", instruction: "", hint: "Tap to begin", goal: .none),
                LessonStep(icon: "sun.max.fill", title: "Step 1: Create a star. Tap to spawn.", instruction: "", hint: "Tap the screen", goal: .placeEntity(name: "Trial Star")),
                LessonStep(icon: "terminal.fill", title: "Ignite the star. Set color to .yellow, radius to 0.3.", instruction: "", hint: "color: .yellow, radius: 0.3", showCodeEditor: true, goal: .modifyProperty(target: "Trial Star", requiredColor: "yellow", minRadius: 0.25)),
                LessonStep(icon: "globe.americas.fill", title: "Step 2: Spawn a planet.", instruction: "", hint: "Tap to place", goal: .placeEntity(name: "Trial Planet")),
                LessonStep(icon: "checkmark.circle.fill", title: "You are a true Cosmic Architect. The universe bows to you.", instruction: "", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2,
            prerequisites: []
        ),
        
        // MARK: - Level 22: Universe Sandbox
        Lesson(
            id: 22,
            title: "Universe Sandbox",
            category: "Mastery",
            instruction: "Total freedom.",
            conceptExplanation: """
            **Creative Mode**
            
            All systems unlocked.
            Build solar systems, outposts, or smash entire fleets.
            
            You have mastered the ARchitect Engine.
            """,
            codeSnippet: """
            // ♾️ SANDBOX MODE — Edit & Tap to Spawn!
            // Shapes: sphere, box, cylinder, cone, plane
            let shape: String = "sphere"
            let color: Color = .cyan
            let radius: Float = 0.1
            
            // Box dimensions (when shape = "box")
            let width: Float = 0.2
            let height: Float = 0.2
            let depth: Float = 0.2
            
            // Scale (stretch your objects)
            let scaleX: Float = 1.0
            let scaleY: Float = 1.0
            let scaleZ: Float = 1.0
            
            // Physics
            let mass: Float = 1.0
            let friction: Float = 0.5
            let restitution: Float = 0.5
            let gravity: Float = 9.8
            
            // Forces & Orbits
            let forceZ: Float = 0.0
            let orbitRadius: Float = 0.0
            let orbitSpeed: Float = 0.0
            """,
            challenges: [Challenge(id: "sandbox_master", description: "Creative Mode Unlocked", targetCount: 1, xpReward: 500)],
            steps: [
                LessonStep(icon: "sparkles", title: "Unlocking Creative Mode...", instruction: "", hint: "Tap next", goal: .none),
                LessonStep(icon: "infinity", title: "Sandbox Mode Active. Build your own universe.", instruction: "Total freedom. No limits.", hint: "Tap screen to place", showCodeEditor: true, goal: .sandbox)
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
    
    func lessonsForCategory(_ category: String) -> [Lesson] {
        return lessons.filter { $0.category == category }
    }
}
