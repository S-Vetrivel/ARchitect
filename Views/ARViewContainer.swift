import SwiftUI
import RealityKit
import ARKit
import Combine
import UIKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var gameManager = GameManager.shared
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        // Start AR Session
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
        
        // Debug Options for "Architect" feel (Show Anchors/Planes)
        arView.debugOptions = [.showAnchorOrigins, .showPhysics]
        
        context.coordinator.arView = arView
        context.coordinator.setupGestures()
        context.coordinator.setupSubscriptions()
        
        return arView
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
        
        init(gameManager: GameManager) {
            self.gameManager = gameManager
        }
        
        func setupGestures() {
            guard let arView = arView else { return }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
        }
        
        func setupSubscriptions() {
            guard let arView = arView else { return }
            
            // Listen for Scene events (Update)
            arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                self?.updatePlanes()
            }.store(in: &subscriptions)
        }
        
        private func updatePlanes() {
            // Placeholder: In a full app, we would add custom Grid materials to detected planes here.
            // For now, debugOptions already provides the "Architect" feel.
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
            // Lesson 1: Place an Anchor on a plane
            guard let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first else { return }
            
            let anchor = AnchorEntity(world: result.worldTransform)
            arView.scene.addAnchor(anchor)
            
            // Blue Box with "Wireframe" feel or glow
            let mesh = MeshResource.generateBox(size: 0.1)
            var mat = SimpleMaterial(color: .cyan, isMetallic: true)
            mat.roughness = 0.2
            let model = ModelEntity(mesh: mesh, materials: [mat])
            model.position.y = 0.05
            
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
                let mat = SimpleMaterial(color: .red, isMetallic: true)
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
            // Lesson 3: Spaawn Physics Cube
            let cameraTransform = arView.cameraTransform
            
            let mesh = MeshResource.generateBox(size: 0.1)
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
            model.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [0.1, 0.1, 0.1])])
            
            let anchor = AnchorEntity(world: .zero)
            arView.scene.addAnchor(anchor)
            anchor.addChild(model)
            
            gameManager.completeTask()
        }
        
        func handleLesson4Tap(location: CGPoint, in arView: ARView) {
            // Lesson 4: Shoot Ball (Impulse)
            let cameraTransform = arView.cameraTransform
            
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
            let force = SIMD3<Float>(-forward.x, -forward.y, -forward.z) * 5.0
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
