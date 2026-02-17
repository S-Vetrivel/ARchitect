import SwiftUI
import RealityKit
import ARKit
import Combine
import UIKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var gameManager = GameManager.shared
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: gameManager.isSimulationMode ? .nonAR : .ar, automaticallyConfigureSession: false)
        
        context.coordinator.arView = arView
        
        if gameManager.isSimulationMode {
            // Virtual Studio Mode
            context.coordinator.setupVirtualEnvironment(in: arView)
        } else {
            // AR Mode
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            
            // Coaching Overlay
            let coachingOverlay = ARCoachingOverlayView()
            coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            coachingOverlay.session = arView.session
            coachingOverlay.goal = .horizontalPlane
            arView.addSubview(coachingOverlay)
        }
        
        context.coordinator.setupGestures()
        context.coordinator.setupSubscriptions()
        
        return arView
    }
    
    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        uiView.session.pause()
        coordinator.arView = nil
        coordinator.subscriptions.removeAll()
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        // Handle updates based on active lesson
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gameManager: gameManager)
    }
    
    @MainActor
    class Coordinator: NSObject {
        var arView: ARView?
        var gameManager: GameManager
        var subscriptions: Set<AnyCancellable> = []
        
        // Virtual Studio Ops
        var cameraRig: Entity?       // The "player body" — moves through the world
        var virtualCamera: PerspectiveCamera?  // The "head" — rotates for look
        var cameraPitch: Float = -0.3 // Current vertical look angle (radians)
        
        init(gameManager: GameManager) {
            self.gameManager = gameManager
        }
        
        func setupVirtualEnvironment(in arView: ARView) {
            // Dark Studio Background
            arView.environment.background = .color(.black)
            
            // 1. Virtual Floor (Large Grid)
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
            
            // 2. Lighting
            let directionalLight = DirectionalLight()
            directionalLight.light.color = .white
            directionalLight.light.intensity = 1000
            directionalLight.look(at: .zero, from: [5, 5, 5], relativeTo: nil)
            anchor.addChild(directionalLight)
            
            // 3. Camera Rig = "Player" that walks around
            //    The rig handles position (walking) and yaw (horizontal look).
            //    The camera (child) handles pitch (vertical look) and zoom (FOV).
            let rig = Entity()
            rig.position = [0, 0, 3] // Start 3m back from origin
            anchor.addChild(rig)
            cameraRig = rig
            
            let camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 60
            camera.position = [0, 1.5, 0] // Eye height, directly on the rig
            // Look slightly downward toward the floor/origin
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            rig.addChild(camera)
            virtualCamera = camera
            
            arView.cameraMode = .nonAR
        }
        
        func setupGestures() {
            guard let arView = arView else { return }
            
            // Tap for lesson interactions (click on Mac)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
            
            // Pan/Drag = Look Around (swipe on touch, drag on mouse)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.allowedScrollTypesMask = [] // Don't capture scroll wheel events
            arView.addGestureRecognizer(panGesture)
            
            // Pinch = Zoom (touch pinch OR trackpad pinch)
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            arView.addGestureRecognizer(pinchGesture)
            
            // Mouse Scroll Wheel = Zoom (separate pan gesture for scroll events)
            let scrollGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScroll(_:)))
            scrollGesture.allowedScrollTypesMask = [.continuous, .discrete]
            scrollGesture.maximumNumberOfTouches = 0 // Only respond to indirect (mouse/trackpad scroll)
            arView.addGestureRecognizer(scrollGesture)
        }
        
        // MARK: - Look Around (Pan/Swipe/Drag)
        @objc func handlePan(_ sender: UIPanGestureRecognizer) {
            guard gameManager.isSimulationMode, let rig = cameraRig, let camera = virtualCamera else { return }
            let translation = sender.translation(in: sender.view)
            
            // Drag right → Look right (positive yaw)
            let yawDelta = Float(translation.x) * 0.005
            rig.orientation *= simd_quatf(angle: yawDelta, axis: [0, 1, 0])
            
            // Drag up → Look up (negative pitch)
            let pitchDelta = Float(translation.y) * 0.005
            cameraPitch -= pitchDelta
            cameraPitch = max(-.pi * 0.44, min(cameraPitch, .pi * 0.44))
            camera.orientation = simd_quatf(angle: cameraPitch, axis: [1, 0, 0])
            
            sender.setTranslation(.zero, in: sender.view)
        }
        
        // MARK: - Zoom (Pinch / Trackpad)
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
        
        // MARK: - Zoom (Mouse Scroll Wheel)
        @objc func handleScroll(_ sender: UIPanGestureRecognizer) {
            guard gameManager.isSimulationMode, let camera = virtualCamera else { return }
            
            let scrollY = Float(sender.translation(in: sender.view).y)
            
            // Scroll up = zoom in (decrease FOV), scroll down = zoom out
            var newFOV = camera.camera.fieldOfViewInDegrees + scrollY * 0.1
            newFOV = max(20, min(newFOV, 100))
            camera.camera.fieldOfViewInDegrees = newFOV
            
            sender.setTranslation(.zero, in: sender.view)
        }
        
        func setupSubscriptions() {
            guard let arView = arView else { return }
            
            // Update loop — process joystick input every frame
            arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.updatePlanes()
                self?.updateMovement(deltaTime: event.deltaTime)
            }.store(in: &subscriptions)
        }
        
        // MARK: - Walk / Strafe (Joystick)
        private func updateMovement(deltaTime: Double) {
            guard gameManager.isSimulationMode, let rig = cameraRig else { return }
            
            let input = gameManager.joystickInput
            if input == .zero { return }
            
            let speed: Float = 3.0 * Float(deltaTime) // 3 meters per second
            
            // Get the rig's forward and right directions (on the XZ plane)
            let rigTransform = rig.transformMatrix(relativeTo: nil)
            let forward = SIMD3<Float>(-rigTransform.columns.2.x, 0, -rigTransform.columns.2.z)
            let right = SIMD3<Float>(rigTransform.columns.0.x, 0, rigTransform.columns.0.z)
            
            // Y input → Walk forward/backward
            // X input → Strafe left/right
            let movement = (forward * input.y + right * input.x) * speed
            rig.position += movement
        }
        
        private func updatePlanes() {
            // Placeholder for future plane visualization
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            let location = sender.location(in: arView)
            
            // Logic will depend on active lesson
            switch gameManager.currentLessonIndex {
            case 1: handleLesson1Tap(location: location, in: arView)
            case 2: handleLesson2Tap(location: location, in: arView)
            case 3: handleLesson3Tap(location: location, in: arView)
            case 4: handleLesson4Tap(location: location, in: arView)
            case 5: handleLesson5Tap(location: location, in: arView)
            default: break
            }
        }
        
        func handleLesson1Tap(location: CGPoint, in arView: ARView) {
            // Lesson 1: Place an Anchor
            var worldTransform: simd_float4x4?
            
            if gameManager.isSimulationMode {
                // Raycast against Virtual Floor
                let hits = arView.hitTest(location)
                if let hit = hits.first(where: { $0.entity.name == "VirtualFloor" }) {
                    // Create a transform at hit position, flat on floor
                    let position = hit.position
                    worldTransform = simd_float4x4(
                        [1, 0, 0, 0],
                        [0, 1, 0, 0],
                        [0, 0, 1, 0],
                        [position.x, position.y, position.z, 1]
                    )
                }
            } else {
                // Raycast against Real Planes
                if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                    worldTransform = result.worldTransform
                }
            }
            
            guard let transform = worldTransform else { return }
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            
            // Blue Box with "Wireframe" feel or glow
            let width = CodeParser.parseWidth(from: gameManager.codeSnippet, defaultWidth: 0.15)
            let height = CodeParser.parseHeight(from: gameManager.codeSnippet, defaultHeight: 0.05)
            let length = CodeParser.parseDepth(from: gameManager.codeSnippet, defaultDepth: 0.15)
            let chamfer = CodeParser.parseChamfer(from: gameManager.codeSnippet, defaultChamfer: 0.01)
            
            let mesh = MeshResource.generateBox(size: [width, height, length], cornerRadius: chamfer)
            let color = CodeParser.parseColor(from: gameManager.codeSnippet)
            var mat = SimpleMaterial(color: color, isMetallic: true)
            mat.roughness = 0.15
            let model = ModelEntity(mesh: mesh, materials: [mat])
            model.position.y = height / 2
            
            // Add Collision for future lessons
            model.generateCollisionShapes(recursive: true)
            
            anchor.addChild(model)
            
            // Task Complete
            gameManager.completeTask()
        }
        
        func handleLesson2Tap(location: CGPoint, in arView: ARView) {
            // Lesson 2: Tap entity to change material
            if let entity = arView.entity(at: location) as? ModelEntity {
                // Change to Architect Red (Blueprint Red)
                let color = CodeParser.parseColor(from: gameManager.codeSnippet)
                let mat = SimpleMaterial(color: color, isMetallic: true)
                entity.model?.materials = [mat]
                
                // Techy bounce animation
                let transform = entity.transform
                var newTransform = transform
                newTransform.scale = [1.2, 1.2, 1.2]
                entity.move(to: newTransform, relativeTo: entity.parent, duration: 0.2, timingFunction: .easeInOut)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    entity.move(to: transform, relativeTo: entity.parent, duration: 0.2, timingFunction: .easeInOut)
                }
                
                gameManager.completeTask()
            }
        }
        
        func handleLesson3Tap(location: CGPoint, in arView: ARView) {
            // Lesson 3: Spawn Physics Cube
            let cameraTransform: Transform
            if gameManager.isSimulationMode, let cam = virtualCamera {
                 cameraTransform = Transform(matrix: cam.transformMatrix(relativeTo: nil))
            } else {
                 cameraTransform = arView.cameraTransform
            }
            
            let size = CodeParser.parseSize(from: gameManager.codeSnippet, defaultSize: 0.1)
            let mesh = MeshResource.generateBox(size: size)
            let mat = SimpleMaterial(color: .green, isMetallic: false)
            let model = ModelEntity(mesh: mesh, materials: [mat])
            
            // Position
            var translation = cameraTransform.translation
            let forward = cameraTransform.matrix.columns.2
            translation += SIMD3<Float>(-forward.x, -forward.y, -forward.z) * 0.5
            translation.y += 0.5
            model.position = translation
            
            // Physics
            model.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
            model.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [size, size, size])])
            
            let anchor = AnchorEntity(world: .zero)
            arView.scene.addAnchor(anchor)
            anchor.addChild(model)
            
            gameManager.completeTask()
        }
        
        func handleLesson4Tap(location: CGPoint, in arView: ARView) {
            // Lesson 4: Shoot Ball (Impulse)
            let cameraTransform: Transform
            if gameManager.isSimulationMode, let cam = virtualCamera {
                 cameraTransform = Transform(matrix: cam.transformMatrix(relativeTo: nil))
            } else {
                 cameraTransform = arView.cameraTransform
            }
            
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let mat = SimpleMaterial(color: .yellow, isMetallic: true)
            let projectile = ModelEntity(mesh: mesh, materials: [mat])
            
            projectile.position = cameraTransform.translation
            
            // Physics
            projectile.components[PhysicsBodyComponent.self] = PhysicsBodyComponent(massProperties: .default, material: PhysicsMaterialResource.generate(friction: 0.0, restitution: 0.5), mode: .dynamic)
            projectile.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateSphere(radius: 0.05)])
            
            let anchor = AnchorEntity(world: .zero)
            arView.scene.addAnchor(anchor)
            anchor.addChild(projectile)
            
            // Force
            let forward = cameraTransform.matrix.columns.2
            // let force = SIMD3<Float>(-forward.x, -forward.y, -forward.z) * 5.0
            
            // Use parsed force Z component as magnitude multiplier
            let parsedForce = CodeParser.parseForce(from: gameManager.codeSnippet)
            let magnitude = abs(parsedForce.z)
            let force = SIMD3<Float>(-forward.x, -forward.y, -forward.z) * magnitude
            
            projectile.applyLinearImpulse(force, relativeTo: nil)
            
            gameManager.completeTask()
        }
        
        func handleLesson5Tap(location: CGPoint, in arView: ARView) {
            // Lesson 5: Place 3D Text
             if let entity = arView.entity(at: location) as? ModelEntity {
                 let mesh = MeshResource.generateText(
                    "ARchitect",
                    extrusionDepth: 0.01,
                    font: .systemFont(ofSize: 0.05, weight: .bold),
                    containerFrame: .zero,
                    alignment: .center,
                    lineBreakMode: .byCharWrapping
                 )
                 
                 let mat = SimpleMaterial(color: .white, isMetallic: false)
                 let textModel = ModelEntity(mesh: mesh, materials: [mat])
                 
                 textModel.position = [0, 0.15, 0] // Above object
                 textModel.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0])
                 
                 entity.addChild(textModel)
                 
                 gameManager.completeTask()
             }
        }
    }
}
