import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var gameManager = GameManager.shared
    
    func makeUIView(context: Context) -> ARView {
        let cameraMode: ARView.CameraMode = gameManager.isSimulationMode ? .nonAR : .ar
        let arView = ARView(frame: .zero, cameraMode: cameraMode, automaticallyConfigureSession: !gameManager.isSimulationMode)
        
        context.coordinator.arView = arView
        
        if gameManager.isSimulationMode {
            context.coordinator.setupVirtualEnvironment(in: arView)
        } else {
            // Configure AR session
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.environmentTexturing = .automatic
            
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
                config.sceneReconstruction = .mesh
            }
            
            arView.session.delegate = context.coordinator // Set delegate
            arView.session.run(config)
            
            // Spawn prerequisite entities from previous levels (AR mode)
            if let lesson = gameManager.currentLesson {
                context.coordinator.spawnPrerequisites(for: lesson, in: arView)
            }
            
            // Enable Occlusion and Physics for real-world Interaction
            arView.environment.sceneUnderstanding.options = []
            
            // Turn on occlusion to hide virtual objects behind real ones
            arView.environment.sceneUnderstanding.options.insert(.occlusion)
            
            // Turn on physics to let objects collide with the real world mesh
            arView.environment.sceneUnderstanding.options.insert(.physics)
            
            // Render the mesh for debugging? No, user asked to remove debug visuals.
            // keeping separate debug options off.
            
        }
        
        // Setup gestures and subscriptions for BOTH simulation and AR modes
        context.coordinator.setupGestures()
        context.coordinator.setupSubscriptions()
        
        // Add Coaching Overlay
        if !gameManager.isSimulationMode {
            let coachingOverlay = ARCoachingOverlayView()
            coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            coachingOverlay.session = arView.session
            coachingOverlay.goal = .horizontalPlane
            arView.addSubview(coachingOverlay)
        }
        
        // Register Solar System Components
        OrbitComponent.registerComponent()
        RotationComponent.registerComponent()
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gameManager: gameManager)
    }
    
    // MARK: - Coordinator
    
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate, ARCoachingOverlayViewDelegate {
        var arView: ARView?
        var gameManager: GameManager
        var subscriptions: Set<AnyCancellable> = []
        
        // Virtual Studio
        var cameraRig: Entity?
        var virtualCamera: PerspectiveCamera?
        var cameraPitch: Float = -0.35
        
        // Tutorial tracking
        var hasLookedAround = false
        var hasZoomed = false
        var startPosition: SIMD3<Float> = .zero
        
        // AR Tracking
        var startLookRotation: simd_quatf?
        var maxLookDeviation: Float = 0
        
        // Focus Square
        var focusSquare: ModelEntity?
        
        init(gameManager: GameManager) {
            self.gameManager = gameManager
            super.init()
            setupFocusSquare()
        }
        
        func setupFocusSquare() {
            let mesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
            let material = SimpleMaterial(color: .yellow.withAlphaComponent(0.5), isMetallic: false)
            focusSquare = ModelEntity(mesh: mesh, materials: [material])
            focusSquare?.name = "FocusSquare"
            focusSquare?.isEnabled = false
        }
        
        // MARK: - Color Mapping
        
        private func colorFromString(_ name: String) -> UIColor {
            switch name.lowercased() {
            case "yellow":  return .yellow
            case "blue":    return .blue
            case "red":     return .red
            case "green":   return .green
            case "gray", "grey": return .gray
            case "orange":  return .orange
            case "cyan":    return .cyan
            case "white":   return .white
            case "brown":   return .brown
            default:        return .lightGray
            }
        }
        
        // MARK: - Prerequisite World State Restoration
        
        func spawnPrerequisites(for lesson: Lesson, in arView: ARView) {
            guard !lesson.prerequisites.isEmpty else { return }
            
            // Single shared anchor so orbits work relative to world origin
            let anchor = AnchorEntity(world: .zero)
            var spawnedEntities: [String: ModelEntity] = [:]
            
            // --- Pass 1: Spawn root entities (no parent, not a belt) ---
            for prereq in lesson.prerequisites where prereq.parentName == nil && prereq.shape.lowercased() != "belt" {
                let entity = createPrerequisiteEntity(from: prereq)
                entity.position = SIMD3<Float>(prereq.positionX, prereq.radius, 0)
                anchor.addChild(entity)
                spawnedEntities[prereq.name] = entity
            }
            
            // --- Pass 2: Spawn child entities (has parent, not a belt) ---
            for prereq in lesson.prerequisites where prereq.parentName != nil && prereq.shape.lowercased() != "belt" {
                if let parent = spawnedEntities[prereq.parentName!] {
                    let entity = createPrerequisiteEntity(from: prereq)
                    entity.position = .zero // orbit will position it
                    parent.addChild(entity)
                    spawnedEntities[prereq.name] = entity
                }
            }
            
            // --- Pass 3: Generate belts (shape == "belt") ---
            for prereq in lesson.prerequisites where prereq.shape.lowercased() == "belt" {
                let parentEntity: Entity? = prereq.parentName.flatMap { spawnedEntities[$0] } ?? anchor
                let count = prereq.count ?? 20
                let beltOrbitRadius = prereq.orbitRadius ?? 1.5
                
                let beltColors: [UIColor] = [.gray, .brown, .darkGray, .lightGray]
                
                for _ in 0..<count {
                    let randomScale = Float.random(in: 0.02...0.06)
                    let mesh = MeshResource.generateSphere(radius: randomScale)
                    let mat = SimpleMaterial(color: beltColors.randomElement()!, isMetallic: false)
                    
                    let asteroid = ModelEntity(mesh: mesh, materials: [mat])
                    asteroid.name = "Asteroid"
                    
                    let variance = Float.random(in: -0.15...0.15)
                    let finalRadius = beltOrbitRadius + variance
                    let speed = Float.random(in: 0.5...1.5)
                    
                    var orbit = OrbitComponent(radius: finalRadius, speed: speed)
                    orbit.currentAngle = Float.random(in: 0...(2 * .pi))
                    asteroid.components.set(orbit)
                    
                    asteroid.position.y = Float.random(in: -0.05...0.05)
                    parentEntity?.addChild(asteroid)
                }
            }
            
            arView.scene.addAnchor(anchor)
        }
        
        /// Creates a single ModelEntity from a PreRequisiteEntity definition
        private func createPrerequisiteEntity(from prereq: PreRequisiteEntity) -> ModelEntity {
            // Generate mesh
            let mesh: MeshResource
            switch prereq.shape.lowercased() {
            case "sphere":
                mesh = MeshResource.generateSphere(radius: prereq.radius)
            case "box":
                let size = prereq.radius * 2
                mesh = MeshResource.generateBox(size: size)
            case "cylinder":
                if #available(iOS 18.0, *) {
                    mesh = MeshResource.generateCylinder(height: prereq.radius * 2, radius: prereq.radius)
                } else {
                    mesh = MeshResource.generateBox(size: prereq.radius * 2)
                }
            case "cone":
                if #available(iOS 18.0, *) {
                    mesh = MeshResource.generateCone(height: prereq.radius * 2, radius: prereq.radius)
                } else {
                    mesh = MeshResource.generateSphere(radius: prereq.radius)
                }
            case "plane":
                mesh = MeshResource.generatePlane(width: prereq.radius * 2, depth: prereq.radius * 2)
            default:
                mesh = MeshResource.generateSphere(radius: prereq.radius)
            }
            
            // Material — stars (yellow/orange) use UnlitMaterial for glow
            let color = colorFromString(prereq.color)
            let isStar = (prereq.color.lowercased() == "yellow" || prereq.color.lowercased() == "orange")
            let materials: [any RealityKit.Material] = isStar
                ? [UnlitMaterial(color: color)]
                : [SimpleMaterial(color: color, isMetallic: false)]
            
            let entity = ModelEntity(mesh: mesh, materials: materials)
            entity.name = prereq.name
            
            // Star glow light
            if isStar {
                let light = PointLight()
                light.light.color = color
                light.light.intensity = 5000
                light.light.attenuationRadius = 10.0
                entity.addChild(light)
            }
            
            // Orbit
            if let orbitRadius = prereq.orbitRadius, let orbitSpeed = prereq.orbitSpeed {
                let orbit = OrbitComponent(radius: orbitRadius, speed: orbitSpeed)
                entity.components.set(orbit)
            }
            
            return entity
        }
        
        // MARK: - AR Session Delegate
        
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor in
                // Only process for AR mode tutorial steps
                guard !gameManager.isSimulationMode else { return }
                
                // Update Focus Square
                if let focusSquare = focusSquare, let arView = arView {
                    // Perform raycast to find plane
                    let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                    let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .estimatedPlane]
                    
                    var found = false
                    for target in queries {
                        if let result = arView.raycast(from: center, allowing: target, alignment: .horizontal).first {
                            if focusSquare.parent == nil {
                                let anchor = AnchorEntity(world: result.worldTransform)
                                anchor.addChild(focusSquare)
                                arView.scene.addAnchor(anchor)
                            } else {
                                if let anchor = focusSquare.parent as? AnchorEntity {
                                    anchor.transform.matrix = result.worldTransform
                                }
                            }
                            focusSquare.isEnabled = true
                            found = true
                            break
                        }
                    }
                    if !found {
                        focusSquare.isEnabled = false
                    }
                }
                
                let transform = frame.camera.transform
                let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                let rotation = simd_quatf(transform)
                
                // Step 2: Look Around (AR)
                if gameManager.tutorialStep == 2 && !hasLookedAround {
                    if startLookRotation == nil {
                        startLookRotation = rotation
                    }
                    
                    if let startRot = startLookRotation {
                        // Calculate angle difference from start rotation
                        let angleFunc = startRot.inverse * rotation
                        let deviation = angleFunc.angle
                        
                        if deviation > maxLookDeviation {
                            maxLookDeviation = deviation
                        }
                        
                        // Trigger if user has rotated at least 30 degrees (approx 0.52 radians)
                        if maxLookDeviation > 0.5 {
                            hasLookedAround = true
                            startLookRotation = nil // Reset
                            gameManager.advanceTutorial()
                        }
                    }
                } else if gameManager.tutorialStep != 2 {
                    // Reset tracker if not on step 2
                    startLookRotation = nil
                    maxLookDeviation = 0
                }
                
                // Step 3: Walk (AR)
                if gameManager.tutorialStep == 3 {
                    // Initialize start position for this step if needed
                    if startPosition == .zero {
                        startPosition = position
                    }
                    
                    let dist = simd_distance(position, startPosition)
                    // Walk 0.5 meters to complete
                    if dist > 0.5 {
                        gameManager.advanceTutorial()
                    }
                }
                // Step 4: Move Closer (AR)
                else if gameManager.tutorialStep == 4 {
                    if startPosition == .zero {
                        startPosition = position
                    }
                    
                    let dist = simd_distance(position, startPosition)
                    // Move 0.3 meters to complete
                    if dist > 0.3 {
                        gameManager.advanceTutorial()
                    }
                }
                else {
                    startPosition = .zero
                }
            }
        }
        
        // MARK: - Virtual Environment Setup
        
        func setupVirtualEnvironment(in arView: ARView) {
            setupLandWorld(in: arView)
            
            // Spawn prerequisite entities from previous levels
            if let lesson = gameManager.currentLesson {
                spawnPrerequisites(for: lesson, in: arView)
            }
        }
        
        // MARK: - ️ Land World (Ground, Gravity, Sunlight)
        
        func setupLandWorld(in arView: ARView) {
            // Sky gradient — dark blue-black
            arView.environment.background = .color(UIColor(red: 0.02, green: 0.02, blue: 0.06, alpha: 1.0))
            
            // Enable environment lighting for realistic reflections and ambient occlusion
            if let envResource = try? EnvironmentResource.load(named: "default") {
                arView.environment.lighting.resource = envResource
            }
            arView.environment.lighting.intensityExponent = 1.0
            
            let anchor = AnchorEntity(world: .zero)
            arView.scene.addAnchor(anchor)
            
            // === Ground Floor (Large, Grid-like) ===
            let floorMesh = MeshResource.generatePlane(width: 50, depth: 50)
            var floorMat = SimpleMaterial(color: UIColor(red: 0.12, green: 0.12, blue: 0.15, alpha: 1.0), isMetallic: true)
            floorMat.roughness = 0.6
            let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMat])
            floorEntity.name = "VirtualFloor"
            
            // Thick collision floor to prevent objects falling through
            let floorShape = ShapeResource.generateBox(size: [50, 1.0, 50])
            let floorCollision = CollisionComponent(shapes: [floorShape], mode: .default, filter: .default)
            floorEntity.components[CollisionComponent.self] = floorCollision
            floorEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            
            // Offset collision downward so top surface is at y=0
            let floorCollisionEntity = Entity()
            floorCollisionEntity.name = "FloorCollision"
            floorCollisionEntity.position.y = -0.5
            floorCollisionEntity.components[CollisionComponent.self] = floorCollision
            floorCollisionEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            
            anchor.addChild(floorEntity)
            anchor.addChild(floorCollisionEntity)
            
            // === Grid Lines on Floor ===
            // Create thin line entities for a subtle grid pattern
            let gridColor = UIColor(red: 0.2, green: 0.25, blue: 0.35, alpha: 0.4)
            let gridSpacing: Float = 1.0
            let gridCount = 25 // Lines in each direction
            
            for i in -gridCount...gridCount {
                let offset = Float(i) * gridSpacing
                
                // X-axis lines
                let xLine = ModelEntity(
                    mesh: .generateBox(size: [50, 0.002, 0.005]),
                    materials: [UnlitMaterial(color: gridColor)]
                )
                xLine.position = SIMD3<Float>(0, 0.001, offset)
                xLine.name = "GridLine"
                anchor.addChild(xLine)
                
                // Z-axis lines
                let zLine = ModelEntity(
                    mesh: .generateBox(size: [0.005, 0.002, 50]),
                    materials: [UnlitMaterial(color: gridColor)]
                )
                zLine.position = SIMD3<Float>(offset, 0.001, 0)
                zLine.name = "GridLine"
                anchor.addChild(zLine)
            }
            
            // === Distant Mountain Silhouettes ===
            let mountainPositions: [(SIMD3<Float>, Float, Float)] = [
                ([-20, 0, -25], 8, 4),
                ([-10, 0, -28], 6, 3),
                ([5, 0, -30], 10, 5),
                ([18, 0, -26], 7, 3.5),
                ([30, 0, -28], 9, 4.5),
                ([-30, 0, -22], 5, 2.5),
            ]
            
            for (pos, height, width) in mountainPositions {
                let mountain = ModelEntity(
                    mesh: .generateBox(size: [width, height, width * 0.8], cornerRadius: 0.5),
                    materials: [SimpleMaterial(color: UIColor(red: 0.06, green: 0.06, blue: 0.1, alpha: 1.0), isMetallic: false)]
                )
                mountain.position = SIMD3<Float>(pos.x, height / 2, pos.z)
                mountain.name = "Mountain"
                anchor.addChild(mountain)
            }
            
            // === Lighting (Sunlight) ===
            let sunLight = DirectionalLight()
            sunLight.light.color = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0) // Warm sun
            sunLight.light.intensity = 1200
            sunLight.look(at: .zero, from: [8, 10, 5], relativeTo: nil)
            anchor.addChild(sunLight)
            
            // Ambient fill light
            let fillLight = PointLight()
            fillLight.light.color = UIColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 1.0) // Cool blue fill
            fillLight.light.intensity = 400
            fillLight.light.attenuationRadius = 50
            fillLight.position = [-5, 8, 3]
            anchor.addChild(fillLight)
            
            // === Camera Rig ===
            let rig = Entity()
            rig.position = [0, 0, 5]
            anchor.addChild(rig)
            cameraRig = rig
            startPosition = rig.position
            
            let camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 50
            camera.camera.near = 0.01
            camera.camera.far = 200
            camera.position = [0, 2.0, 0]
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            rig.addChild(camera)
            virtualCamera = camera
            
            arView.cameraMode = .nonAR
        }
        
        // MARK: - Gesture Setup
        
        func setupGestures() {
            guard let arView = arView else { return }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.allowedScrollTypesMask = []
            arView.addGestureRecognizer(panGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            arView.addGestureRecognizer(pinchGesture)
            
            let scrollGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScroll(_:)))
            scrollGesture.allowedScrollTypesMask = [.continuous, .discrete]
            scrollGesture.maximumNumberOfTouches = 0
            arView.addGestureRecognizer(scrollGesture)
        }
        
        // MARK: - Look Around (Pan/Drag)
        
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard gameManager.isSimulationMode, let rig = cameraRig, let camera = virtualCamera else { return }
            
            let translation = sender.translation(in: sender.view)
            
            let yawDelta = Float(translation.x) * 0.005
            rig.orientation *= simd_quatf(angle: yawDelta, axis: [0, 1, 0])
            
            let pitchDelta = Float(translation.y) * 0.005
            cameraPitch -= pitchDelta
            cameraPitch = max(-.pi * 0.44, min(cameraPitch, .pi * 0.44))
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            
            sender.setTranslation(.zero, in: sender.view)
        }
        
        // MARK: - Zoom (Pinch)
        
        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            
            if sender.state == .changed {
                let scale = Float(sender.scale)
                var newFOV = camera.camera.fieldOfViewInDegrees / scale
                newFOV = max(20, min(newFOV, 100))
                camera.camera.fieldOfViewInDegrees = newFOV
                sender.scale = 1.0
            }
        }
        
        // MARK: - Zoom (Scroll Wheel)
        
        @objc func handleScroll(_ sender: UIPanGestureRecognizer) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            
            let scrollY = Float(sender.translation(in: sender.view).y)
            var newFOV = camera.camera.fieldOfViewInDegrees + scrollY * 0.1
            newFOV = max(20, min(newFOV, 100))
            camera.camera.fieldOfViewInDegrees = newFOV
            sender.setTranslation(.zero, in: sender.view)
        }
        
        // MARK: - Subscriptions (Frame Update)
        
        func setupSubscriptions() {
            guard let arView = arView else { return }
            
            arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                guard let self = self else { return }
                self.updateMovement(deltaTime: event.deltaTime)
                self.updateZoom(deltaTime: event.deltaTime)
                self.applyCustomGravity()
                self.updateOrbits(deltaTime: event.deltaTime)
                
                // Evaluate Game Logic / Win Conditions continuously
                if let arView = self.arView {
                    self.gameManager.evaluateCurrentGoal(context: arView)
                }
            }.store(in: &subscriptions)
            
            gameManager.$triggerConsoleExecution
                .dropFirst()
                .filter { $0 }
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.evaluateConsoleExecution()
                    self?.gameManager.triggerConsoleExecution = false
                }
                .store(in: &subscriptions)
        }
        
        // MARK: - Solar System Animation (Orbits)
        
        private func updateOrbits(deltaTime: Double) {
            guard let arView = arView else { return }
            
            // 1. Update Orbits
            let orbitQuery = arView.scene.performQuery(EntityQuery(where: .has(OrbitComponent.self)))
            orbitQuery.forEach { entity in
                if var orbit = entity.components[OrbitComponent.self] {
                    // Update angle
                    orbit.currentAngle += orbit.speed * Float(deltaTime)
                    if orbit.currentAngle > .pi * 2 { orbit.currentAngle -= .pi * 2 }
                    
                    // Calculate new position
                    let x = cos(orbit.currentAngle) * orbit.radius
                    let z = sin(orbit.currentAngle) * orbit.radius
                    
                    entity.position = SIMD3<Float>(x + orbit.center.x, entity.position.y, z + orbit.center.z)
                    
                    // Save back component
                    entity.components[OrbitComponent.self] = orbit
                }
            }
            
            // 2. Update Rotations (Self-Spin)
            let rotationQuery = arView.scene.performQuery(EntityQuery(where: .has(RotationComponent.self)))
            rotationQuery.forEach { entity in
                if let rot = entity.components[RotationComponent.self] {
                    let rotationAmount = rot.speed * Float(deltaTime)
                    entity.orientation *= simd_quatf(angle: rotationAmount, axis: [0, 1, 0])
                }
            }
        }
        
        // MARK: - Button Zoom (per-frame)
        
        private func updateZoom(deltaTime: Double) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            
            let input = gameManager.zoomInput
            if input == 0 { return }
            
            // +1 = zoom in (decrease FOV), -1 = zoom out (increase FOV)
            let zoomSpeed: Float = 40.0 * Float(deltaTime) // degrees per second
            var newFOV = camera.camera.fieldOfViewInDegrees - (input * zoomSpeed)
            newFOV = max(20, min(newFOV, 100))
            camera.camera.fieldOfViewInDegrees = newFOV
        }
        
        // MARK: - Walk / Strafe (Joystick)
        
        private func updateMovement(deltaTime: Double) {
            guard gameManager.isSimulationMode, let rig = cameraRig else { return }
            
            let input = gameManager.joystickInput
            if input == .zero { return }
            
            let speed: Float = 3.0 * Float(deltaTime)
            
            let rigTransform = rig.transformMatrix(relativeTo: nil)
            let forward = SIMD3<Float>(-rigTransform.columns.2.x, 0, -rigTransform.columns.2.z)
            let right = SIMD3<Float>(rigTransform.columns.0.x, 0, rigTransform.columns.0.z)
            
            let movement = (forward * input.y + right * input.x) * speed
            rig.position += movement
        }
        
        // MARK: - Custom Gravity Override (per-frame)
        
        private func applyCustomGravity() {
            guard let arView = arView else { return }
            
            // Parse gravity from current code snippet each frame
            let targetGravity = CodeParser.parseGravity(from: gameManager.codeSnippet)
            gameManager.customGravity = targetGravity
            
            // RealityKit default gravity is -9.8 m/s² (downward)
            // We apply a compensating force: (9.8 - targetGravity) * mass upward
            let gravityDiff = 9.8 - targetGravity
            
            if abs(gravityDiff) < 0.01 { return } // Default gravity, nothing to do
            
            // Find all dynamic UserObject entities and apply compensating force
            arView.scene.anchors.forEach { anchor in
                applyGravityToEntity(anchor, gravityDiff: gravityDiff)
            }
        }
        
        /// Recursively find UserObject entities and apply gravity compensation
        private func applyGravityToEntity(_ entity: Entity, gravityDiff: Float) {
            if let model = entity as? ModelEntity,
               let physics = model.components[PhysicsBodyComponent.self],
               physics.mode == .dynamic {
                
                let mass = physics.massProperties.mass
                let upwardForce = SIMD3<Float>(0, gravityDiff * mass, 0)
                model.addForce(upwardForce, relativeTo: nil)
            }
            for child in entity.children {
                applyGravityToEntity(child, gravityDiff: gravityDiff)
            }
        }

        
        // MARK: - Generic Tap Handler (Data-Driven by GoalType)
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            
            // Advance for step 0 (Start Lesson)
            if gameManager.tutorialStep == 0 {
                gameManager.advanceTutorial()
                return
            }
            
            guard let currentLesson = gameManager.currentLesson,
                  gameManager.tutorialStep < currentLesson.steps.count else { return }
            
            let currentGoal = currentLesson.steps[gameManager.tutorialStep].goal
            
            // Generic Action based on GoalType
            switch currentGoal {
            case .none:
                // Do nothing on tap, UI handles continue button
                break
                
            case .any:
                // Any tap advances the tutorial step
                gameManager.advanceTutorial()
                
            case .placeEntity(let name):
                if let worldPos = getTapWorldPosition(location: location, in: arView) {
                    spawnCosmicEntity(at: worldPos, name: name, in: arView)
                    gameManager.advanceTutorial()
                }
                
            case .buildOutpost(_):
                if let worldPos = getTapWorldPosition(location: location, in: arView) {
                    spawnCosmicEntity(at: worldPos, name: "Outpost Part", in: arView)
                }
                
            case .sandbox:
                if let worldPos = getTapWorldPosition(location: location, in: arView) {
                    spawnCosmicEntity(at: worldPos, name: "UserObject", in: arView)
                }
                
            case .modifyProperty(_, _, _):
                // Handled via evaluateConsoleExecution when user runs code
                break
                
            case .modifyPosition(_,_):
                // Handled via evaluateConsoleExecution when user runs code
                break
                
            case .modifyOrbit(_, _, _), .placeSatellite(_, _, _, _), .generateBelt(_, _, _), .modifyGravity(_), .applyForce(_, _), .modifyPhysics(_, _, _, _):
                // Handled via evaluateConsoleExecution when user runs code
                break
                
            case .any, .none:
                break
            }
        }
        
        // MARK: - Helper: Generic Spawner (GoalType.placeCelestialBody)
        
        private func spawnCosmicEntity(at position: SIMD3<Float>, name: String, in arView: ARView) {
            let anchor = AnchorEntity(world: position)
            arView.scene.addAnchor(anchor)
            
            let code = gameManager.codeSnippet
            let color = CodeParser.parseColor(from: code)
            let radius = CodeParser.parseRadius(from: code, defaultValue: 0.1)
            let mass = CodeParser.parseMass(from: code, defaultMass: 1.0)
            let isMetallic = CodeParser.parseMetallic(from: code)
            let scale = CodeParser.parseScale(from: code)
            
            let shapeName = CodeParser.parseShape(from: code).lowercased()
            let isStar = (shapeName == "star" || color == .yellow || color == .orange)
            
            // Generate Mesh based on Shape
            let mesh: MeshResource
            var verticalOffset: Float = radius // Default for sphere
            
            switch shapeName {
            case "box":
                let w = CodeParser.parseWidth(from: code, defaultWidth: radius * 2)
                let h = CodeParser.parseHeight(from: code, defaultHeight: radius * 2)
                let d = CodeParser.parseDepth(from: code, defaultDepth: radius * 2)
                mesh = MeshResource.generateBox(width: w, height: h, depth: d)
                verticalOffset = (h / 2) * scale.y
            case "cylinder":
                let h = CodeParser.parseHeight(from: code, defaultHeight: 0.2)
                if #available(iOS 18.0, *) {
                    mesh = MeshResource.generateCylinder(height: h, radius: radius)
                } else {
                    mesh = MeshResource.generateBox(size: radius * 2)
                }
                verticalOffset = (h / 2) * scale.y
            case "cone":
                let h = CodeParser.parseHeight(from: code, defaultHeight: 0.2)
                if #available(iOS 18.0, *) {
                    mesh = MeshResource.generateCone(height: h, radius: radius)
                } else {
                    mesh = MeshResource.generateSphere(radius: radius)
                }
                verticalOffset = (h / 2) * scale.y
            case "plane":
                let w = CodeParser.parseWidth(from: code, defaultWidth: 0.3)
                let d = CodeParser.parseDepth(from: code, defaultDepth: 0.3)
                mesh = MeshResource.generatePlane(width: w, depth: d)
                verticalOffset = 0.001
            default: // sphere or star
                mesh = MeshResource.generateSphere(radius: radius)
                verticalOffset = radius * scale.y
            }
            
            var mat = SimpleMaterial(color: color, isMetallic: isMetallic)
            if isStar {
                mat = SimpleMaterial(color: color, isMetallic: false)
            }
            
            let entity = ModelEntity(mesh: mesh, materials: [mat])
            entity.name = name
            entity.scale = scale
            entity.position.y = verticalOffset // Rest on the floor
            
            if isStar {
                let light = PointLight()
                light.light.intensity = 2000
                light.light.attenuationRadius = 5.0
                entity.addChild(light)
            }
            
            // Physics
            entity.generateCollisionShapes(recursive: true)
            let physics = PhysicsBodyComponent(massProperties: .init(mass: mass), material: .default, mode: .dynamic)
            entity.components[PhysicsBodyComponent.self] = physics
            
            // Orbit (if applicable)
            if let _ = code.range(of: "orbit") {
                let orbitSpeed = CodeParser.parseOrbitSpeed(from: code)
                let orbitRadius = CodeParser.parseOrbitRadius(from: code)
                entity.components[OrbitComponent.self] = OrbitComponent(radius: orbitRadius, speed: orbitSpeed)
            }
            
            anchor.addChild(entity)
            gameManager.placedObjectCount += 1
            HapticsManager.shared.play(.medium)
        }
        
        // MARK: - Evaluate Console
        
        func evaluateConsoleExecution() {
            guard let arView = arView,
                  let currentLesson = gameManager.currentLesson,
                  gameManager.tutorialStep < currentLesson.steps.count else { return }
                  
            let currentGoal = currentLesson.steps[gameManager.tutorialStep].goal
            
            if case .modifyProperty(let target, _, let minRadius) = currentGoal {
                let code = gameManager.codeSnippet
                let color = CodeParser.parseColor(from: code)
                let radius = CodeParser.parseRadius(from: code)
                
                // Color parser maps "yellow" string to .yellow UIColor.
                // It's a simplistic check for this specific lesson
                if color == .yellow && radius >= minRadius {
                    // Find the entity recursively
                    if let entity = findEntity(named: target, in: arView) {
                        
                        // Change material to Unlit yellow for Emissive look
                        entity.model?.materials = [UnlitMaterial(color: .yellow)]
                        
                        // Scale animation and adjust Y position to rest on the floor
                        let scaleFactor = radius / 0.1 // Since initial radius was 0.1
                        var transform = entity.transform
                        transform.scale = SIMD3<Float>(repeating: scaleFactor)
                        transform.translation.y = radius // Update Y to match new radius
                        entity.move(to: transform, relativeTo: entity.parent, duration: 1.0, timingFunction: .easeInOut)
                        
                        // Add star illumination
                        let light = PointLight()
                        light.light.color = .yellow
                        light.light.intensity = 5000
                        light.light.attenuationRadius = 10.0
                        entity.addChild(light)
                        
                        HapticsManager.shared.play(.heavy)
                        
                        // Give time for animation before advancing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .modifyPosition(let target, let targetX) = currentGoal {
                let code = gameManager.codeSnippet
                let posX = CodeParser.parsePositionX(from: code)
                
                if abs(posX - targetX) < 0.01 {
                    // Find the target entity recursively
                    if let entity = findEntity(named: target, in: arView) {
                        
                        var transform = entity.transform
                        transform.translation = SIMD3<Float>(posX, entity.position.y, entity.position.z)
                        entity.move(to: transform, relativeTo: entity.parent, duration: 1.0, timingFunction: .easeInOut)
                        
                        HapticsManager.shared.play(.heavy)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .modifyOrbit(let target, let targetRadius, let targetSpeed) = currentGoal {
                let code = gameManager.codeSnippet
                let radius = CodeParser.parseOrbitRadius(from: code)
                let speed = CodeParser.parseOrbitSpeed(from: code)
                
                if abs(radius - targetRadius) < 0.01 && abs(speed - targetSpeed) < 0.01 {
                    if let entity = findEntity(named: target, in: arView) {
                        
                        if var orbitComponent = entity.components[OrbitComponent.self] {
                            orbitComponent.radius = radius
                            orbitComponent.speed = speed
                            entity.components[OrbitComponent.self] = orbitComponent
                        } else {
                            let orbit = OrbitComponent(radius: radius, speed: speed)
                            entity.components.set(orbit)
                        }
                        
                        HapticsManager.shared.play(.light)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .placeSatellite(let parent, let name, let targetRadius, let targetSpeed) = currentGoal {
                let code = gameManager.codeSnippet
                let radius = CodeParser.parseOrbitRadius(from: code)
                let speed = CodeParser.parseOrbitSpeed(from: code)
                
                if abs(radius - targetRadius) < 0.01 && abs(speed - targetSpeed) < 0.01 {
                    if let parentEntity = findEntity(named: parent, in: arView) {
                        
                        let mesh = MeshResource.generateSphere(radius: 0.05)
                        let mat = SimpleMaterial(color: .gray, isMetallic: false)
                        let moonEntity = ModelEntity(mesh: mesh, materials: [mat])
                        moonEntity.name = name
                        moonEntity.position = SIMD3<Float>(0, 0, 0) // Start at center of parent
                        
                        let orbit = OrbitComponent(radius: radius, speed: speed)
                        moonEntity.components.set(orbit)
                        
                        parentEntity.addChild(moonEntity)
                        
                        HapticsManager.shared.play(.medium)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .generateBelt(let target, let minCount, let targetRadius) = currentGoal {
                let code = gameManager.codeSnippet
                let count = CodeParser.parseCount(from: code)
                
                if count >= minCount {
                    // Use recursive search to find the target entity anywhere in the scene
                    if let parentEntity = findEntity(named: target, in: arView) {
                        
                        for _ in 0..<count {
                            let randomScale = Float.random(in: 0.02...0.06)
                            let mesh = MeshResource.generateSphere(radius: randomScale)
                            
                            // Randomize material between gray and brown
                            let colors: [UIColor] = [.gray, .brown, .darkGray, .lightGray]
                            let mat = SimpleMaterial(color: colors.randomElement()!, isMetallic: false)
                            
                            let asteroidEntity = ModelEntity(mesh: mesh, materials: [mat])
                            asteroidEntity.name = "Asteroid"
                            
                            // Slight variation in radius
                            let variance = Float.random(in: -0.15...0.15)
                            let finalRadius = targetRadius + variance
                            
                            // Random orbit speed
                            let speed = Float.random(in: 0.5...1.5)
                            
                            var orbit = OrbitComponent(radius: finalRadius, speed: speed)
                            orbit.currentAngle = Float.random(in: 0...(2 * .pi))
                            asteroidEntity.components.set(orbit)
                            
                            // Stagger Y position slightly for a 3D belt effect
                            asteroidEntity.position.y = Float.random(in: -0.05...0.05)
                            
                            parentEntity.addChild(asteroidEntity)
                        }
                        
                        HapticsManager.shared.play(.heavy)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .modifyGravity(let targetGravity) = currentGoal {
                let code = gameManager.codeSnippet
                if let gravity = CodeParser.parseFloat(from: code, keyword: "gravity"), abs(gravity - targetGravity) < 0.01 {
                    gameManager.customGravity = gravity
                    HapticsManager.shared.play(.heavy)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.gameManager.advanceTutorial()
                    }
                }
            } else if case .applyForce(let target, let requiredZ) = currentGoal {
                let code = gameManager.codeSnippet
                let forceZ = CodeParser.parseFloat(from: code, keyword: "forceZ") ?? 0.0
                
                if abs(forceZ - requiredZ) < 0.01 {
                    if let entity = findEntity(named: target, in: arView) {
                        
                        let force = SIMD3<Float>(0, 0, forceZ)
                        entity.applyLinearImpulse(force, relativeTo: nil)
                        
                        HapticsManager.shared.play(.heavy)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .modifyPhysics(let target, let targetFriction, let targetMass, let targetRestitution) = currentGoal {
                let code = gameManager.codeSnippet
                let friction = CodeParser.parseFloat(from: code, keyword: "friction")
                let mass = CodeParser.parseFloat(from: code, keyword: "mass")
                let restitution = CodeParser.parseFloat(from: code, keyword: "restitution")
                
                var success = true
                if let tf = targetFriction, abs((friction ?? -1) - tf) > 0.01 { success = false }
                if let tm = targetMass, abs((mass ?? -1) - tm) > 0.01 { success = false }
                if let tr = targetRestitution, abs((restitution ?? -1) - tr) > 0.01 { success = false }
                
                if success {
                    if let entity = findEntity(named: target, in: arView) {
                        
                        let safeFriction = friction ?? 0.5
                        let safeRestitution = restitution ?? 0.0
                        let safeMass = mass ?? 1.0
                        
                        let material = PhysicsMaterialResource.generate(friction: safeFriction, restitution: safeRestitution)
                        let physics = PhysicsBodyComponent(massProperties: .init(mass: safeMass), material: material, mode: .dynamic)
                        entity.components.set(physics)
                        entity.generateCollisionShapes(recursive: true)
                        
                        HapticsManager.shared.play(.medium)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            } else if case .buildOutpost(let requiredParts) = currentGoal {
                var outpostParts = 0
                for anchor in arView.scene.anchors {
                    for entity in anchor.children {
                        if entity.name == "Outpost Part" || entity.name.contains("ylinder") || entity.name.contains("ox") {
                            outpostParts += 1
                        }
                    }
                }
                
                if outpostParts >= requiredParts {
                    HapticsManager.shared.play(.heavy)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.gameManager.advanceTutorial()
                    }
                }
            } else if case .sandbox = currentGoal {
                // Sandbox mode: Execute code and spawn/modify objects but never advance.
                // Modifications are handled by applying properties to the found target or creating a generic object.
                // For sandbox, we'll try to find any "UserObject" or the target specified in code.
                _ = CodeParser.parseFloat(from: gameManager.codeSnippet, keyword: "target") == nil ? "UserObject" : "SpecifiedTarget"
                // Actually, in sandbox, EXECUTE usually means "apply these global/local settings to the NEXT spawn" 
                // or "modify the last touched object". Since our architecture is data-driven, 
                // EXECUTE already updates the codeSnippet for the NEXT tap.
                HapticsManager.shared.play(.light)
            }
        }
        
        // MARK: - Generic Utilities
        
        private func getTapWorldPosition(location: CGPoint, in arView: ARView) -> SIMD3<Float>? {
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    return hit.position
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        return SIMD3<Float>(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y + 0.5, result.worldTransform.columns.3.z)
                    }
                }
            }
            return nil
        }
        
        /// Recursively finds an entity by name anywhere in the scene graph
        private func findEntity(named name: String, in arView: ARView) -> ModelEntity? {
            for anchor in arView.scene.anchors {
                if let found = findEntityRecursive(named: name, in: anchor) {
                    return found
                }
            }
            return nil
        }
        
        private func findEntityRecursive(named name: String, in entity: Entity) -> ModelEntity? {
            if entity.name == name, let model = entity as? ModelEntity {
                return model
            }
            for child in entity.children {
                if let found = findEntityRecursive(named: name, in: child) {
                    return found
                }
            }
            return nil
        }
        
        private func flashEntity(_ entity: ModelEntity) {
            if let originalMaterial = entity.model?.materials.first {
                entity.model?.materials = [SimpleMaterial(color: .white, isMetallic: true)]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    entity.model?.materials = [originalMaterial]
                }
            }
        }
    }
}
