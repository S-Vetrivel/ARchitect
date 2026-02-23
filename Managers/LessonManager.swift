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

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let conceptExplanation: String
    let codeSnippet: String
    let challenges: [Challenge]
    let steps: [LessonStep]
    let codeEditorStartStep: Int
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
            - 📏 Radius: **0.25** (Large)
            - 🎨 Color: **.yellow** (G-Type)
            """,
            codeSnippet: """
            // MISSION 01: IGNITION
            // Goal: Create the Sun
            
            // 1. Define Geometry (Shape)
            // radius: 0.25 (25cm)
            let mesh = MeshResource.generateSphere(radius: 0.25)
            
            // 2. Define Material (Surface)
            // color: .yellow (Sun)
            let material = SimpleMaterial(color: .yellow, isMetallic: false)
            """,
            challenges: [Challenge(id: "ignition", description: "Ignite the Sun", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "sun.max.fill", title: "Stellar Nursery", instruction: "Space is cold and empty.\nWe need a heat source.\nTap 'Run Code' to ignite.", hint: "Tap the Play button", goal: .none),
                LessonStep(icon: "arrow.up.left.and.arrow.down.right", title: "Optimization", instruction: "The star is stable.\nBut it can be brighter.\nChange `.yellow` to `.orange`.", hint: "Edit code to .orange", showCodeEditor: true, goal: .placeCelestialBody(mass: 1000.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "System Online", instruction: "Fusion sustained.\nHelium production nominal.\nReady for planets.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1
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
            // MISSION 02: LIFE SUPPORT
            // Goal: Place Earth in the Goldilocks Zone
            
            // Position relative to Sun (Center)
            // x: 0.0 -> Inside the Sun (Bad)
            // x: 0.8 -> Habitable Zone (Good)
            
            entity.position = SIMD3<Float>(0.8, 0.0, 0.0)
            """,
            challenges: [Challenge(id: "goldilocks", description: "Place Earth", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "globe.americas.fill", title: "Orbital Injection", instruction: "The Sun is too hot.\nWe need distance.\nSet x position to 0.8.", hint: "x: 0.8", goal: .placeCelestialBody(mass: 1.0)),
                LessonStep(icon: "thermometer.sun.fill", title: "Temperature Check", instruction: "Scanner indicates water is liquid.\nGreat work.\nTry `x: 1.2` for a colder orbit.", hint: "Increase distance", showCodeEditor: true, goal: .none),
                LessonStep(icon: "checkmark.circle.fill", title: "Orbit Established", instruction: "Biosphere stable.\nAwaiting evolution.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1
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
            // MISSION 03: MOMENTUM
            // Goal: Orbit the Sun
            
            // radius: Match your position (0.8)
            // speed: Speed of revolution
            
            orbitRadius: 0.8
            orbitSpeed: 0.5
            """,
            challenges: [Challenge(id: "orbit_stabilized", description: "Stabilize Orbit", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "arrow.2.circlepath", title: "Gravity Well", instruction: "Planet is stationary.\nInitiate orbital engines.\nSet radius to 0.8.", hint: "orbitRadius: 0.8", goal: .achieveOrbit(targetSpeed: 0.5)),
                LessonStep(icon: "hare.fill", title: "Velocity Adjust", instruction: "Orbit is stable.\nLet's speed up time.\nChange `orbitSpeed` to `2.0`.", hint: "Double the speed", showCodeEditor: true, goal: .achieveOrbit(targetSpeed: 2.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "System Clock", instruction: "Years are passing in seconds.\nTime is relative.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1
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
            // MISSION 04: SATELLITE
            // Goal: Create the Moon
            
            // This orbits the EARTH, not the Sun.
            // So radius should be small (0.2).
            
            orbitRadius: 0.2
            orbitSpeed: 3.0
            color: .gray
            radius: 0.05
            """,
            challenges: [Challenge(id: "lunar_orbit", description: "Deploy Moon", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "moon.fill", title: "Natural Satellite", instruction: "Earth is lonely.\nLet's give it a friend.\nInject a moon into orbit.", hint: "Run the code", goal: .achieveOrbit(targetSpeed: 3.0)),
                LessonStep(icon: "arrow.triangle.2.circlepath", title: "Tidal Lock", instruction: "Watch the path.\nA spiral within a circle.\nTry `orbitRadius: 0.3`.", hint: "Expand the orbit", showCodeEditor: true, goal: .any),
                LessonStep(icon: "checkmark.circle.fill", title: "Tides Active", instruction: "Tidal forces stabilized.\nSurfing is now possible.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1
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
            - 🪨 Create **10** Asteroids
            - 🎨 Randomize colors (Gray/Brown)
            - 📏 Randomize sizes
            """,
            codeSnippet: """
            // MISSION 05: DEBRIS FIELD
            // Goal: Create Asteroid Belt
            
            count: 10
            orbitRadius: 1.5
            color: .gray
            """,
            challenges: [Challenge(id: "asteroid_belt", description: "Create Belt", targetCount: 10, xpReward: 300)],
            steps: [
                LessonStep(icon: "sparkles", title: "Kessler Syndrome", instruction: "We need a barrier between inner and outer planets.\nGenerate the belt.", hint: "Run the code", goal: .placeCelestialBody(mass: 0.5)),
                LessonStep(icon: "plus.circle.fill", title: "Density Critical", instruction: "10 rocks is sparse.\nIncrease `count` to `20`.\nWatch the CPU burn!", hint: "count: 20", showCodeEditor: true, goal: .none),
                LessonStep(icon: "checkmark.circle.fill", title: "Sector Secured", instruction: "Navigation is hazardous.\nPerfect defense system.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 1
        ),
        
        // MARK: - Level 6: Gravity Engine
        Lesson(
            id: 6,
            title: "Gravity Engine",
            instruction: "Master the force of gravity itself.",
            conceptExplanation: """
            **Gravity Engine**
            
            Every world has gravity pulling objects down.
            Earth = **9.8** m/s². Moon = **1.6** m/s².
            
            Task:
            - 🌍 Default gravity is **9.8** (objects fall normally)
            - 🌙 Set to **1.6** for Moon gravity (slow fall)
            - 🛸 Set to **0.0** for Anti-Gravity (objects float!)
            """,
            codeSnippet: """
            // MISSION 06: GRAVITY ENGINE
            // Change gravity to control how objects fall!
            // gravity: 9.8  (Earth — normal)
            // gravity: 1.6  (Moon — slow fall)
            // gravity: 0.0  (Space — float!)
            
            gravity: 9.8
            color: .cyan
            shape: sphere
            """,
            challenges: [Challenge(id: "gravity_control", description: "Master Gravity", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "arrow.down.to.line.alt", title: "Gravity Lab", instruction: "Welcome to the Gravity Engine.\nObjects fall at 9.8 m/s² by default.\nTap to begin.", hint: "Change gravity in code", goal: .none),
                LessonStep(icon: "cube.fill", title: "Step 1: Normal Drop", instruction: "Place an object above the floor.\nIt falls at Earth gravity (9.8).\nWatch it drop!", hint: "Tap the floor", goal: .placeCelestialBody(mass: 1.0)),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Zero-G", instruction: "Open Code.\nChange `gravity: 9.8` to\n`gravity: 0.0`\nThis disables gravity!", hint: "0.0 = float in space", showCodeEditor: true, goal: .none),
                LessonStep(icon: "cloud.fill", title: "Step 3: Anti-Gravity!", instruction: "Place another object.\nIt floats in mid-air! 🛸\nNo gravity = no falling.", hint: "Look! It floats!", showCodeEditor: true, goal: .any),
                LessonStep(icon: "moon.fill", title: "Step 4: Moon Walk", instruction: "Try `gravity: 1.6`\nPlace an object.\nIt falls slowly — Moon gravity!", hint: "1.6 = lunar gravity", showCodeEditor: true, goal: .any),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Gravity engine mastered!\n9.8=Earth, 1.6=Moon, 0=Space.\nYou control the universe!", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Level 7: Thruster Engage
        Lesson(
            id: 7,
            title: "Thruster Engage",
            instruction: "Launch a probe into deep space.",
            conceptExplanation: """
            **Launch Detection**
            
            We need to send a probe to the Outer Rim.
            Gravity is not enough. We need **Thrust**.
            
            Task:
            - 💨 Apply **Force Z: -10.0**
            - 🚀 Launch **Forward** (Negative Z is forward in AR)
            """,
            codeSnippet: """
            // MISSION 07: DEEP SPACE
            // Goal: Launch Forward
            // forceZ: 0.0 (Drifting)
            // forceZ: -10.0 (Warp Speed)
            
            let force = SIMD3<Float>(0.0, 1.0, 0.0) // THIS PUSHES UP. FIX IT.
            entity.addForce(force, relativeTo: nil)
            """,
            challenges: [Challenge(id: "thruster_launch", description: "Launch Deep Space Probe", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "flame.fill", title: "Launch Pad", instruction: "Probe ready for departure.\nEngine check required.\nTap to begin.", hint: "Negative Z = Forward", goal: .none),
                LessonStep(icon: "arrow.up", title: "Step 1: Test Fire", instruction: "Place probe.\nNotice it hops UP (Y-axis).\nWe need it to go FORWARD.", hint: "Tap floor", goal: .any),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Vector Alignment", instruction: "Open Code.\nChange `forceY: 1.0` to `0.0`\nSet `forceZ` to `-10.0`", hint: "-10.0 is forward", showCodeEditor: true, goal: .none),
                LessonStep(icon: "rocket.fill", title: "Step 3: Engage", instruction: "Place probe.\nWatch it launch into the void!\nWave goodbye! 👋", hint: "There it goes...", showCodeEditor: true, goal: .achieveOrbit(targetSpeed: 10.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Probe trajectory confirmed.\nETA to Outer Rim: 400 years.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Level 8: Void Glider
        Lesson(
            id: 8,
            title: "Void Glider",
            instruction: "Simulate a frictionless vacuum.",
            conceptExplanation: """
            **Vacuum Physics**
            
            In space, there is no air resistance or friction.
            An object in motion stays in motion.
            
            Task:
            - 🧊 Set **Friction** to **0.0**
            - ⛸️ Push object and watch it **glide forever**
            """,
            codeSnippet: """
            // MISSION 08: VACUUM DRIFT
            // Goal: Perpetual Motion
            // friction: 1.0 (High Drag)
            // friction: 0.0 (No Drag)
            
            var material = PhysicsMaterialResource.generate(
                friction: 1.0, // TOO HIGH
                restitution: 0.0
            )
            """,
            challenges: [Challenge(id: "frictionless_glide", description: "Create Frictionless Object", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "wind.snow", title: "Drag Detected", instruction: "Space hull is slowing down.\nSomething is dragging on it.\nTap to fix.", hint: "Friction slows things down", goal: .none),
                LessonStep(icon: "stop.fill", title: "Step 1: Friction Test", instruction: "Place the hull. Push it.\nIt stops quickly due to friction.", hint: "Tap floor", goal: .any),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Remove Drag", instruction: "Open Code.\nSet `friction` to `0.0`\nThis simulates a vacuum.", hint: "0.0 = ice mode", showCodeEditor: true, goal: .none),
                LessonStep(icon: "arrow.right", title: "Step 3: Eternal Glide", instruction: "Place hull. Tap to push.\nIt will slide forever until it hits a wall.", hint: "Weeeee!", showCodeEditor: true, goal: .any),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Friction systems offline.\nHull efficiency at 100%.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Level 9: Asteroid Impact
        Lesson(
            id: 9,
            title: "Asteroid Impact",
            instruction: "Use mass to obliterate obstacles.",
            conceptExplanation: """
            **Kinetic Impact**
            
            A debris field is blocking our path.
            We need a heavy projectile to clear it.
            
            Task:
            - 🧱 Set **Mass** to **50.0**
            - 💥 **Smash** through lighter objects
            """,
            codeSnippet: """
            // MISSION 09: DEBRIS CLEARANCE
            // Goal: Smash Obstacles
            // Mass 1.0 = Weak Impact
            // Mass 50.0 = Heavy Impact
            
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: 1.0), // TOO LIGHT
                material: .default,
                mode: .dynamic
            )
            """,
            challenges: [Challenge(id: "asteroid_smash", description: "Clear Debris Field", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "exclamationmark.triangle.fill", title: "Path Blocked", instruction: "Satellite debris ahead.\nStandard lasers ineffective.\nKinetic ram required.", hint: "Heavy objects push light ones", goal: .none),
                LessonStep(icon: "circle.dotted", title: "Step 1: Weak Impact", instruction: "Drop a standard rock (Mass 1.0).\nIt bounces off the debris.", hint: "Tap floor", goal: .placeCelestialBody(mass: 1.0)),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Increase Density", instruction: "Open Code.\nSet `mass` to `50.0`\nMake it a dense iron asteroid.", hint: "50x heavier!", showCodeEditor: true, goal: .none),
                LessonStep(icon: "burst.fill", title: "Step 3: Impact!", instruction: "Drop the asteroid.\nWatch it crush the debris!\nPath cleared.", hint: "Boom!", showCodeEditor: true, goal: .placeCelestialBody(mass: 50.0)),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Debris field neutralized.\nRoute confirmed.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2
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
            // MISSION 10: SHIELD UP
            // Goal: Perfect Reflection
            // Restitution 0.0 = Absorb (Damage)
            // Restitution 1.0 = Reflect (Safe)
            
            var material = PhysicsMaterialResource.generate(
                friction: 0.5,
                restitution: 0.1 // SHIELDS DOWN!
            )
            """,
            challenges: [Challenge(id: "shield_reflect", description: "Reflect Meteor", targetCount: 1, xpReward: 300)],
            steps: [
                LessonStep(icon: "shield.slash.fill", title: "Shields Critical", instruction: "Incoming meteors detected.\nShields are at 10% capacity.\nImpact imminent.", hint: "Restitution is reflection", goal: .none),
                LessonStep(icon: "arrow.down", title: "Step 1: Hull Breach", instruction: "Place the shield.\nDrop a test meteor.\nIt hits hard and stops. Damage taken.", hint: "Tap floor", goal: .any),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Max Power", instruction: "Open Code.\nSet `restitution` to `1.0`\nMaximum bounce capability.", hint: "1.0 = 100% reflection", showCodeEditor: true, goal: .none),
                LessonStep(icon: "shield.fill", title: "Step 3: Reflect!", instruction: "Place shield.\nDrop meteor.\nIt bounces off harmlessly!", hint: "Boing!", showCodeEditor: true, goal: .deflectAsteroid),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Shields holding at 100%.\nSector secured.\nWelcome to Starfleet.", hint: "", goal: .any)
            ],
            codeEditorStartStep: 2
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
