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
        var cameraPitch: Float = -0.3
        
        // Tutorial tracking
        var targetMarker: ModelEntity?
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
            arView.environment.background = .color(.black)
            
            // Virtual Floor
            let floorMesh = MeshResource.generatePlane(width: 20, depth: 20)
            var floorMat = SimpleMaterial(color: .darkGray, isMetallic: false)
            floorMat.roughness = 0.9
            let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMat])
            floorEntity.name = "VirtualFloor"
            floorEntity.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [20, 0.01, 20])])
            floorEntity.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
            
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(floorEntity)
            arView.scene.addAnchor(anchor)
            
            // Lighting
            let directionalLight = DirectionalLight()
            directionalLight.light.color = .white
            directionalLight.light.intensity = 1000
            directionalLight.look(at: .zero, from: [5, 5, 5], relativeTo: nil)
            anchor.addChild(directionalLight)
            
            // Camera Rig
            let rig = Entity()
            rig.position = [0, 0, 3]
            anchor.addChild(rig)
            cameraRig = rig
            startPosition = rig.position
            
            let camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 60
            camera.position = [0, 1.5, 0]
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            rig.addChild(camera)
            virtualCamera = camera
            
            arView.cameraMode = .nonAR
            
            // Tutorial: Place glowing target marker for Step 3 (walk toward it)
            let markerMesh = MeshResource.generateBox(size: [0.3, 0.02, 0.3], cornerRadius: 0.02)
            var markerMat = SimpleMaterial(color: .cyan, isMetallic: true)
            markerMat.roughness = 0.1
            let marker = ModelEntity(mesh: markerMesh, materials: [markerMat])
            marker.position = [0, 0.01, 0] // At origin on the floor
            marker.name = "TutorialMarker"
            anchor.addChild(marker)
            targetMarker = marker
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
            
            // Only allow looking around from step 2 onward (Level 1) or always (Levels 2+)
            guard gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 2 else { return }
            
            let translation = sender.translation(in: sender.view)
            
            let yawDelta = Float(translation.x) * 0.005
            rig.orientation *= simd_quatf(angle: yawDelta, axis: [0, 1, 0])
            
            let pitchDelta = Float(translation.y) * 0.005
            cameraPitch -= pitchDelta
            cameraPitch = max(-.pi * 0.44, min(cameraPitch, .pi * 0.44))
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            
            sender.setTranslation(.zero, in: sender.view)
            
            // Tutorial: Complete Step 2 after looking around
            if gameManager.tutorialStep == 2 && !hasLookedAround {
                let totalDelta = abs(yawDelta) + abs(pitchDelta)
                if totalDelta > 0.001 {
                    hasLookedAround = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if self.gameManager.tutorialStep == 2 {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            }
        }
        
        // MARK: - Zoom (Pinch)
        
        @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            guard gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 4 else { return }
            
            if sender.state == .changed {
                let scale = Float(sender.scale)
                var newFOV = camera.camera.fieldOfViewInDegrees / scale
                newFOV = max(20, min(newFOV, 100))
                camera.camera.fieldOfViewInDegrees = newFOV
                sender.scale = 1.0
                
                // Tutorial: Complete Step 4
                if gameManager.tutorialStep == 4 && !hasZoomed {
                    hasZoomed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if self.gameManager.tutorialStep == 4 {
                            self.gameManager.advanceTutorial()
                        }
                    }
                }
            }
        }
        
        // MARK: - Zoom (Scroll Wheel)
        
        @objc func handleScroll(_ sender: UIPanGestureRecognizer) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            guard gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 4 else { return }
            
            let scrollY = Float(sender.translation(in: sender.view).y)
            var newFOV = camera.camera.fieldOfViewInDegrees + scrollY * 0.1
            newFOV = max(20, min(newFOV, 100))
            camera.camera.fieldOfViewInDegrees = newFOV
            sender.setTranslation(.zero, in: sender.view)
            
            // Tutorial: Complete Step 4
            if gameManager.tutorialStep == 4 && !hasZoomed {
                hasZoomed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    if self.gameManager.tutorialStep == 4 {
                        self.gameManager.advanceTutorial()
                    }
                }
            }
        }
        
        // MARK: - Subscriptions (Frame Update)
        
        func setupSubscriptions() {
            guard let arView = arView else { return }
            
            arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.updateMovement(deltaTime: event.deltaTime)
                self?.updateZoom(deltaTime: event.deltaTime)
                self?.updateTutorialMarker(deltaTime: event.deltaTime)
            }.store(in: &subscriptions)
        }
        
        // MARK: - Button Zoom (per-frame)
        
        private func updateZoom(deltaTime: Double) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            guard gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 4 else { return }
            
            let input = gameManager.zoomInput
            if input == 0 { return }
            
            // +1 = zoom in (decrease FOV), -1 = zoom out (increase FOV)
            let zoomSpeed: Float = 40.0 * Float(deltaTime) // degrees per second
            var newFOV = camera.camera.fieldOfViewInDegrees - (input * zoomSpeed)
            newFOV = max(20, min(newFOV, 100))
            camera.camera.fieldOfViewInDegrees = newFOV
            
            // Tutorial: Complete Step 4
            if gameManager.tutorialStep == 4 && !hasZoomed {
                hasZoomed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    if self.gameManager.tutorialStep == 4 {
                        self.gameManager.advanceTutorial()
                    }
                }
            }
        }
        
        // MARK: - Walk / Strafe (Joystick)
        
        private func updateMovement(deltaTime: Double) {
            guard gameManager.isSimulationMode, let rig = cameraRig else { return }
            
            // Only allow walking from step 3 onward (Level 1) or always (Levels 2+)
            guard gameManager.currentLessonIndex > 1 || gameManager.tutorialStep >= 3 else { return }
            
            let input = gameManager.joystickInput
            if input == .zero { return }
            
            let speed: Float = 3.0 * Float(deltaTime)
            
            let rigTransform = rig.transformMatrix(relativeTo: nil)
            let forward = SIMD3<Float>(-rigTransform.columns.2.x, 0, -rigTransform.columns.2.z)
            let right = SIMD3<Float>(rigTransform.columns.0.x, 0, rigTransform.columns.0.z)
            
            let movement = (forward * input.y + right * input.x) * speed
            rig.position += movement
            
            // Tutorial: Track walk distance for Step 3
            if gameManager.tutorialStep == 3 {
                let distFromStart = simd_distance(rig.position, startPosition)
                if distFromStart > 1.0 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Tutorial Marker Animation
        
        private var markerTime: Float = 0
        
        private func updateTutorialMarker(deltaTime: Double) {
            guard let marker = targetMarker else { return }
            
            markerTime += Float(deltaTime)
            
            // Pulse the marker opacity
            let pulse = (sin(markerTime * 3.0) + 1.0) / 2.0
            let showMarker = gameManager.tutorialStep <= 3
            
            if showMarker {
                marker.isEnabled = true
                // Gentle float animation
                marker.position.y = 0.01 + pulse * 0.03
            } else {
                marker.isEnabled = false
            }
        }
        
        // MARK: - Tap Handler
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            
            let lessonIndex = gameManager.currentLessonIndex
            let step = gameManager.tutorialStep
            
            // Route by lesson
            switch lessonIndex {
            case 1:
                handleLevel1Tap(step: step, location: location, in: arView)
            case 2:
                handleLevel2Tap(step: step, location: location, in: arView)
            case 3:
                handleLevel3Tap(step: step, location: location, in: arView)
            case 4:
                handleLevel4Tap(step: step, location: location, in: arView)
            case 5:
                handleLevel5Tap(step: step, location: location, in: arView)
            case 6:
                handleLevel6Tap(step: step, location: location, in: arView)
            case 7:
                handleLevel7Tap(step: step, location: location, in: arView)
            case 8:
                handleLevel8Tap(step: step, location: location, in: arView)
            case 9:
                handleLevel9Tap(step: step, location: location, in: arView)
            case 10...17:
                handlePhysicsMasteryTap(step: step, location: location, in: arView)
            case 18...25:
                handleShootingLevelTap(step: step, location: location, in: arView)
            case 26...33:
                handleBuildingLevelTap(step: step, location: location, in: arView)
            case 34...41:
                handleCreativeLevelTap(step: step, location: location, in: arView)
            case 42...49:
                handleChallengeLevelTap(step: step, location: location, in: arView)
            case 50:
                handleLevel10Tap(step: step, location: location, in: arView)
            default:
                handleLevel1Tap(step: step, location: location, in: arView)
            }
        }
        
        // MARK: - Level 1: Tutorial Tap
        
        func handleLevel1Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0, 1:
                gameManager.advanceTutorial()
            case 5:
                handlePlaceObject(location: location, in: arView)
            case 6:
                handleCodeApply(location: location, in: arView)
            default:
                if step > 5 {
                    if let entity = arView.entity(at: location) as? ModelEntity,
                       entity.name != "VirtualFloor" && entity.name != "TutorialMarker" {
                        handleCodeApply(location: location, in: arView)
                    } else {
                        handlePlaceObject(location: location, in: arView)
                    }
                }
            }
        }
        
        // MARK: - Level 2: Gravity & Mass Tap
        
        func handleLevel2Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place a static box
                handlePlaceObject(location: location, in: arView)
            case 3:
                // Tap an existing object to apply physics (gravity)
                handleApplyPhysics(location: location, in: arView)
            case 4:
                // Place another object with new mass, then apply physics
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name == "UserObject" && entity.components[PhysicsBodyComponent.self] == nil {
                    handleApplyPhysics(location: location, in: arView)
                } else {
                    handlePlaceObject(location: location, in: arView)
                }
            default:
                break
            }
        }
        
        // MARK: - Level 3: Bounce & Collide Tap
        
        func handleLevel3Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place a bouncy sphere with physics
                handlePlaceBounceObject(location: location, in: arView)
            case 3, 4:
                // Place more spheres with modified restitution
                handlePlaceBounceObject(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Level 4: Forces & Impulse Tap
        
        func handleLevel4Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place the object to launch
                handlePlaceObject(location: location, in: arView)
            case 3, 4:
                // Tap an object to apply force
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name == "UserObject" {
                    handleApplyImpulse(entity: entity)
                } else {
                    // Tap floor to place new object
                    handlePlaceObject(location: location, in: arView)
                }
            default:
                break
            }
        }
        
        // MARK: - Place Object (generic)
        
        func handlePlaceObject(location: CGPoint, in arView: ARView) {
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .existingPlaneInfinite, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        worldTransform = result.worldTransform
                        break
                    }
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            let shape = CodeParser.parseShape(from: gameManager.codeSnippet)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            var mat = SimpleMaterial(color: color, isMetallic: true)
            mat.roughness = 0.15
            
            let model: ModelEntity
            
            if shape == "sphere" {
                let radius: Float = 0.08
                let mesh = MeshResource.generateSphere(radius: radius)
                model = ModelEntity(mesh: mesh, materials: [mat])
                model.position.y = radius
            } else {
                let width = CodeParser.parseWidth(from: gameManager.codeSnippet, defaultWidth: 0.15)
                let height = CodeParser.parseHeight(from: gameManager.codeSnippet, defaultHeight: 0.05)
                let length = CodeParser.parseDepth(from: gameManager.codeSnippet, defaultDepth: 0.15)
                let chamfer = CodeParser.parseChamfer(from: gameManager.codeSnippet, defaultChamfer: 0.02)
                let mesh = MeshResource.generateBox(size: [width, height, length], cornerRadius: chamfer)
                model = ModelEntity(mesh: mesh, materials: [mat])
                model.position.y = height / 2
            }
            
            model.name = "UserObject"
            model.generateCollisionShapes(recursive: true)
            anchor.addChild(model)
            
            gameManager.placedObjectCount += 1
            HapticsManager.shared.play(.medium)
            
            // Level 1 Tutorial: Complete Step 5
            if gameManager.currentLessonIndex == 1 && gameManager.tutorialStep == 5 {
                gameManager.advanceTutorial()
            }
            // Level 2: Complete Step 1 (place a box)
            if gameManager.currentLessonIndex == 2 && gameManager.tutorialStep == 1 {
                gameManager.advanceTutorial()
            }
            // Level 4: Complete Step 1 (place an object)
            if gameManager.currentLessonIndex == 4 && gameManager.tutorialStep == 1 {
                gameManager.advanceTutorial()
            }
            // Level 6: Complete Step 1 (place a sphere) or Step 4 (place with new material)
            if gameManager.currentLessonIndex == 6 {
                if gameManager.tutorialStep == 1 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Apply Physics (Level 2: Gravity)
        
        func handleApplyPhysics(location: CGPoint, in arView: ARView) {
            guard let entity = arView.entity(at: location) as? ModelEntity,
                  entity.name == "UserObject" else { return }
            
            let mass = CodeParser.parseMass(from: gameManager.codeSnippet)
            
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: mass),
                material: .default,
                mode: .dynamic
            )
            entity.components[PhysicsBodyComponent.self] = physics
            
            // Visual feedback — flash
            let originalColor = CodeParser.parseColor(from: gameManager.codeSnippet)
            entity.model?.materials = [SimpleMaterial(color: .white, isMetallic: true)]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                entity.model?.materials = [SimpleMaterial(color: originalColor, isMetallic: true)]
            }
            
            HapticsManager.shared.play(.heavy)
            
            // Advance tutorial step
            if gameManager.currentLessonIndex == 2 {
                if gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Place Bounce Object (Level 3)
        
        func handlePlaceBounceObject(location: CGPoint, in arView: ARView) {
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .existingPlaneInfinite, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        worldTransform = result.worldTransform
                        break
                    }
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            let restitution = CodeParser.parseRestitution(from: gameManager.codeSnippet)
            let mass = CodeParser.parseMass(from: gameManager.codeSnippet)
            
            // Create sphere
            let radius: Float = 0.08
            let mesh = MeshResource.generateSphere(radius: radius)
            var mat = SimpleMaterial(color: color, isMetallic: true)
            mat.roughness = 0.2
            let sphere = ModelEntity(mesh: mesh, materials: [mat])
            sphere.name = "UserObject"
            sphere.position.y = 1.5 // Drop from height
            sphere.generateCollisionShapes(recursive: true)
            
            // Physics with custom restitution
            let physicsMaterial = PhysicsMaterialResource.generate(
                staticFriction: 0.5,
                dynamicFriction: 0.5,
                restitution: restitution
            )
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: mass),
                material: physicsMaterial,
                mode: .dynamic
            )
            sphere.components[PhysicsBodyComponent.self] = physics
            
            anchor.addChild(sphere)
            
            gameManager.placedObjectCount += 1
            HapticsManager.shared.play(.medium)
            
            // Advance tutorial
            if gameManager.currentLessonIndex == 3 {
                if gameManager.tutorialStep == 1 || gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Apply Impulse Force (Level 4)
        
        func handleApplyImpulse(entity: ModelEntity) {
            let mass = CodeParser.parseMass(from: gameManager.codeSnippet)
            let force = CodeParser.parseForce(from: gameManager.codeSnippet)
            
            // Ensure entity has physics
            if entity.components[PhysicsBodyComponent.self] == nil {
                entity.generateCollisionShapes(recursive: true)
                let physics = PhysicsBodyComponent(
                    massProperties: .init(mass: mass),
                    material: .default,
                    mode: .dynamic
                )
                entity.components[PhysicsBodyComponent.self] = physics
            }
            
            // Apply impulse
            entity.applyLinearImpulse(force, relativeTo: nil)
            
            // Visual flash
            let originalColor = CodeParser.parseColor(from: gameManager.codeSnippet)
            entity.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: true)]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                entity.model?.materials = [SimpleMaterial(color: originalColor, isMetallic: true)]
            }
            
            HapticsManager.shared.play(.heavy)
            
            // Advance tutorial
            if gameManager.currentLessonIndex == 4 {
                if gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Level 5: Scaling & Transform Tap
        
        func handleLevel5Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place a normal box
                handlePlaceScaledObject(location: location, in: arView)
            case 3, 4:
                // Place scaled objects
                handlePlaceScaledObject(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Level 6: Color Lab Tap
        
        func handleLevel6Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place a sphere
                handlePlaceObject(location: location, in: arView)
            case 3:
                // Tap existing object to repaint
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name == "UserObject" {
                    handleRepaintObject(entity: entity)
                }
            case 4:
                // Place new object with updated material
                handlePlaceObject(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Level 7: Shape Factory Tap
        
        func handleLevel7Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1, 3, 4, 5:
                // Place various shapes
                handlePlaceShapeObject(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Level 8: Target Practice Tap
        
        func handleLevel8Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Place a target on the floor
                handlePlaceTarget(location: location, in: arView)
            case 3, 4:
                // Shoot projectile from camera
                handleShootProjectile(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Level 9: Stack & Topple Tap
        
        func handleLevel9Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1, 4:
                // Build a tower
                handlePlaceStack(location: location, in: arView)
            case 3:
                // Shoot to topple
                handleShootProjectile(location: location, in: arView)
            default:
                break
            }
        }
        
        // MARK: - Physics Mastery (10-17) Tap
        
        func handlePhysicsMasteryTap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                handlePlaceBounceObject(location: location, in: arView)
                gameManager.advanceTutorial()
            case 3:
                if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    let force = CodeParser.parseForce(from: gameManager.codeSnippet)
                    entity.addForce(force, relativeTo: nil)
                    HapticsManager.shared.play(.medium)
                    gameManager.advanceTutorial()
                } else {
                    handlePlaceBounceObject(location: location, in: arView)
                }
            case 4:
                if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    let force = CodeParser.parseForce(from: gameManager.codeSnippet)
                    entity.addForce(force, relativeTo: nil)
                    HapticsManager.shared.play(.medium)
                    gameManager.advanceTutorial()
                } else {
                    handlePlaceBounceObject(location: location, in: arView)
                    gameManager.advanceTutorial()
                }
            default:
                break
            }
        }
        
        // MARK: - Shooting Range (18-25) Tap
        
        func handleShootingLevelTap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                handlePlaceTarget(location: location, in: arView)
                gameManager.advanceTutorial()
            case 3, 4:
                handleShootProjectile(location: location, in: arView)
                gameManager.advanceTutorial()
            default:
                break
            }
        }
        
        // MARK: - Architecture (26-33) Tap
        
        func handleBuildingLevelTap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                handlePlaceStack(location: location, in: arView)
                gameManager.advanceTutorial()
            case 3:
                if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    handleShootProjectile(location: location, in: arView)
                } else {
                    handlePlaceStack(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            case 4:
                if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    handleShootProjectile(location: location, in: arView)
                } else {
                    handlePlaceStack(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            default:
                break
            }
        }
        
        // MARK: - Creative Studio (34-41) Tap
        
        func handleCreativeLevelTap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                handlePlaceScaledObject(location: location, in: arView)
                gameManager.advanceTutorial()
            case 3:
                if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    handleRepaintObject(entity: entity)
                } else {
                    handlePlaceScaledObject(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            case 4:
                handlePlaceScaledObject(location: location, in: arView)
                gameManager.advanceTutorial()
            default:
                break
            }
        }
        
        // MARK: - Master Challenges (42-49) Tap
        
        func handleChallengeLevelTap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Build or place depending on lesson
                let lesson = gameManager.currentLessonIndex
                if lesson == 46 { // Target Marathon
                    handlePlaceTarget(location: location, in: arView)
                } else if [43, 47, 48].contains(lesson) { // Demolition, Tower Defense, Grand
                    handlePlaceStack(location: location, in: arView)
                } else {
                    handlePlaceScaledObject(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            case 3:
                let lesson = gameManager.currentLessonIndex
                if [43, 46, 47, 49].contains(lesson) {
                    handleShootProjectile(location: location, in: arView)
                } else if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                    let force = CodeParser.parseForce(from: gameManager.codeSnippet)
                    entity.addForce(force, relativeTo: nil)
                    HapticsManager.shared.play(.medium)
                } else {
                    handlePlaceScaledObject(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            case 4:
                let lesson = gameManager.currentLessonIndex
                if [43, 47, 49].contains(lesson) {
                    if let entity = arView.entity(at: location) as? ModelEntity, entity.name == "UserObject" {
                        handleShootProjectile(location: location, in: arView)
                    } else {
                        handlePlaceStack(location: location, in: arView)
                    }
                } else {
                    handlePlaceScaledObject(location: location, in: arView)
                }
                gameManager.advanceTutorial()
            default:
                break
            }
        }
        
        // MARK: - Level 50: Free Build (Sandbox) Tap
        
        func handleLevel10Tap(step: Int, location: CGPoint, in arView: ARView) {
            switch step {
            case 0:
                gameManager.advanceTutorial()
            case 1:
                // Free build: tap object = physics, tap floor = place, tap air = shoot
                if let entity = arView.entity(at: location) as? ModelEntity,
                   entity.name == "UserObject" {
                    // Apply physics to existing object
                    handleApplyPhysics(location: location, in: arView)
                } else {
                    // Check if tapping floor or air
                    let hitFloor = hitTestFloor(location: location, in: arView)
                    if hitFloor {
                        handlePlaceScaledObject(location: location, in: arView)
                    } else {
                        handleShootProjectile(location: location, in: arView)
                    }
                }
                // Track placed objects for the challenge
                if gameManager.placedObjectCount >= 5 && !gameManager.isTaskCompleted {
                    gameManager.completeTask()
                }
            default:
                break
            }
        }
        
        // MARK: - Helper: Hit Test Floor
        
        func hitTestFloor(location: CGPoint, in arView: ARView) -> Bool {
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                return hits.contains(where: { $0.entity.name == "VirtualFloor" })
            } else {
                let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .horizontal)
                return !results.isEmpty
            }
        }
        
        // MARK: - Place Scaled Object (Level 5)
        
        func handlePlaceScaledObject(location: CGPoint, in arView: ARView) {
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .existingPlaneInfinite, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        worldTransform = result.worldTransform
                        break
                    }
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            let shape = CodeParser.parseShape(from: gameManager.codeSnippet)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            let isMetallic = CodeParser.parseMetallic(from: gameManager.codeSnippet)
            let scale = CodeParser.parseScale(from: gameManager.codeSnippet)
            var mat = SimpleMaterial(color: color, isMetallic: isMetallic)
            mat.roughness = isMetallic ? 0.15 : 0.7
            
            let model: ModelEntity
            
            switch shape {
            case "sphere":
                let radius: Float = 0.08
                model = ModelEntity(mesh: MeshResource.generateSphere(radius: radius), materials: [mat])
                model.position.y = radius
            case "cylinder":
                // Approximate cylinder with a rounded box (generateCylinder requires iOS 18+)
                model = ModelEntity(mesh: .generateBox(size: [0.12, 0.2, 0.12], cornerRadius: 0.06), materials: [mat])
                model.position.y = 0.1
            case "cone":
                // Approximate cone with a tapered box (generateCone requires iOS 18+)
                model = ModelEntity(mesh: .generateBox(size: [0.16, 0.2, 0.16], cornerRadius: 0.06), materials: [mat])
                model.scale = SIMD3<Float>(1.0, 1.0, 0.5)
                model.position.y = 0.1
            default:
                let w: Float = 0.15, h: Float = 0.05, l: Float = 0.15
                model = ModelEntity(mesh: .generateBox(size: [w, h, l], cornerRadius: 0.02), materials: [mat])
                model.position.y = h / 2
            }
            
            model.name = "UserObject"
            model.scale = scale
            model.generateCollisionShapes(recursive: true)
            anchor.addChild(model)
            
            gameManager.placedObjectCount += 1
            HapticsManager.shared.play(.medium)
            
            // Advance tutorial for Level 5
            if gameManager.currentLessonIndex == 5 {
                if gameManager.tutorialStep == 1 || gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
            // Level 7: Shape Factory
            if gameManager.currentLessonIndex == 7 {
                if gameManager.tutorialStep == 1 || gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 || gameManager.tutorialStep == 5 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Repaint Object (Level 6)
        
        func handleRepaintObject(entity: ModelEntity) {
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            let isMetallic = CodeParser.parseMetallic(from: gameManager.codeSnippet)
            var mat = SimpleMaterial(color: color, isMetallic: isMetallic)
            mat.roughness = isMetallic ? 0.15 : 0.7
            
            // Flash white first
            entity.model?.materials = [SimpleMaterial(color: .white, isMetallic: true)]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                entity.model?.materials = [mat]
            }
            
            HapticsManager.shared.play(.light)
            
            if gameManager.currentLessonIndex == 6 {
                if gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Place Shape Object (Level 7)
        
        func handlePlaceShapeObject(location: CGPoint, in arView: ARView) {
            // Reuses handlePlaceScaledObject which already handles all shapes
            handlePlaceScaledObject(location: location, in: arView)
        }
        
        // MARK: - Place Target (Level 8)
        
        func handlePlaceTarget(location: CGPoint, in arView: ARView) {
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .existingPlaneInfinite, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        worldTransform = result.worldTransform
                        break
                    }
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            // Create target using flat boxes (generateCylinder requires iOS 18+)
            let outerRing = ModelEntity(
                mesh: .generateBox(size: [0.3, 0.01, 0.3], cornerRadius: 0.005),
                materials: [SimpleMaterial(color: .red, isMetallic: true)]
            )
            outerRing.position.y = 0.005
            outerRing.name = "Target"
            outerRing.generateCollisionShapes(recursive: true)
            
            let innerRing = ModelEntity(
                mesh: .generateBox(size: [0.16, 0.015, 0.16], cornerRadius: 0.005),
                materials: [SimpleMaterial(color: .white, isMetallic: true)]
            )
            innerRing.position.y = 0.0075
            innerRing.name = "Target"
            
            let bullseye = ModelEntity(
                mesh: .generateBox(size: [0.06, 0.02, 0.06], cornerRadius: 0.005),
                materials: [SimpleMaterial(color: .red, isMetallic: true)]
            )
            bullseye.position.y = 0.01
            bullseye.name = "Target"
            bullseye.generateCollisionShapes(recursive: true)
            
            anchor.addChild(outerRing)
            anchor.addChild(innerRing)
            anchor.addChild(bullseye)
            
            HapticsManager.shared.play(.medium)
            
            if gameManager.currentLessonIndex == 8 && gameManager.tutorialStep == 1 {
                gameManager.advanceTutorial()
            }
        }
        
        // MARK: - Shoot Projectile (Level 8, 9, 10)
        
        func handleShootProjectile(location: CGPoint, in arView: ARView) {
            let speed = CodeParser.parseSpeed(from: gameManager.codeSnippet)
            let radius = CodeParser.parseRadius(from: gameManager.codeSnippet, defaultValue: 0.03)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            let mass = CodeParser.parseMass(from: gameManager.codeSnippet, defaultMass: 0.5)
            
            // Create projectile
            var mat = SimpleMaterial(color: color, isMetallic: true)
            mat.roughness = 0.1
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: radius),
                materials: [mat]
            )
            sphere.name = "Projectile"
            sphere.generateCollisionShapes(recursive: true)
            
            // Physics
            let physics = PhysicsBodyComponent(
                massProperties: .init(mass: mass),
                material: .default,
                mode: .dynamic
            )
            sphere.components[PhysicsBodyComponent.self] = physics
            
            // Position at camera
            let cameraPos: SIMD3<Float>
            let direction: SIMD3<Float>
            
            if gameManager.isSimulationMode {
                // Use virtual camera position
                if let rig = cameraRig {
                    cameraPos = rig.position(relativeTo: nil) + SIMD3<Float>(0, 0.2, 0)
                    let rigTransform = rig.transformMatrix(relativeTo: nil)
                    direction = normalize(SIMD3<Float>(-rigTransform.columns.2.x, -rigTransform.columns.2.y, -rigTransform.columns.2.z))
                } else {
                    return
                }
            } else {
                // Use AR camera
                guard let frame = arView.session.currentFrame else { return }
                let camTransform = frame.camera.transform
                cameraPos = SIMD3<Float>(camTransform.columns.3.x, camTransform.columns.3.y, camTransform.columns.3.z)
                direction = normalize(SIMD3<Float>(-camTransform.columns.2.x, -camTransform.columns.2.y, -camTransform.columns.2.z))
            }
            
            let anchor = AnchorEntity(world: cameraPos)
            anchor.addChild(sphere)
            arView.scene.addAnchor(anchor)
            
            // Apply impulse in camera direction
            let impulse = direction * speed
            sphere.applyLinearImpulse(impulse, relativeTo: nil)
            
            HapticsManager.shared.play(.heavy)
            
            // Auto-remove projectile after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                anchor.removeFromParent()
            }
            
            // Advance tutorial
            let lessonIdx = gameManager.currentLessonIndex
            if lessonIdx == 8 {
                if gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
            if lessonIdx == 9 {
                if gameManager.tutorialStep == 3 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Place Stack (Level 9)
        
        func handlePlaceStack(location: CGPoint, in arView: ARView) {
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                let queries: [ARRaycastQuery.Target] = [.existingPlaneGeometry, .existingPlaneInfinite, .estimatedPlane]
                for target in queries {
                    if let result = arView.raycast(from: location, allowing: target, alignment: .horizontal).first {
                        worldTransform = result.worldTransform
                        break
                    }
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            let count = CodeParser.parseCount(from: gameManager.codeSnippet)
            let mass = CodeParser.parseMass(from: gameManager.codeSnippet, defaultMass: 0.5)
            let restitution = CodeParser.parseRestitution(from: gameManager.codeSnippet, defaultRestitution: 0.2)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            
            let blockSize: Float = 0.08
            let gap: Float = 0.002
            
            let physicsMaterial = PhysicsMaterialResource.generate(
                staticFriction: 0.8,
                dynamicFriction: 0.8,
                restitution: restitution
            )
            
            // Stagger colors for visual variety
            let colors: [UIColor] = [color, .orange, .yellow, .cyan, .green, .purple, .red, .magenta, .white, .blue]
            
            for i in 0..<count {
                let blockColor = colors[i % colors.count]
                var mat = SimpleMaterial(color: blockColor, isMetallic: true)
                mat.roughness = 0.2
                let block = ModelEntity(
                    mesh: .generateBox(size: [blockSize, blockSize, blockSize], cornerRadius: 0.005),
                    materials: [mat]
                )
                block.name = "UserObject"
                block.position.y = Float(i) * (blockSize + gap) + blockSize / 2
                block.generateCollisionShapes(recursive: true)
                
                let physics = PhysicsBodyComponent(
                    massProperties: .init(mass: mass),
                    material: physicsMaterial,
                    mode: .dynamic
                )
                block.components[PhysicsBodyComponent.self] = physics
                
                anchor.addChild(block)
            }
            
            gameManager.placedObjectCount += count
            HapticsManager.shared.play(.heavy)
            
            if gameManager.currentLessonIndex == 9 {
                if gameManager.tutorialStep == 1 || gameManager.tutorialStep == 4 {
                    gameManager.advanceTutorial()
                }
            }
        }
        
        // MARK: - Apply Code (Level 1 Step 6+)
        
        func handleCodeApply(location: CGPoint, in arView: ARView) {
            if let entity = arView.entity(at: location) as? ModelEntity,
               entity.name == "UserObject" {
                let color = CodeParser.parseColor(from: gameManager.codeSnippet)
                let mat = SimpleMaterial(color: color, isMetallic: true)
                entity.model?.materials = [mat]
                
                // Bounce animation
                let originalTransform = entity.transform
                var bounced = originalTransform
                bounced.scale = [1.3, 1.3, 1.3]
                entity.move(to: bounced, relativeTo: entity.parent, duration: 0.15, timingFunction: .easeInOut)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    entity.move(to: originalTransform, relativeTo: entity.parent, duration: 0.15, timingFunction: .easeInOut)
                }
                
                HapticsManager.shared.play(.light)
                
                if gameManager.tutorialStep == 6 {
                    gameManager.advanceTutorial()
                }
            }
        }
    }
}
