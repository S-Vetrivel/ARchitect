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
            
            context.coordinator.setupGestures()
            context.coordinator.setupSubscriptions()
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gameManager: gameManager)
    }
    
    // MARK: - Coordinator
    
    @MainActor
    class Coordinator: NSObject, ARSessionDelegate {
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
        
        init(gameManager: GameManager) {
            self.gameManager = gameManager
        }
        
        // MARK: - AR Session Delegate
        
        nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
            Task { @MainActor in
                // Only process for AR mode tutorial steps
                guard !gameManager.isSimulationMode else { return }
                
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
            
            // Only allow looking around from step 2 onward
            guard gameManager.tutorialStep >= 2 else { return }
            
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
            guard gameManager.tutorialStep >= 4 else { return }
            
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
            guard gameManager.tutorialStep >= 4 else { return }
            
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
            guard gameManager.tutorialStep >= 4 else { return }
            
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
            
            // Only allow walking from step 3 onward
            guard gameManager.tutorialStep >= 3 else { return }
            
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
            
            let step = gameManager.tutorialStep
            
            switch step {
            case 1:
                // Step 1: Just tap to advance
                gameManager.advanceTutorial()
                
            case 5:
                // Step 5: Place an object
                handlePlaceObject(location: location, in: arView)
                
            case 6:
                // Step 6: Tap an object to apply code changes
                handleCodeApply(location: location, in: arView)
                
            default:
                // For other steps, tapping can also place objects if past step 5
                if step > 5 {
                    if let entity = arView.entity(at: location) as? ModelEntity,
                       entity.name != "VirtualFloor" && entity.name != "TutorialMarker" {
                        handleCodeApply(location: location, in: arView)
                    } else {
                        handlePlaceObject(location: location, in: arView)
                    }
                }
                break
            }
        }
        
        // MARK: - Place Object (Step 5+)
        
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
                // Try to find a solid existing plane first for realism
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
            
            let width = CodeParser.parseWidth(from: gameManager.codeSnippet, defaultWidth: 0.15)
            let height = CodeParser.parseHeight(from: gameManager.codeSnippet, defaultHeight: 0.05)
            let length = CodeParser.parseDepth(from: gameManager.codeSnippet, defaultDepth: 0.15)
            let chamfer = CodeParser.parseChamfer(from: gameManager.codeSnippet, defaultChamfer: 0.02)
            
            let mesh = MeshResource.generateBox(size: [width, height, length], cornerRadius: chamfer)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            var mat = SimpleMaterial(color: color, isMetallic: true)
            mat.roughness = 0.15
            let model = ModelEntity(mesh: mesh, materials: [mat])
            model.name = "UserObject"
            model.position.y = height / 2
            model.generateCollisionShapes(recursive: true)
            anchor.addChild(model)
            
            HapticsManager.shared.play(.medium)
            
            // Tutorial: Complete Step 5
            if gameManager.tutorialStep == 5 {
                gameManager.advanceTutorial()
            }
        }
        
        // MARK: - Apply Code (Step 6+)
        
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
                
                // Tutorial: Complete Step 6
                if gameManager.tutorialStep == 6 {
                    gameManager.advanceTutorial()
                }
            }
        }
    }
}
