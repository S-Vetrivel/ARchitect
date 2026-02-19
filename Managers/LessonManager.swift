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
        
        // MARK: - Cosmic Architect: Building the Universe (1-5)
        
        // Level 1: The Void (Hello World)
        Lesson(
            id: 1,
            title: "The Void",
            instruction: "Initialize a basic sphere in empty space.",
            conceptExplanation: """
            **Creation Engine Online**
            
            Welcome to the Void, Architect.
            Your first task is to manifest a basic celestial body.
            
            You'll learn:
            - 🪐 How to initialize a **Sphere**
            - 📍 How to place it in 3D space
            """,
            codeSnippet: """
            // MISSION 01: GENESIS
            // Goal: Create a Planet (Sphere)
            // Warning: Start small.
            // radius: 0.1 (10cm)
            // color: .blue
            
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            """,
            challenges: [Challenge(id: "genesis", description: "Create a Planet", targetCount: 1, xpReward: 100)],
            steps: [], // Level 1 uses TutorialOverlayView
            codeEditorStartStep: 6
        ),
        
        // Level 2: Planetary Scale (Scale 10.0)
        Lesson(
            id: 2,
            title: "Planetary Scale",
            instruction: "Scale a planet to Gas Giant proportions.",
            conceptExplanation: """
            **Gas Giant Protocol**
            
            The current planet is too small to sustain an atmosphere.
            We need a Gas Giant like Jupiter.
            
            Task:
            - 📏 Increase **Scale** to 10.0
            - 🧱 Mass will increase exponentially
            """,
            codeSnippet: """
            // MISSION 02: GIGANTISM
            // Goal: Scale to Gas Giant size
            // Current Scale: 1.0 (Earth-sized)
            // Target Scale: 10.0 (Jupiter-sized)
            
            entity.scale = SIMD3<Float>(1.0, 1.0, 1.0) // CHANGE THIS!
            """,
            challenges: [Challenge(id: "gas_giant", description: "Create a Gas Giant", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "circle.circle.fill", title: "Scale Mismatch", instruction: "This planet is too small.\nWe need a Gas Giant.\nTap to assess.", hint: "Scale 1.0 is too small"),
                LessonStep(icon: "arrow.up.left.and.arrow.down.right", title: "Step 1: Place Prototype", instruction: "Place a standard planet.\nObserve its insufficient size.", hint: "Tap floor to place", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Access Mainframe", instruction: "Open the code editor.\nChange `1.0` to `10.0`\non ALL axes (x, y, z).", hint: "scale = SIMD3(10, 10, 10)", showCodeEditor: true),
                LessonStep(icon: "globe.asia.australia.fill", title: "Step 3: Manifest Giant", instruction: "Place the new planet.\nWitness the scale difference!", hint: "It will be huge!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Planetary scale achieved.\nGravity well stabilizing.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 3: Atmospheric Colors (Mars Red)
        Lesson(
            id: 3,
            title: "Red Planet",
            instruction: "Terraform the planet to Mars-like conditions.",
            conceptExplanation: """
            **Atmospheric Re-entry**
            
            We are approaching Sector 4 (Mars).
            The current planet is stuck in Ocean Mode (Blue).
            
            Task:
            - 🎨 Change atmospheric color to **.red**
            - 🌡️ Iron Oxide detection expected
            """,
            codeSnippet: """
            // MISSION 03: RED DUST
            // Goal: Terraform to Mars
            // Current Atmosphere: .blue
            // Target Atmosphere: .red
            
            var material = SimpleMaterial(color: .blue, isMetallic: false) // FIX THIS
            """,
            challenges: [Challenge(id: "mars_terraform", description: "Create Mars", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "paintpalette.fill", title: "Wrong Sector", instruction: "This planet matches Earth data.\nWe need Mars data.\nTap to Initialize.", hint: "Color mismatch detected"),
                LessonStep(icon: "circle.fill", title: "Step 1: Scan Planet", instruction: "Place the current planet.\nConfirm it is Blue.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Recalibrate", instruction: "Open Inspector.\nChange `.blue` to `.red`\nto match Martian soil.", hint: "color: .red", showCodeEditor: true),
                LessonStep(icon: "globe.americas.fill", title: "Step 3: Terraform", instruction: "Place the new planet.\nWelcome to Mars, Architect.", hint: "Red Planet achieved", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Atmosphere stabilized.\nIron oxide levels nominal.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 4: Rocky vs Gas (Metallic)
        Lesson(
            id: 4,
            title: "Asteroid Mining",
            instruction: "Identify metallic asteroids vs matte moons.",
            conceptExplanation: """
            **Material Scanner**
            
            We need to distinguish between valuable **Metals**
            and common **Rock**.
            
            Task:
            - ✨ Create a **Shiny Asteroid** (Metallic: True)
            - 🌑 Create a **Matte Moon** (Metallic: False)
            """,
            codeSnippet: """
            // MISSION 04: ORE SCAN
            // Goal: Create Metallic Asteroid
            // isMetallic: false (Rock/Moon)
            // isMetallic: true (Metal/Treasure)
            
            var material = SimpleMaterial(
                color: .gray,
                isMetallic: false // CHANGE TO TRUE
            )
            """,
            challenges: [Challenge(id: "metallic_asteroid", description: "Create Metallic Object", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "sparkles", title: "Ore Detection", instruction: "Scanner picking up silicate (Rock).\nWe need Metal.\nTap to calibrate.", hint: "Metallic surfaces reflect light"),
                LessonStep(icon: "circle.fill", title: "Step 1: Analyze Rock", instruction: "Place a standard moon.\nNotice the matte, dull finish.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Refine Ore", instruction: "Open Code.\nSet `isMetallic: true`\nTurn rock into iron.", hint: "true = shiny", showCodeEditor: true),
                LessonStep(icon: "star.fill", title: "Step 3: Forge", instruction: "Place the new asteroid.\nIt should shine in the starlight!", hint: "Look for the shine", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Rich metal deposits found.\nMining drones deployed.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 5: Planetary Rings (Shapes)
        Lesson(
            id: 5,
            title: "Saturn's Rings",
            instruction: "Construct orbital rings using flattened cylinders.",
            conceptExplanation: """
            **Orbital Architecture**
            
            Saturn is missing its signature rings.
            We need to fabricate a debris field.
            
            Task:
            - 🔵 Use **Cylinder** shape
            - 📉 Flatten it: **ScaleY: 0.1**
            - 🌌 Expand it: **ScaleX/Z: 5.0**
            """,
            codeSnippet: """
            // MISSION 05: RING BUILDER
            // Goal: Create Saturn's Rings
            // Shape: Cylinder
            // ScaleY: 0.1 (Flat)
            
            let mesh = MeshResource.generateCylinder(height: 0.2, radius: 0.5)
            entity.scale = SIMD3<Float>(1.0, 1.0, 1.0) // FLATTEN THIS!
            """,
            challenges: [Challenge(id: "saturn_ring", description: "Create Orbital Ring", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "smallcircle.filled.circle", title: "Ring System Offline", instruction: "Planet is naked.\nInitiating Ring Construction Protocol.\nTap to begin.", hint: "Rings are just flat cylinders"),
                LessonStep(icon: "cylinder.fill", title: "Step 1: Raw Material", instruction: "Place a standard cylinder.\nIt looks like a can, not a ring.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Flatten", instruction: "Open Code.\nSet `scaleY` to `0.1` (Thin)\nSet `scaleX/Z` to `3.0` (Wide)", hint: "Y is height, X/Z is width", showCodeEditor: true),
                LessonStep(icon: "record.circle.fill", title: "Step 3: Deploy Ring", instruction: "Place the flattened cylinder.\nA perfect orbital disc!", hint: "Saturn would be proud", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Ring system stable.\nScenic rating increased to 100%.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // MARK: - Starfleet Academy: Physics & Space (6-10)
        
        // Level 6: Anti-Gravity (Mass 0)
        Lesson(
            id: 6,
            title: "Anti-Gravity",
            instruction: "Defy gravity by nullifying mass.",
            conceptExplanation: """
            **Gravity Nullifier**
            
            Standard objects plummet to the surface.
            Satellites must stay in orbit.
            
            Task:
            - ⚖️ Set **Mass** to **0.0**
            - 🛰️ Object becomes **Kinematic** (Unaffected by forces)
            """,
            codeSnippet: """
            // MISSION 06: ORBITAL LOCK
            // Goal: Float in Space
            // Mass 1.0 = Falls (Dynamic)
            // Mass 0.0 = Floats (Kinematic)
            
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: 1.0), // CHANGE TO 0.0
                material: .default,
                mode: .dynamic
            )
            """,
            challenges: [Challenge(id: "anti_gravity", description: "Create Floating Satellite", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "arrow.down.to.line.alt", title: "Gravity Alert", instruction: "Satellites are crashing.\nGravity is too strong.\nTap to fix.", hint: "Mass 0 disables gravity"),
                LessonStep(icon: "cube.fill", title: "Step 1: Observe Crash", instruction: "Place a satellite (Box).\nIt falls immediately.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Nullify Mass", instruction: "Open Code.\nSet `mass: 1.0` to `mass: 0.0`\nThis creates a 'Static' body.", hint: "0.0 = no gravity effect", showCodeEditor: true),
                LessonStep(icon: "cloud.fill", title: "Step 3: Orbit Achieved", instruction: "Place the new satellite.\nIt floats perfectly in the air!", hint: "Look at it float!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Anti-gravity generators online.\nOrbit established.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 7: Thruster Engage (Force Z)
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
                LessonStep(icon: "flame.fill", title: "Launch Pad", instruction: "Probe ready for departure.\nEngine check required.\nTap to begin.", hint: "Negative Z = Forward"),
                LessonStep(icon: "arrow.up", title: "Step 1: Test Fire", instruction: "Place probe.\nNotice it hops UP (Y-axis).\nWe need it to go FORWARD.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Vector Alignment", instruction: "Open Code.\nChange `forceY: 1.0` to `0.0`\nSet `forceZ` to `-10.0`", hint: "-10.0 is forward", showCodeEditor: true),
                LessonStep(icon: "rocket.fill", title: "Step 3: Engage", instruction: "Place probe.\nWatch it launch into the void!\nWave goodbye! 👋", hint: "There it goes...", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Probe trajectory confirmed.\nETA to Outer Rim: 400 years.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 8: Frictionless Space (Friction 0)
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
                LessonStep(icon: "wind.snow", title: "Drag Detected", instruction: "Space hull is slowing down.\nSomething is dragging on it.\nTap to fix.", hint: "Friction slows things down"),
                LessonStep(icon: "stop.fill", title: "Step 1: Friction Test", instruction: "Place the hull. Push it.\nIt stops quickly due to friction.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Remove Drag", instruction: "Open Code.\nSet `friction` to `0.0`\nThis simulates a vacuum.", hint: "0.0 = ice mode", showCodeEditor: true),
                LessonStep(icon: "arrow.right", title: "Step 3: Eternal Glide", instruction: "Place hull. Tap to push.\nIt will slide forever until it hits a wall.", hint: "Weeeee!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Friction systems offline.\nHull efficiency at 100%.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 9: Asteroid Collision (Mass 50)
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
                LessonStep(icon: "exclamationmark.triangle.fill", title: "Path Blocked", instruction: "Satellite debris ahead.\nStandard lasers ineffective.\nKinetic ram required.", hint: "Heavy objects push light ones"),
                LessonStep(icon: "circle.dotted", title: "Step 1: Weak Impact", instruction: "Drop a standard rock (Mass 1.0).\nIt bounces off the debris.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Increase Density", instruction: "Open Code.\nSet `mass` to `50.0`\nMake it a dense iron asteroid.", hint: "50x heavier!", showCodeEditor: true),
                LessonStep(icon: "burst.fill", title: "Step 3: Impact!", instruction: "Drop the asteroid.\nWatch it crush the debris!\nPath cleared.", hint: "Boom!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Debris field neutralized.\nRoute confirmed.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        // Level 10: Deflector Shields (Restitution 1.0)
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
                LessonStep(icon: "shield.slash.fill", title: "Shields Critical", instruction: "Incoming meteors detected.\nShields are at 10% capacity.\nImpact imminent.", hint: "Restitution is reflection"),
                LessonStep(icon: "arrow.down", title: "Step 1: Hull Breach", instruction: "Place the shield.\nDrop a test meteor.\nIt hits hard and stops. Damage taken.", hint: "Tap floor", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Max Power", instruction: "Open Code.\nSet `restitution` to `1.0`\nMaximum bounce capability.", hint: "1.0 = 100% reflection", showCodeEditor: true),
                LessonStep(icon: "shield.fill", title: "Step 3: Reflect!", instruction: "Place shield.\nDrop meteor.\nIt bounces off harmlessly!", hint: "Boing!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Mission Accomplished", instruction: "Shields holding at 100%.\nSector secured.\nWelcome to Starfleet.", hint: "")
            ],
            codeEditorStartStep: 2
        ),
        
        Lesson(id: 11, title: "Friction Stop", instruction: "Control how objects slide and stop.",
            conceptExplanation: "**Slip & Grip**\n\nFriction determines how quickly\nobjects slow down and stop.\n\nYou'll learn:\n- 🧊 **Low friction** = slippery ice\n- 🏖️ **High friction** = sticky sand\n- 🎮 How friction affects gameplay",
            codeSnippet: "// Friction Control\n// friction: 0.5  (0=ice, 1=sandpaper)\n// mass: 1.0\n// restitution: 0.3\n// forceX: 3.0\n// color: .orange\n// shape: box",
            challenges: [Challenge(id: "friction_test", description: "Test different friction levels", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "figure.walk", title: "Friction Lab!", instruction: "Friction controls how objects\nslide across surfaces.\nTap to begin!", hint: "0 = no friction, 1 = max grip"),
                LessonStep(icon: "cube.fill", title: "Step 1: Place a Box", instruction: "Place a box on the floor.\nIt will slide when pushed!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Friction Code", instruction: "`friction: 0.5` is medium grip.\nWe'll push it with a sideways force.\nTap to continue.", hint: "forceX pushes sideways", showCodeEditor: true),
                LessonStep(icon: "arrow.right", title: "Step 3: Push It!", instruction: "Tap your box to push it sideways!\nSee how far it slides\nwith medium friction.", hint: "Tap your placed box", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "snowflake", title: "Step 4: Ice Mode!", instruction: "Change `friction: 0.5` to\n`friction: 0.0`\nPlace & push — it never stops!", hint: "Zero friction = pure ice", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Friction controls sliding!\n0 = ice, 1 = sandpaper.\nPerfect for game mechanics.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 12, title: "Super Bounce", instruction: "Push restitution to extremes!",
            conceptExplanation: "**Bounce Laboratory**\n\nYou learned basic bounce in Level 3.\nNow let's go extreme!\n\nYou'll learn:\n- 🚀 **Super bounce** with restitution > 1.0\n- 🪨 **Dead weight** with restitution = 0\n- 🎾 Combining mass + bounce",
            codeSnippet: "// Super Bounce\n// restitution: 1.5  (try 0.0 to 2.0!)\n// mass: 0.3\n// color: .magenta\n// shape: sphere",
            challenges: [Challenge(id: "super_bounce", description: "Create a super bouncy ball", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "arrow.up.arrow.down", title: "Super Bounce!", instruction: "Time to break physics!\nRestitution > 1.0 means the ball\ngains energy each bounce!", hint: "Extra bouncy!"),
                LessonStep(icon: "circle.fill", title: "Step 1: Normal Bounce", instruction: "Place a ball with restitution 1.5.\nWatch it bounce HIGHER\nthan where it started!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Check Code", instruction: "`restitution: 1.5` means\n150% energy returned!\nThe ball gains energy!", hint: "Values > 1 = energy gain", showCodeEditor: true),
                LessonStep(icon: "flame.fill", title: "Step 3: Maximum Bounce!", instruction: "Change restitution to `2.0`\nPlace another ball.\nWatch it go crazy! 🚀", hint: "2.0 = double energy return", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "minus.circle", title: "Step 4: Dead Stop", instruction: "Now try `restitution: 0.0`\nwith `mass: 10.0`\nA heavy dead weight!", hint: "0 bounce + heavy = thud", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Restitution > 1 breaks reality!\nGreat for power-ups in games.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 13, title: "Domino Effect", instruction: "Create chain reactions with physics!",
            conceptExplanation: "**Chain Reaction! 🎯**\n\nPlace objects in a line and topple\nthe first one to start a chain!\n\nYou'll learn:\n- 🧱 Precise **object placement**\n- 💫 **Chain reactions** with physics\n- 📐 Spacing affects the chain",
            codeSnippet: "// Domino Setup\n// count: 5  (dominoes in a row)\n// mass: 0.3\n// restitution: 0.1\n// color: .white\n// shape: box",
            challenges: [Challenge(id: "domino_chain", description: "Create a domino chain", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "rectangle.stack.fill", title: "Domino Effect!", instruction: "Place dominoes in a line\nand topple the first one!\nTap to begin!", hint: "Chain reactions are fun!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Place Dominoes", instruction: "Tap the floor to place\na line of 5 dominoes.\nThey're tall and thin!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Domino Code", instruction: "`count: 5` dominoes in a row.\nLow restitution so they\ndon't bounce away.", hint: "Low bounce = clean topple", showCodeEditor: true),
                LessonStep(icon: "hand.point.right.fill", title: "Step 3: Topple!", instruction: "Shoot a ball to knock\nthe first domino!\nWatch the chain reaction! 🎳", hint: "Aim at the first one", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "plus.circle.fill", title: "Step 4: Longer Chain!", instruction: "Change `count: 5` to `count: 10`\nBuild a bigger chain\nand topple it!", hint: "More dominoes = more fun", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Chain reactions are powerful!\nDominoes demonstrate how\nsmall forces create big effects.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 14, title: "Ramp Rush", instruction: "Launch objects at angles!",
            conceptExplanation: "**Angled Launch 🏔️**\n\nForces don't just push up or forward.\nAngled forces create arcs!\n\nYou'll learn:\n- 📐 **Angled forces** (X + Y combined)\n- 🏹 **Projectile arcs**\n- 🎯 Predicting where objects land",
            codeSnippet: "// Ramp Launch\n// forceX: 4.0  (sideways push)\n// forceY: 6.0  (upward push)\n// forceZ: 0.0\n// mass: 0.5\n// color: .green\n// shape: sphere",
            challenges: [Challenge(id: "ramp_launch", description: "Launch at an angle", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "arrow.up.right", title: "Ramp Rush!", instruction: "Combine X and Y forces\nto launch objects at angles!\nTap to begin!", hint: "Angle = X + Y forces"),
                LessonStep(icon: "circle.fill", title: "Step 1: Place Ball", instruction: "Tap the floor to place\nyour launch ball!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Force Angles", instruction: "forceX: 4.0 pushes sideways\nforceY: 6.0 pushes UP\nCombined = diagonal arc!", hint: "X + Y = angle", showCodeEditor: true),
                LessonStep(icon: "arrow.up.forward", title: "Step 3: Launch!", instruction: "Tap your ball to launch it!\nWatch the beautiful arc! 🏹", hint: "Tap the placed ball", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "pencil.circle.fill", title: "Step 4: Steeper Arc!", instruction: "Try `forceY: 12.0` and\n`forceX: 2.0`\nfor a steep, high arc!", hint: "More Y = higher arc", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Angled forces create arcs!\nThis is how projectile\nmotion works in games.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 15, title: "Multi-Drop", instruction: "Spawn multiple physics objects at once!",
            conceptExplanation: "**Rain of Objects! 🌧️**\n\nWhat happens when you drop\nmany objects at the same time?\n\nYou'll learn:\n- 🎱 **Multiple objects** with physics\n- 💥 **Object-to-object** collisions\n- 🌀 Chaos theory in AR!",
            codeSnippet: "// Multi-Drop\n// count: 5  (objects to drop)\n// mass: 0.5\n// restitution: 0.6\n// color: .cyan\n// shape: sphere",
            challenges: [Challenge(id: "multi_drop", description: "Drop multiple objects", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "cloud.heavyrain.fill", title: "Multi-Drop!", instruction: "Drop many objects at once\nand watch them collide!\nTap to begin!", hint: "Controlled chaos!"),
                LessonStep(icon: "circle.grid.3x3.fill", title: "Step 1: Drop 5 Balls", instruction: "Tap the floor to spawn\n5 bouncy balls from above!\nWatch them collide! 💥", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Multi Code", instruction: "`count: 5` objects spawned.\nEach has its own physics!\nThey all collide with each other.", hint: "More objects = more chaos", showCodeEditor: true),
                LessonStep(icon: "plus.circle.fill", title: "Step 3: More Objects!", instruction: "Change `count: 5` to `count: 10`\nDrop again for more chaos!", hint: "10 bouncing balls!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Heavy Rain!", instruction: "Try `count: 15` with\n`restitution: 1.0`\nMaximum bouncy chaos! 🌪️", hint: "Careful — lots of physics!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Multiple physics objects\ncreate emergent behavior!\nChaos can be fun! 🎉", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 16, title: "Force Field", instruction: "Push objects in every direction!",
            conceptExplanation: "**Directional Forces ⚡**\n\nForces work in all 3 dimensions.\nMaster X, Y, and Z!\n\nYou'll learn:\n- ⬅️➡️ **X-axis** = left/right\n- ⬆️⬇️ **Y-axis** = up/down\n- ↗️↙️ **Z-axis** = forward/back",
            codeSnippet: "// Force Field\n// forceX: 5.0  (left/right)\n// forceY: 0.0  (up/down)\n// forceZ: 0.0  (forward/back)\n// mass: 1.0\n// color: .yellow\n// shape: box",
            challenges: [Challenge(id: "force_field", description: "Apply force in all axes", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "arrow.left.and.right", title: "Force Field!", instruction: "Master forces in all\nthree dimensions!\nTap to begin!", hint: "X, Y, Z control direction"),
                LessonStep(icon: "cube.fill", title: "Step 1: Place Object", instruction: "Place a box on the floor.\nWe'll push it sideways!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: X-Force", instruction: "`forceX: 5.0` pushes RIGHT.\nNegative values push LEFT.\nY and Z are zero.", hint: "X = horizontal", showCodeEditor: true),
                LessonStep(icon: "arrow.right.circle.fill", title: "Step 3: Push Right!", instruction: "Tap your box to push it\nsideways with X-force!", hint: "Tap the placed box", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.up.circle.fill", title: "Step 4: Launch Up!", instruction: "Change to:\n`forceX: 0, forceY: 10, forceZ: 0`\nLaunch it straight up! 🚀", hint: "Y = vertical force", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "You control all 3 force axes!\nCombine them for any\ndirection you want.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 17, title: "Air Hockey", instruction: "Low friction + impulse = air hockey!",
            conceptExplanation: "**Air Hockey! 🏒**\n\nCombine low friction with sideways\nforces to simulate air hockey!\n\nYou'll learn:\n- 🧊 **Zero friction** sliding\n- 🏒 **Sideways impulse** mechanics\n- 🎮 Building a mini-game concept",
            codeSnippet: "// Air Hockey\n// friction: 0.0\n// forceX: 6.0\n// forceY: 0.0\n// forceZ: -4.0\n// mass: 0.5\n// restitution: 0.9\n// color: .blue\n// shape: sphere",
            challenges: [Challenge(id: "air_hockey", description: "Slide a puck with zero friction", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "hockey.puck.fill", title: "Air Hockey! 🏒", instruction: "Zero friction + impulse\n= perfect sliding puck!\nTap to begin!", hint: "Like real air hockey!"),
                LessonStep(icon: "circle.fill", title: "Step 1: Place Puck", instruction: "Place your air hockey puck.\nIt's a flat sphere on\nfrictionless ground!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Hockey Code", instruction: "`friction: 0.0` = no resistance\n`restitution: 0.9` = bouncy walls\nPerfect for hockey!", hint: "Zero friction is key", showCodeEditor: true),
                LessonStep(icon: "arrow.right", title: "Step 3: Slide It!", instruction: "Tap the puck to slide it!\nIt glides with zero friction\nand bounces off everything!", hint: "Tap the puck", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Power Shot!", instruction: "Change `forceX: 6.0` to\n`forceX: 15.0`\nPower shot across the floor!", hint: "Faster = more exciting", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "You built air hockey physics!\nLow friction + bounce =\nperfect sliding gameplay.", hint: "")
            ], codeEditorStartStep: 2),
        
        // MARK: - Chapter 4: Shooting Range (18-25)
        
        Lesson(id: 18, title: "Quick Draw", instruction: "Master the basics of shooting!",
            conceptExplanation: "**Ready, Aim, Fire! 🔫**\n\nYou learned targeting in Level 8.\nNow become a sharpshooter!\n\nYou'll learn:\n- 🎯 Quick **target placement**\n- 💨 Fast **projectile shooting**\n- 🏆 Accuracy matters!",
            codeSnippet: "// Quick Draw\n// speed: 8.0\n// radius: 0.03\n// mass: 0.5\n// color: .red\n// shape: sphere",
            challenges: [Challenge(id: "quick_draw", description: "Hit a target quickly", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "scope", title: "Quick Draw!", instruction: "Speed and accuracy!\nPlace a target and hit it fast!\nTap to begin!", hint: "Be quick!"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Set Target", instruction: "Tap the floor to place\nyour target. Quick!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Projectile Code", instruction: "`speed: 8.0` = projectile speed\n`radius: 0.03` = small bullet\nReady to shoot!", hint: "Higher speed = faster", showCodeEditor: true),
                LessonStep(icon: "target", title: "Step 3: Fire!", instruction: "Tap in the air to shoot!\nAim at your target!\nHit it! 🎯", hint: "Aim carefully", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Rapid Fire!", instruction: "Tap multiple times quickly\nto fire a burst of shots!\nSpray and pray! 💨", hint: "Tap tap tap!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Quick draw mastered!\nSpeed + aim = deadly combo.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 19, title: "Long Range", instruction: "Hit distant targets with precision!",
            conceptExplanation: "**Sniper Mode 🔭**\n\nDistant targets need faster bullets.\nSpeed compensates for gravity drop.\n\nYou'll learn:\n- 🔭 **Long-range** shooting\n- 📉 **Gravity drop** over distance\n- ⚡ Speed vs accuracy tradeoff",
            codeSnippet: "// Long Range\n// speed: 15.0  (fast for distance)\n// radius: 0.02\n// mass: 0.3\n// color: .yellow",
            challenges: [Challenge(id: "long_range", description: "Hit a distant target", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "binoculars.fill", title: "Long Range!", instruction: "Place target far away\nand snipe it!\nTap to begin!", hint: "Distance needs speed"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Far Target", instruction: "Walk forward, then place\na target far from you.\nUse the joystick to move!", hint: "Place it far away!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Speed Up", instruction: "`speed: 15.0` for fast bullets.\nSmall `radius: 0.02` for precision.\nNeed speed to reach far targets.", hint: "Faster = farther range", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Snipe!", instruction: "Walk back to your start.\nAim at the distant target\nand take the shot! 🎯", hint: "Aim slightly above", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Max Speed!", instruction: "Try `speed: 25.0`\nfor laser-fast bullets!\nAlmost instant hit!", hint: "Speed = range", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Long range mastered!\nFaster bullets = longer range\nbut harder to aim.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 20, title: "Power Shot", instruction: "Heavy projectiles = maximum impact!",
            conceptExplanation: "**Heavy Hitter 💪**\n\nHeavier bullets carry more momentum.\nThey push targets harder!\n\nYou'll learn:\n- 🏋️ **Heavy projectiles** hit harder\n- 💥 Momentum = mass × speed\n- 🎳 Knock objects flying!",
            codeSnippet: "// Power Shot\n// speed: 10.0\n// radius: 0.06\n// mass: 5.0  (heavy!)\n// color: .orange",
            challenges: [Challenge(id: "power_shot", description: "Fire a heavy projectile", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "bolt.fill", title: "Power Shot!", instruction: "Bigger, heavier bullets\nfor maximum impact!\nTap to begin!", hint: "Mass = power"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Place Target", instruction: "Place a target on the floor.\nWe'll hit it with a cannonball!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Heavy Ammo", instruction: "`mass: 5.0` = heavy cannonball\n`radius: 0.06` = big bullet!\nThis will pack a punch!", hint: "Heavy + fast = powerful", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: FIRE!", instruction: "Shoot the cannonball!\nWatch the heavy impact! 💥", hint: "Aim at the target", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Mega Shot!", instruction: "Try `mass: 20.0` and\n`radius: 0.1`\nAbsolute destruction! 💣", hint: "Maximum power!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Power shots dominate!\nHeavy projectiles destroy\neverything in their path.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 21, title: "Bullet Storm", instruction: "Rapid fire multiple projectiles!",
            conceptExplanation: "**Suppressive Fire! 🌪️**\n\nSometimes one shot isn't enough.\nFire many projectiles rapidly!\n\nYou'll learn:\n- 🔫 **Rapid fire** techniques\n- 🎯 **Spread** patterns\n- 💨 Volume over precision",
            codeSnippet: "// Bullet Storm\n// speed: 12.0\n// radius: 0.02\n// mass: 0.2  (light & fast)\n// color: .green",
            challenges: [Challenge(id: "bullet_storm", description: "Fire 5 rapid shots", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "cloud.bolt.fill", title: "Bullet Storm!", instruction: "Fire many shots rapidly!\nOverwhelm with volume!\nTap to begin!", hint: "Quantity over quality"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Multiple Targets", instruction: "Place several targets\naround the floor!\nTap in different spots.", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Light Ammo", instruction: "Light bullets `mass: 0.2`\nare fast to fire!\n`speed: 12.0` for range.", hint: "Light = rapid fire", showCodeEditor: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 3: Open Fire!", instruction: "Tap rapidly in the air!\nFire a storm of bullets!\nTry to hit all targets! 🌪️", hint: "Tap fast!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Machine Gun!", instruction: "Change `speed: 12.0` to\n`speed: 20.0`\nUltra-fast bullet storm!", hint: "Maximum rate of fire!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Bullet storm complete!\nRapid fire is great for\naction-packed AR games.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 22, title: "Sniper Elite", instruction: "Tiny targets, maximum precision!",
            conceptExplanation: "**Pin-Point Accuracy 🎯**\n\nSmall targets require steady aim\nand precise projectiles.\n\nYou'll learn:\n- 🔬 **Tiny bullets** for accuracy\n- 🎯 **Small targets** = hard mode\n- 🧘 Patience + precision",
            codeSnippet: "// Sniper Elite\n// speed: 18.0\n// radius: 0.015  (tiny bullet)\n// mass: 0.1\n// color: .white",
            challenges: [Challenge(id: "sniper_elite", description: "Hit a tiny target", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "scope", title: "Sniper Elite!", instruction: "Precision is everything.\nTiny target, tiny bullet.\nTap to begin!", hint: "Steady aim wins"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Tiny Target", instruction: "Place a target. It's small!\nYou'll need eagle eyes\nto hit it.", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Precision Setup", instruction: "`radius: 0.015` = needle bullet\n`speed: 18.0` = fast & accurate\nOne shot, one kill!", hint: "Small + fast = precise", showCodeEditor: true),
                LessonStep(icon: "target", title: "Step 3: Take the Shot!", instruction: "Aim carefully...\nTake your time...\nFire! 🎯", hint: "Patience, then shoot", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Speed Snipe!", instruction: "Try `speed: 30.0`\nInstant hit — no gravity drop!\nPure precision! ⚡", hint: "Max speed = straight line", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Sniper elite unlocked!\nPrecision > power\nin skilled hands.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 23, title: "Arc Shot", instruction: "Master curved trajectories!",
            conceptExplanation: "**Curve It! 🌈**\n\nSlower projectiles arc more\ndue to gravity. Use this!\n\nYou'll learn:\n- 🌈 **Arcing** trajectories\n- 📐 **Lob shots** over obstacles\n- ⬆️ Aim high to hit far",
            codeSnippet: "// Arc Shot\n// speed: 4.0  (slow = more arc)\n// radius: 0.05\n// mass: 1.0\n// color: .purple",
            challenges: [Challenge(id: "arc_shot", description: "Lob a projectile in an arc", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "arrow.up.right.circle.fill", title: "Arc Shot!", instruction: "Slow bullets arc beautifully!\nLob shots over obstacles!\nTap to begin!", hint: "Slow speed = big arc"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Place Target", instruction: "Place a target ahead.\nWe'll lob a ball at it\nin a beautiful arc!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Slow Speed", instruction: "`speed: 4.0` = very slow bullet.\nGravity pulls it down fast!\nAim HIGH to compensate.", hint: "Aim above target", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Lob It!", instruction: "Aim ABOVE the target.\nThe ball will arc down!\nBeautiful parabola! 🌈", hint: "Aim high!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.down.right.circle.fill", title: "Step 4: Mortar Shot!", instruction: "Try `speed: 3.0`\nAim almost straight up!\nThe ball rains down! ☄️", hint: "Nearly vertical = mortar", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Arc shots mastered!\nSlow speed + high aim =\nbeautiful curved fire.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 24, title: "Speed Demon", instruction: "Maximum velocity projectiles!",
            conceptExplanation: "**Warp Speed! ⚡**\n\nPush projectile speed to the max!\nFaster = flatter trajectory.\n\nYou'll learn:\n- ⚡ **Maximum speed** bullets\n- ➖ Flat trajectories at high speed\n- 🎮 Speed vs control tradeoff",
            codeSnippet: "// Speed Demon\n// speed: 30.0  (maximum!)\n// radius: 0.02\n// mass: 0.3\n// color: .yellow",
            challenges: [Challenge(id: "speed_demon", description: "Fire at maximum speed", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "hare.fill", title: "Speed Demon!", instruction: "Fastest bullets possible!\nAlmost hitscan at this speed!\nTap to begin!", hint: "Speed = FAST"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Place Target", instruction: "Place a target anywhere.\nAt this speed, distance\ndoesn't matter!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Max Speed", instruction: "`speed: 30.0` is insane!\nThe bullet barely drops.\nAlmost a laser beam! ⚡", hint: "Flat trajectory", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Instant Hit!", instruction: "Shoot! The bullet travels\nalmost instantly!\nNo need to lead the target.", hint: "Point and shoot", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Compare Slow", instruction: "Now try `speed: 2.0`\nSee the HUGE difference?\nSlow = arc, fast = line!", hint: "Speed controls arc", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Speed demon achieved!\nHigher speed = flatter arc.\nPros use high speed for accuracy.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 25, title: "Trick Shot", instruction: "Complex target arrangements!",
            conceptExplanation: "**Show-Off Mode! 🏆**\n\nPlace multiple targets and\nhit them all with skill!\n\nYou'll learn:\n- 🎯 **Multiple targets** setup\n- 🔄 Quick **target switching**\n- 🏆 Combining all skills",
            codeSnippet: "// Trick Shot\n// speed: 12.0\n// radius: 0.03\n// mass: 0.5\n// color: .red",
            challenges: [Challenge(id: "trick_shot", description: "Hit multiple targets", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "star.fill", title: "Trick Shot!", instruction: "Place targets everywhere\nand hit them all!\nTap to begin!", hint: "Show off your skills!"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Setup Targets", instruction: "Place 3+ targets around\nthe room. Spread them out!\nTap floor in different spots.", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Balanced Setup", instruction: "Medium speed `12.0` is\nperfect for trick shots.\nNot too fast, not too slow!", hint: "Balance is key", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Hit Them All!", instruction: "Shoot all the targets!\nSwitch between them!\nClean sweep! 🧹", hint: "Aim at each target", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.circle.fill", title: "Step 4: Speed Run!", instruction: "Try again but FASTER!\nHow quickly can you\nhit all targets?", hint: "Speed + accuracy!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Trick shot master! 🏆\nYou've mastered the\nshooting range!", hint: "")
            ], codeEditorStartStep: 2),
        
        // MARK: - Chapter 5: Architecture (26-33)
        
        Lesson(id: 26, title: "Wall Builder", instruction: "Build horizontal walls!",
            conceptExplanation: "**Brick by Brick 🧱**\n\nWalls are the foundation of\nevery building.\n\nYou'll learn:\n- 🧱 Building **horizontal lines**\n- 📏 **Scale** for flat bricks\n- 🏗️ Foundation construction",
            codeSnippet: "// Wall Building\n// count: 5  (bricks in a wall)\n// scaleX: 2.0  (wide bricks)\n// scaleY: 0.5  (flat bricks)\n// scaleZ: 1.0\n// color: .brown\n// shape: box",
            challenges: [Challenge(id: "wall_build", description: "Build a wall", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "rectangle.split.3x3.fill", title: "Wall Builder!", instruction: "Build walls from bricks!\nWide, flat blocks in a row.\nTap to begin!", hint: "Walls = flat bricks"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Lay Bricks", instruction: "Tap the floor to place\na row of bricks.\nAutomatic wall building!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Brick Code", instruction: "`scaleX: 2.0` = wide bricks\n`scaleY: 0.5` = flat bricks\n`count: 5` bricks per row.", hint: "Scale shapes bricks", showCodeEditor: true),
                LessonStep(icon: "plus.circle.fill", title: "Step 3: More Bricks!", instruction: "Change `count: 5` to `count: 8`\nBuild a longer wall!\nTap to build.", hint: "Tap the floor!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.up.circle.fill", title: "Step 4: Higher Wall!", instruction: "Build again nearby!\nStack walls to make\na higher structure! 🏗️", hint: "Place next to existing wall", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Walls built!\nHorizontal stacking is\nthe basis of all architecture.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 27, title: "Pyramid", instruction: "Build a decreasing-width pyramid!",
            conceptExplanation: "**Ancient Wonder 🔺**\n\nPyramids use decreasing layers.\nEach level is narrower than below.\n\nYou'll learn:\n- 🔺 **Pyramid** construction\n- 📐 **Decreasing width** per layer\n- 🏛️ Ancient architecture",
            codeSnippet: "// Pyramid\n// count: 6  (blocks in base)\n// scaleX: 1.0\n// scaleY: 0.5\n// scaleZ: 1.0\n// color: .yellow\n// shape: box",
            challenges: [Challenge(id: "pyramid", description: "Build a pyramid", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "triangle.fill", title: "Pyramid Builder!", instruction: "Build like the pharaohs!\nDecreasing layers upward.\nTap to begin!", hint: "Wide base, narrow top"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Base Layer", instruction: "Tap the floor to build\nthe pyramid base.\n6 blocks wide!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Structure", instruction: "`count: 6` base blocks.\nEach layer above has fewer.\nClassic pyramid shape!", hint: "Base is widest", showCodeEditor: true),
                LessonStep(icon: "arrow.up", title: "Step 3: Build Up!", instruction: "Change `count: 4`\nTap nearby to add\na narrower layer!", hint: "Tap above base", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "triangle.fill", title: "Step 4: Top It!", instruction: "Now `count: 2`\nAdd the crown of\nyour pyramid! 👑", hint: "Almost there!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Pyramid complete! 🔺\nYou built an ancient wonder\nright in your room!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 28, title: "Twin Towers", instruction: "Build two matching towers!",
            conceptExplanation: "**Double Trouble! 🏙️**\n\nSymmetry is key in architecture.\nBuild matching towers!\n\nYou'll learn:\n- 🏙️ **Symmetrical** building\n- 📏 Consistent **sizing**\n- 🏗️ Multi-structure scenes",
            codeSnippet: "// Twin Towers\n// count: 6  (blocks per tower)\n// scaleX: 0.8\n// scaleY: 1.0\n// scaleZ: 0.8\n// color: .gray\n// shape: box",
            challenges: [Challenge(id: "twin_towers", description: "Build two matching towers", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "building.2.fill", title: "Twin Towers!", instruction: "Build two identical towers!\nSymmetry is beautiful.\nTap to begin!", hint: "Match them perfectly"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Tower One", instruction: "Tap the floor to build\nyour first tower.\n6 blocks tall!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Tower Code", instruction: "`count: 6` blocks high.\nKeep settings identical\nfor both towers!", hint: "Same code for both", showCodeEditor: true),
                LessonStep(icon: "building.fill", title: "Step 3: Tower Two!", instruction: "Tap the floor nearby\nto build the matching\ntwin tower!", hint: "Place next to first", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.up.circle.fill", title: "Step 4: Taller!", instruction: "Change `count: 10`\nBuild two TALL twins!\nSkyline challenge! 🏙️", hint: "10 blocks high!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Twin towers built! 🏙️\nMatching structures create\nbeautiful symmetry.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 29, title: "The Fortress", instruction: "Build thick, strong walls!",
            conceptExplanation: "**Castle Walls! 🏰**\n\nFortresses need thick walls.\nScale Z for depth!\n\nYou'll learn:\n- 🏰 **Thick walls** with scaleZ\n- 🛡️ **Defensive** structures\n- 🧱 Multi-layer building",
            codeSnippet: "// Fortress Wall\n// count: 6\n// scaleX: 1.5\n// scaleY: 1.5  (tall)\n// scaleZ: 2.0  (thick!)\n// color: .gray\n// shape: box",
            challenges: [Challenge(id: "fortress", description: "Build a fortress wall", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "shield.fill", title: "The Fortress!", instruction: "Build thick castle walls\nthat nothing can break!\nTap to begin!", hint: "Thick walls = strong"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Thick Wall", instruction: "Tap the floor to build\na thick fortress wall.\nNotice the depth!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Thickness", instruction: "`scaleZ: 2.0` = double depth!\n`scaleY: 1.5` = extra tall.\nThis is a real fortress wall!", hint: "Z = depth/thickness", showCodeEditor: true),
                LessonStep(icon: "shield.fill", title: "Step 3: Second Wall!", instruction: "Place another wall at\nan angle to create\na corner! 🏰", hint: "Build at 90°", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Test It!", instruction: "Shoot projectiles at\nyour fortress walls!\nAre they strong? 💪", hint: "Try to knock them down!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Fortress built! 🏰\nThick walls withstand\neven heavy impacts.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 30, title: "Sky Scraper", instruction: "Build the tallest tower possible!",
            conceptExplanation: "**Reach the Sky! 🌆**\n\nHow tall can you build before\nphysics takes over?\n\nYou'll learn:\n- 🏢 **Maximum height** building\n- ⚖️ **Balance** and stability\n- 😱 Gravity's revenge!",
            codeSnippet: "// Sky Scraper\n// count: 15  (tower height!)\n// scaleX: 0.6\n// scaleY: 0.6\n// scaleZ: 0.6\n// color: .blue\n// shape: box",
            challenges: [Challenge(id: "skyscraper", description: "Build a 15-block tower", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "building.fill", title: "Sky Scraper!", instruction: "Build the tallest tower!\nHow high can you go?\nTap to begin!", hint: "Height is the goal!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build Tall!", instruction: "Tap the floor to build\na 15-block skyscraper!\nReach for the sky! 🌤️", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Height Code", instruction: "`count: 15` is impressive!\nSmall blocks `0.6` scale\nfor a slim skyscraper.", hint: "Slim = taller", showCodeEditor: true),
                LessonStep(icon: "arrow.up", title: "Step 3: Even Taller!", instruction: "Try `count: 20`\nBuild a mega tower!\nDoes it stay up? 🤔", hint: "Test the limits!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Topple It!", instruction: "Now shoot your skyscraper!\nWatch the physics chaos\nas it crumbles! 💥", hint: "Shoot the base!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Skyscraper built & toppled!\nTaller towers are harder\nto keep balanced.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 31, title: "Bowling Alley", instruction: "Set up pins and knock them down!",
            conceptExplanation: "**Strike! 🎳**\n\nBuild a bowling alley in AR!\nSetup pins and roll a ball!\n\nYou'll learn:\n- 🎳 **Bowling pin** arrangement\n- 🏐 Rolling balls at targets\n- 💥 Chain collisions",
            codeSnippet: "// Bowling Alley\n// count: 6  (bowling pins)\n// scaleX: 0.4\n// scaleY: 1.5  (tall pins)\n// scaleZ: 0.4\n// speed: 8.0\n// color: .white\n// shape: box",
            challenges: [Challenge(id: "bowling", description: "Knock down all pins", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "figure.bowling", title: "Bowling Alley! 🎳", instruction: "Set up pins and\nroll a strike!\nTap to begin!", hint: "Aim for the middle!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Set Pins", instruction: "Tap the floor to place\nbowling pins in formation.\nReady to bowl!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Pin Setup", instruction: "Tall narrow boxes as pins!\n`scaleY: 1.5` = tall pins\n`count: 6` pin formation.", hint: "Tall + narrow = pins", showCodeEditor: true),
                LessonStep(icon: "sportscourt.fill", title: "Step 3: BOWL!", instruction: "Shoot a ball at the pins!\nAim for a STRIKE! 🎯\nKnock them all down!", hint: "Aim at the center", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Power Bowl!", instruction: "Try `speed: 15.0` for\na power throw!\nMaximum destruction! 💥", hint: "Faster = harder hit", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "STRIKE! 🎳\nBowling uses physics chain\nreactions perfectly!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 32, title: "Staircase", instruction: "Build stepped structures!",
            conceptExplanation: "**Step by Step! 🪜**\n\nStairs are offset stacks.\nEach block shifts sideways!\n\nYou'll learn:\n- 🪜 **Stepped** construction\n- ↗️ **Offset** stacking\n- 🏗️ Complex structures",
            codeSnippet: "// Staircase\n// count: 8  (steps)\n// scaleX: 1.5\n// scaleY: 0.5\n// scaleZ: 1.0\n// color: .mint\n// shape: box",
            challenges: [Challenge(id: "staircase", description: "Build a staircase", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "stairs", title: "Staircase Builder!", instruction: "Build stairs step by step!\nEach block offset upward.\nTap to begin!", hint: "Stairs go up!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build Stairs", instruction: "Tap the floor to create\na staircase structure.\nWatch blocks step up!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Stair Code", instruction: "`count: 8` = 8 steps\nEach one shifts up & over.\nFlat blocks for treads!", hint: "Offset pattern", showCodeEditor: true),
                LessonStep(icon: "plus.circle.fill", title: "Step 3: Longer Stairs!", instruction: "Change `count: 12`\nBuild a grand staircase\nthat reaches higher! 🏛️", hint: "More steps = higher", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "paintbrush.fill", title: "Step 4: Marble Stairs!", instruction: "Change `color: .white`\nand add marble-look stairs!\nFancy architecture! ✨", hint: "White = marble look", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Staircase complete! 🪜\nOffset stacking creates\ncomplex architecture.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 33, title: "Bridge & Topple", instruction: "Build a bridge and destroy it!",
            conceptExplanation: "**Engineering & Chaos! 🌉**\n\nBuild spanning structures,\nthen demolish them!\n\nYou'll learn:\n- 🌉 **Bridge** construction\n- 🏗️ Spans and supports\n- 💥 Satisfying **destruction**!",
            codeSnippet: "// Bridge\n// count: 8  (bridge span)\n// scaleX: 2.0  (wide span)\n// scaleY: 0.3  (thin deck)\n// scaleZ: 1.0\n// speed: 10.0\n// color: .red\n// shape: box",
            challenges: [Challenge(id: "bridge_topple", description: "Build and destroy a bridge", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "road.lanes", title: "Bridge & Topple!", instruction: "Build a bridge, then\nsmash it to pieces!\nTap to begin!", hint: "Build → Destroy 💥"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build Bridge", instruction: "Tap the floor to build\na long bridge structure.\nEngineering marvel!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Bridge Code", instruction: "`scaleX: 2.0` = wide deck\n`scaleY: 0.3` = thin surface\n`count: 8` = long span!", hint: "Wide & thin = bridge", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Attack!", instruction: "Shoot the bridge supports!\nWatch the physics engine\ncollapse the structure! 💥", hint: "Aim at the base!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Heavy Ammo!", instruction: "Change code to add\nheavy projectiles.\nMaximum bridge destruction! 🔥", hint: "Heavy = more damage", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Bridge demolished! 💥\nBuilding + destroying =\nthe ultimate AR fun!", hint: "")
            ], codeEditorStartStep: 2),
        
        // MARK: - Chapter 6: Creative Studio (34-41)
        
        Lesson(id: 34, title: "Rainbow Row", instruction: "Place a rainbow of colored objects!",
            conceptExplanation: "**Color Spectrum! 🌈**\n\nPlace objects in every color\nof the rainbow!\n\nYou'll learn:\n- 🌈 **Color theory** in 3D\n- 🎨 All available **colors**\n- 📏 Organized placement",
            codeSnippet: "// Rainbow\n// color: .red  (.red .orange .yellow .green .cyan .blue .purple)\n// shape: sphere\n// scaleX: 0.8\n// scaleY: 0.8\n// scaleZ: 0.8",
            challenges: [Challenge(id: "rainbow", description: "Place 7 colored objects", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "paintpalette.fill", title: "Rainbow Row! 🌈", instruction: "Create a beautiful rainbow\nof colored objects!\nTap to begin!", hint: "7 colors of the rainbow"),
                LessonStep(icon: "circle.fill", title: "Step 1: Red First!", instruction: "Place a red sphere.\nStart of the rainbow! 🔴", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Color Code", instruction: "Change `color:` value\nfor each sphere.\nROY G BIV order!", hint: ".red, .orange, .yellow...", showCodeEditor: true),
                LessonStep(icon: "paintbrush.fill", title: "Step 3: Add Orange!", instruction: "Change to `color: .orange`\nPlace next to your red sphere.\nKeep going! 🟠", hint: "Place in a line", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "paintpalette.fill", title: "Step 4: Complete It!", instruction: "Continue through:\nyellow, green, cyan, blue, purple!\nFull rainbow! 🌈", hint: "7 colors total!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Beautiful rainbow! 🌈\nColor is a powerful tool\nin AR design.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 35, title: "Giant & Tiny", instruction: "Extreme scale differences!",
            conceptExplanation: "**Small to Enormous! 📏**\n\nScale creates drama!\nTiny details vs massive structures.\n\nYou'll learn:\n- 🔬 **Miniature** objects (0.1 scale)\n- 🏔️ **Giant** objects (5.0 scale)\n- 📐 Scale for perspective",
            codeSnippet: "// Giant & Tiny\n// scaleX: 0.2  (tiny!)\n// scaleY: 0.2\n// scaleZ: 0.2\n// color: .purple\n// shape: box",
            challenges: [Challenge(id: "giant_tiny", description: "Create extreme scales", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "arrow.up.left.and.arrow.down.right", title: "Giant & Tiny!", instruction: "From microscopic to massive!\nExtreme scale differences!\nTap to begin!", hint: "Scale = size power"),
                LessonStep(icon: "circle.fill", title: "Step 1: Tiny Object", instruction: "Place a tiny object!\nScale 0.2 = really small!\nCan you see it? 🔬", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Scale Code", instruction: "`scaleX/Y/Z: 0.2` = 20% size.\nSo tiny! Let's go\nthe other direction...", hint: "0.2 = 1/5 normal size", showCodeEditor: true),
                LessonStep(icon: "arrow.up.circle.fill", title: "Step 3: GIANT!", instruction: "Change all scales to `3.0`\nPlace a GIANT object!\nIt's enormous! 🏔️", hint: "3x normal size!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "bolt.circle.fill", title: "Step 4: Mega Scale!", instruction: "Try `scaleX: 5.0`\n`scaleY: 0.5`\n`scaleZ: 5.0`\nGiant flat platform!", hint: "Mix scales for shapes", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Scale mastery!\nMix tiny and giant objects\nfor dramatic scenes.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 36, title: "Shape Medley", instruction: "Mix all shapes in one scene!",
            conceptExplanation: "**Shape Orchestra! 🎭**\n\nCombine all available shapes\nfor rich, varied scenes.\n\nYou'll learn:\n- 🎭 **Mixing shapes** effectively\n- 🔲 Box, sphere, cylinder, cone\n- 🎨 Shape + color combinations",
            codeSnippet: "// Shape Medley\n// shape: box  (box, sphere, cylinder, cone)\n// color: .red\n// scaleX: 1.0\n// scaleY: 1.0\n// scaleZ: 1.0",
            challenges: [Challenge(id: "shape_medley", description: "Place 4 different shapes", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "square.on.circle", title: "Shape Medley!", instruction: "Every shape in one scene!\nBox, sphere, cylinder, cone!\nTap to begin!", hint: "Mix and match!"),
                LessonStep(icon: "cube.fill", title: "Step 1: Start with Box", instruction: "Place a box first.\nThe classic building block!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Shape Code", instruction: "Change `shape:` to switch\nbetween shapes.\nTry `sphere` next!", hint: "shape: sphere", showCodeEditor: true),
                LessonStep(icon: "circle.fill", title: "Step 3: Add Sphere!", instruction: "Change to `shape: sphere`\nPlace it next to the box.\nRound meets square! ⚪", hint: "Sphere + box", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "triangle.fill", title: "Step 4: All Shapes!", instruction: "Add `cylinder` and `cone`!\nChange shape and place.\nComplete the collection! 🎭", hint: "4 shapes total!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "All shapes placed! 🎭\nMixing shapes creates\nrich, interesting scenes.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 37, title: "Snowman", instruction: "Build a snowman from spheres!",
            conceptExplanation: "**Build a Snowman! ⛄**\n\nStack spheres of decreasing size\nto build a classic snowman!\n\nYou'll learn:\n- ⛄ **Stacking** different sizes\n- 📏 **Scale** for each segment\n- 🎨 White = snow!",
            codeSnippet: "// Snowman\n// shape: sphere\n// color: .white\n// metallic: false\n// scaleX: 1.5  (body)\n// scaleY: 1.5\n// scaleZ: 1.5",
            challenges: [Challenge(id: "snowman", description: "Build a 3-part snowman", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "snowflake", title: "Build a Snowman! ⛄", instruction: "Stack white spheres\nto make a snowman!\nTap to begin!", hint: "Big → medium → small"),
                LessonStep(icon: "circle.fill", title: "Step 1: Body", instruction: "Place a big white sphere.\nThis is the body!\nscaleX/Y/Z: 1.5", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Size Code", instruction: "Scale 1.5 = big snowball.\nWe'll make each part\nsmaller as we go up!", hint: "Decrease scale each time", showCodeEditor: true),
                LessonStep(icon: "circle", title: "Step 3: Middle!", instruction: "Change to `scaleX/Y/Z: 1.0`\nPlace on top of the body.\nMiddle section! ⚪", hint: "Place above body", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "circle.fill", title: "Step 4: Head!", instruction: "Change to `scaleX/Y/Z: 0.6`\nPlace the tiny head on top!\nSnowman complete! ⛄", hint: "Smallest on top!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Snowman built! ⛄\nStacking + scaling =\ncreative 3D art!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 38, title: "Modern Art", instruction: "Create abstract art in AR!",
            conceptExplanation: "**Abstract Expression! 🎨**\n\nNo rules! Place objects randomly\nwith wild colors and scales.\n\nYou'll learn:\n- 🎨 **Abstract** composition\n- 🌀 **Random** placement art\n- ✨ Breaking the rules!",
            codeSnippet: "// Modern Art\n// shape: box\n// color: .red\n// metallic: true\n// scaleX: 2.0\n// scaleY: 0.3\n// scaleZ: 0.5",
            challenges: [Challenge(id: "modern_art", description: "Create abstract art", targetCount: 1, xpReward: 100)],
            steps: [
                LessonStep(icon: "paintbrush.pointed.fill", title: "Modern Art! 🎨", instruction: "Create abstract art!\nNo rules — go wild!\nTap to begin!", hint: "Express yourself!"),
                LessonStep(icon: "cube.fill", title: "Step 1: First Piece", instruction: "Place your first art piece.\nWeird shape, bold color!\nBreak the mold!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Be Wild!", instruction: "Use extreme scales!\n`scaleX: 3.0, scaleY: 0.1`\nCreates a floating plane!", hint: "Wild scales = art", showCodeEditor: true),
                LessonStep(icon: "paintpalette.fill", title: "Step 3: Add Color!", instruction: "Change colors between pieces.\nMetallic + bold colors\n= stunning art! ✨", hint: "Mix metallic & matte", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.fill", title: "Step 4: Gallery!", instruction: "Place 5+ abstract pieces!\nMix shapes, colors, scales.\nYour AR gallery! 🖼️", hint: "More pieces = better!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Art is subjective! 🎨\nYour AR gallery is\nuniquely yours.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 39, title: "AR Zoo", instruction: "Build animal-shaped structures!",
            conceptExplanation: "**Zoo Architect! 🦁**\n\nUse shapes to build simple\nanimal representations!\n\nYou'll learn:\n- 🐕 Building with **primitives**\n- 🎨 Color for **character**\n- 🏗️ Multi-part creatures",
            codeSnippet: "// AR Zoo\n// shape: sphere  (body parts)\n// color: .brown\n// scaleX: 1.0\n// scaleY: 0.5  (squish for body)\n// scaleZ: 1.5  (stretch for body)",
            challenges: [Challenge(id: "ar_zoo", description: "Build a zoo animal", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "pawprint.fill", title: "AR Zoo! 🦁", instruction: "Build animals from shapes!\nSimple but creative!\nTap to begin!", hint: "Shapes = animals"),
                LessonStep(icon: "circle.fill", title: "Step 1: Animal Body", instruction: "Place a squished sphere\nfor the animal body.\nStretch on Z axis!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Body Code", instruction: "`scaleZ: 1.5` stretches\nthe sphere into a body!\nAdd legs as small boxes.", hint: "Stretch = body shape", showCodeEditor: true),
                LessonStep(icon: "cube.fill", title: "Step 3: Add Head!", instruction: "Change to small sphere:\n`scaleX/Y/Z: 0.5`\nPlace at one end! 🐕", hint: "Small sphere = head", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "paintbrush.fill", title: "Step 4: Color It!", instruction: "Try different colors:\n`.brown` = dog, `.orange` = cat\n`.gray` = elephant! 🐘", hint: "Color = species!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Zoo animal built! 🦁\nPrimitive shapes can\nrepresent anything!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 40, title: "Sculpture Park", instruction: "Artistic 3D sculptures!",
            conceptExplanation: "**Art Installation! 🗿**\n\nCreate museum-worthy sculptures\nfrom 3D primitives.\n\nYou'll learn:\n- 🗿 **Artistic** composition\n- ✨ **Metallic** surfaces for art\n- 🎭 Form meets function",
            codeSnippet: "// Sculpture\n// shape: sphere\n// color: .gray\n// metallic: true\n// scaleX: 1.0\n// scaleY: 2.0  (tall)\n// scaleZ: 0.5  (thin)",
            challenges: [Challenge(id: "sculpture", description: "Create a sculpture", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "cube.transparent.fill", title: "Sculpture Park! 🗿", instruction: "Create museum-quality\nAR sculptures!\nTap to begin!", hint: "Art in 3D space"),
                LessonStep(icon: "circle.fill", title: "Step 1: Base Form", instruction: "Place a stretched metallic\nsphere as your base.\nTall and elegant!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Sculpture Code", instruction: "`scaleY: 2.0` = tall\n`scaleZ: 0.5` = thin\n`metallic: true` = museum quality!", hint: "Stretched = elegant", showCodeEditor: true),
                LessonStep(icon: "plus.circle.fill", title: "Step 3: Add Details!", instruction: "Add smaller shapes around\nyour main form.\nBuild complexity! 🎭", hint: "Small details matter", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.fill", title: "Step 4: Gallery Show!", instruction: "Place multiple sculptures!\nCreate an art park\nworth visiting! ✨", hint: "Multiple pieces!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Sculpture park open! 🗿\nYou're a 3D artist now!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 41, title: "City Skyline", instruction: "Build a miniature city!",
            conceptExplanation: "**Urban Planning! 🏙️**\n\nCombine everything to build\na miniature city skyline!\n\nYou'll learn:\n- 🏙️ **City** composition\n- 🏢 Buildings of **varying heights**\n- 🎨 Color for **variety**",
            codeSnippet: "// City Skyline\n// shape: box\n// color: .blue\n// metallic: true\n// scaleX: 0.5\n// scaleY: 2.0  (tall building)\n// scaleZ: 0.5",
            challenges: [Challenge(id: "city", description: "Build a city skyline", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "building.2.crop.circle.fill", title: "City Skyline! 🏙️", instruction: "Build a miniature city!\nTowers, offices, homes!\nTap to begin!", hint: "Urban planning time!"),
                LessonStep(icon: "building.fill", title: "Step 1: First Tower", instruction: "Place a tall blue building.\nThe centerpiece of\nyour skyline! 🏢", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Building Code", instruction: "`scaleY: 2.0` = tall tower.\nChange this for each\nbuilding to vary heights!", hint: "Vary the heights!", showCodeEditor: true),
                LessonStep(icon: "building.2.fill", title: "Step 3: More Buildings!", instruction: "Change `scaleY:` to 1.0, 1.5, 3.0\nChange colors too!\nBuild a diverse skyline! 🌆", hint: "Different heights & colors", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "sparkles", title: "Step 4: Night Mode!", instruction: "Use dark colors with\n`metallic: true` for a\nglassy night city! ✨", hint: "Dark + metallic = glass", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "City built! 🏙️\nYou're an AR urban\nplanner now!", hint: "")
            ], codeEditorStartStep: 2),
        
        // MARK: - Chapter 7: Master Challenges (42-49)
        
        Lesson(id: 42, title: "Speed Builder", instruction: "Place objects as fast as possible!",
            conceptExplanation: "**Speed Run! ⚡**\n\nHow fast can you build?\nPlace 10 objects quickly!\n\nYou'll learn:\n- ⚡ **Speed** placement\n- 🎯 Quick **aim** skills\n- 🏆 Time yourself!",
            codeSnippet: "// Speed Build\n// shape: box\n// color: .green\n// scaleX: 0.5\n// scaleY: 0.5\n// scaleZ: 0.5",
            challenges: [Challenge(id: "speed_build", description: "Place 10 objects quickly", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "timer", title: "Speed Builder! ⚡", instruction: "Place as many objects\nas fast as you can!\nTap to begin!", hint: "Speed is key!"),
                LessonStep(icon: "cube.fill", title: "Step 1: GO!", instruction: "Start placing objects!\nTap tap tap the floor!\nAs fast as possible! ⚡", hint: "Tap fast!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Code Ready", instruction: "Simple code for speed.\nDon't edit — just TAP!\nSpeed > precision here!", hint: "Just keep tapping!", showCodeEditor: true),
                LessonStep(icon: "bolt.fill", title: "Step 3: Fill the Space!", instruction: "Cover the entire floor!\nEvery tap = new object.\nFill it up! 🟩", hint: "Tap everywhere!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.fill", title: "Step 4: New Color!", instruction: "Change color and continue!\nMix colors for a\ncolorful carpet! 🌈", hint: "Change color between rounds", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Speed builder! ⚡\nFast placement is\nkey for AR experiences.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 43, title: "Demolition Expert", instruction: "Build structures and destroy them!",
            conceptExplanation: "**Build & Destroy! 💥**\n\nThe satisfaction of creation\nfollowed by destruction!\n\nYou'll learn:\n- 🏗️ Quick **building**\n- 💥 Precise **destruction**\n- 🔄 Build → Destroy cycle",
            codeSnippet: "// Demolition\n// count: 8\n// shape: box\n// color: .red\n// speed: 12.0\n// mass: 3.0",
            challenges: [Challenge(id: "demolition", description: "Build and demolish structures", targetCount: 1, xpReward: 150)],
            steps: [
                LessonStep(icon: "hammer.fill", title: "Demolition Expert! 💥", instruction: "Build it up, then\ntear it down!\nTap to begin!", hint: "Create then destroy!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build Tower", instruction: "Tap to build a tower.\n8 blocks high!\nLooking good... 🏗️", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Arms Ready", instruction: "Heavy projectiles ready!\n`mass: 3.0` = wrecking balls\n`speed: 12.0` = fast!", hint: "Heavy + fast = chaos", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: DEMOLISH!", instruction: "Shoot the tower base!\nWatch it crumble! 💥\nSatisfying destruction!", hint: "Aim at the base!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.clockwise", title: "Step 4: Rebuild!", instruction: "Build another tower\nand demolish it again!\nBuild → Destroy → Repeat!", hint: "The cycle continues!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Demolition expert! 💥\nBuilding and destroying\nis endlessly fun!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 44, title: "Precision Master", instruction: "Place objects with careful precision!",
            conceptExplanation: "**Careful Placement 🎯**\n\nPrecision is an art.\nExact placement matters!\n\nYou'll learn:\n- 🎯 **Precise** object placement\n- 📏 **Consistent** spacing\n- ⚖️ Balance and symmetry",
            codeSnippet: "// Precision\n// shape: sphere\n// color: .white\n// scaleX: 0.6\n// scaleY: 0.6\n// scaleZ: 0.6",
            challenges: [Challenge(id: "precision", description: "Place objects precisely", targetCount: 1, xpReward: 125)],
            steps: [
                LessonStep(icon: "scope", title: "Precision Master! 🎯", instruction: "Every placement must\nbe perfect!\nTap to begin!", hint: "Steady hands!"),
                LessonStep(icon: "circle.fill", title: "Step 1: Center Piece", instruction: "Place one sphere exactly\nwhere you want it.\nTake your time! ⚪", hint: "Tap carefully!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Plan It", instruction: "Small, consistent spheres.\nPlan your layout before\nplacing each one.", hint: "Think before tap", showCodeEditor: true),
                LessonStep(icon: "circle", title: "Step 3: Symmetry!", instruction: "Place matching spheres\non both sides.\nPerfect symmetry! ⚖️", hint: "Left matches right", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.fill", title: "Step 4: Pattern!", instruction: "Create a precise pattern.\nCircle, line, or grid.\nArchitect-level precision! 📐", hint: "Order from chaos!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Precision mastered! 🎯\nCareful placement creates\nprofessional-looking scenes.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 45, title: "Physics Wizard", instruction: "Combine all physics concepts!",
            conceptExplanation: "**Physics Master Class! 🧙**\n\nCombine gravity, bounce, friction,\nand forces into one scene!\n\nYou'll learn:\n- 🧙 **Combined** physics\n- 🔬 Advanced **interactions**\n- 🎮 Game-ready physics!",
            codeSnippet: "// Physics Combo\n// mass: 1.0\n// restitution: 0.7\n// friction: 0.3\n// forceY: 8.0\n// forceZ: -5.0\n// color: .cyan\n// shape: sphere",
            challenges: [Challenge(id: "physics_wizard", description: "Combine physics concepts", targetCount: 1, xpReward: 175)],
            steps: [
                LessonStep(icon: "wand.and.stars", title: "Physics Wizard! 🧙", instruction: "Every physics concept\nin one level!\nTap to begin!", hint: "Master class!"),
                LessonStep(icon: "circle.fill", title: "Step 1: Bouncy Ball", instruction: "Place a ball with bounce,\nfriction, and mass combined.\nAll-in-one physics!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Full Physics", instruction: "mass + restitution + friction\n+ force = complete physics!\nEvery parameter matters.", hint: "All sliders active!", showCodeEditor: true),
                LessonStep(icon: "bolt.fill", title: "Step 3: Launch & Bounce!", instruction: "Tap to apply force!\nWatch it launch, arc,\nbounce, and slide! 🎪", hint: "Tap any object", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flame.fill", title: "Step 4: Chaos Mode!", instruction: "Extreme values!\n`mass: 0.1, restitution: 1.5`\n`forceY: 15.0` = chaos! 🌪️", hint: "Break the limits!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Physics wizard! 🧙\nYou command all forces\nof the AR universe!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 46, title: "Target Marathon", instruction: "Hit targets in rapid succession!",
            conceptExplanation: "**Marathon Run! 🏃**\n\nPlace targets all around\nand clear them all!\n\nYou'll learn:\n- 🏃 **Endurance** shooting\n- 🎯 Quick **target switching**\n- 📊 Hit all targets!",
            codeSnippet: "// Marathon\n// speed: 10.0\n// radius: 0.03\n// mass: 0.5\n// color: .red",
            challenges: [Challenge(id: "marathon", description: "Clear all targets", targetCount: 1, xpReward: 175)],
            steps: [
                LessonStep(icon: "flag.fill", title: "Target Marathon! 🏃", instruction: "Place many targets\nand clear them ALL!\nTap to begin!", hint: "Every target must fall!"),
                LessonStep(icon: "mappin.circle.fill", title: "Step 1: Setup Course", instruction: "Place 5+ targets around\nthe room. Spread them\nfar and wide!", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Marathon Code", instruction: "Medium speed for balance.\nYou'll need accuracy AND\nspeed for this challenge!", hint: "Balanced loadout", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: START!", instruction: "Begin the marathon!\nHit every target!\nDon't stop moving! 🏃", hint: "Move and shoot!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "flag.checkered", title: "Step 4: Clear All!", instruction: "Hit every last target!\nLeave no target standing!\nFinish line! 🏁", hint: "Get them all!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Marathon champion! 🏃\nAll targets eliminated!\nYou're unstoppable.", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 47, title: "Tower Defense", instruction: "Build towers and defend them!",
            conceptExplanation: "**Defend Your Base! 🛡️**\n\nBuild defensive towers\nand test their strength!\n\nYou'll learn:\n- 🛡️ **Defensive** building\n- 🏰 Strategic **placement**\n- 💥 Stress testing!",
            codeSnippet: "// Tower Defense\n// count: 10\n// shape: box\n// color: .gray\n// scaleX: 0.8\n// scaleY: 0.8\n// scaleZ: 0.8\n// speed: 8.0",
            challenges: [Challenge(id: "tower_defense", description: "Build and defend towers", targetCount: 1, xpReward: 175)],
            steps: [
                LessonStep(icon: "shield.fill", title: "Tower Defense! 🛡️", instruction: "Build strong towers!\nThen test their defenses!\nTap to begin!", hint: "Build to survive!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build Defense", instruction: "Build a tall, strong tower.\n10 blocks with sturdy\ndimensions! 🏗️", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Fort Code", instruction: "`count: 10` = tall defense.\nThick blocks hold better.\nBuild wide for stability!", hint: "Wide base = stable", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Attack!", instruction: "Now shoot at your tower!\nCan it survive? 💥\nTest its defenses!", hint: "Shoot the tower!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "arrow.clockwise", title: "Step 4: Rebuild Better!", instruction: "Build a BETTER tower.\nThicker blocks, wider base.\nCan this one survive? 🏰", hint: "Learn from failure!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Tower defended! 🛡️\nIterative design makes\neverything stronger!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 48, title: "Grand Constructor", instruction: "Build the most complex structure!",
            conceptExplanation: "**Master Builder! 🏛️**\n\nUse every tool to build\nsomething amazing.\n\nYou'll learn:\n- 🏛️ **Complex** construction\n- 🔧 **All tools** combined\n- ✨ Your masterpiece!",
            codeSnippet: "// Grand Build\n// shape: box\n// color: .indigo\n// metallic: true\n// scaleX: 1.0\n// scaleY: 1.0\n// scaleZ: 1.0\n// count: 5",
            challenges: [Challenge(id: "grand_build", description: "Build a complex structure", targetCount: 1, xpReward: 200)],
            steps: [
                LessonStep(icon: "crown.fill", title: "Grand Constructor! 🏛️", instruction: "Build something magnificent!\nUse all your skills!\nTap to begin!", hint: "Your finest work!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Foundation", instruction: "Start with a strong base.\nWide, thick blocks.\nEvery building needs roots! 🏗️", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Plan Grand", instruction: "Think BIG! Use stacks,\nscaling, different shapes.\nPlan each section.", hint: "Think like an architect", showCodeEditor: true),
                LessonStep(icon: "building.fill", title: "Step 3: Build Up!", instruction: "Add towers, walls, bridges!\nChange shape, color, scale\nbetween each section! 🏰", hint: "Mix everything!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "sparkles", title: "Step 4: Details!", instruction: "Add metallic accents,\nsmall decorations.\nMake it magnificent! ✨", hint: "Details make it grand", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "Level Complete! 🎉", instruction: "Grand construction! 🏛️\nYou're a true ARchitect\nmaster builder!", hint: "")
            ], codeEditorStartStep: 2),
        
        Lesson(id: 49, title: "Final Exam", instruction: "Prove your ARchitect mastery!",
            conceptExplanation: "**The Final Test! 🎓**\n\nEverything you've learned,\ncombined into one challenge!\n\nYou'll prove:\n- 🏗️ **Building** mastery\n- 🎯 **Shooting** accuracy\n- ⚡ **Physics** understanding\n- 🎨 **Creative** expression",
            codeSnippet: "// Final Exam\n// shape: box\n// color: .red\n// metallic: true\n// scaleX: 1.0\n// scaleY: 1.0\n// scaleZ: 1.0\n// mass: 1.0\n// speed: 10.0\n// count: 5",
            challenges: [Challenge(id: "final_exam", description: "Complete the final exam", targetCount: 1, xpReward: 250)],
            steps: [
                LessonStep(icon: "graduationcap.fill", title: "Final Exam! 🎓", instruction: "The ultimate test!\nEverything combined.\nAre you ready?", hint: "Show what you know!"),
                LessonStep(icon: "square.stack.fill", title: "Step 1: Build", instruction: "Build a structure using\nstacks and scales.\nYour construction skills! 🏗️", hint: "Tap the floor!", autoAdvance: true),
                LessonStep(icon: "chevron.left.forwardslash.chevron.right", title: "Step 2: Everything", instruction: "Use ALL parameters:\nshape, color, scale,\nmass, speed, count!", hint: "Full toolkit!", showCodeEditor: true),
                LessonStep(icon: "scope", title: "Step 3: Shoot!", instruction: "Place targets and hit them!\nShow your shooting skills!\nAccuracy counts! 🎯", hint: "Aim carefully!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "star.fill", title: "Step 4: Grand Finale!", instruction: "Build something amazing,\nthen dramatically destroy it!\nThe ultimate AR moment! 🔥", hint: "Go out with a BANG!", showCodeEditor: true, autoAdvance: true),
                LessonStep(icon: "checkmark.circle.fill", title: "GRADUATED! 🎓🏆", instruction: "You've mastered ARchitect!\nAll 49 lessons complete.\nNow enter Free Build!", hint: "")
            ], codeEditorStartStep: 2),
        
        // MARK: - Level 50: Free Build (Sandbox)
        Lesson(
            id: 50,
            title: "Free Build",
            instruction: "Sandbox mode — build anything!",
            conceptExplanation: """
            **Your AR Playground 🔓**
            
            All tools are unlocked! Combine everything
            you've learned to create freely.
            
            Available tools:
            - 📦 All **shapes** (box, sphere, cylinder, cone)
            - 📏 **Scale** transforms
            - 🎨 **Color** and material control
            - ⚡ **Physics** and forces
            - 🎯 **Projectile** shooting
            """,
            codeSnippet: """
            // Free Build Mode — All Tools!
            // shape: box  (box, sphere, cylinder, cone)
            // color: .cyan
            // metallic: true
            // scaleX: 1.0
            // scaleY: 1.0
            // scaleZ: 1.0
            // mass: 1.0
            // restitution: 0.5
            // speed: 8.0
            
            // Tap floor = place object
            // Tap object = apply physics
            // Tap air = shoot projectile!
            """,
            challenges: [
                Challenge(id: "free_builder", description: "Place 5 objects in sandbox", targetCount: 5, xpReward: 200)
            ],
            steps: [
                LessonStep(
                    icon: "wand.and.stars",
                    title: "Free Build Mode! 🔓",
                    instruction: "All tools are unlocked!\nBuild, shoot, stack — go wild!\nTap to enter sandbox.",
                    hint: "No rules, just create!"
                ),
                LessonStep(
                    icon: "hammer.fill",
                    title: "Build Freely!",
                    instruction: "🔨 Tap FLOOR → Place object\n👆 Tap OBJECT → Apply physics\n💨 Tap AIR → Shoot projectile\n\nEdit code to change everything!",
                    hint: "Use the code editor for full control",
                    showCodeEditor: true,
                    autoAdvance: false
                ),
                LessonStep(
                    icon: "checkmark.circle.fill",
                    title: "Congratulations! 🎉🏆",
                    instruction: "You've completed ARchitect!\nYou're now a certified AR developer.\nKeep building amazing things!",
                    hint: ""
                )
            ],
            codeEditorStartStep: 1
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
