import Foundation

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let codeSnippet: String
}

@MainActor
class LessonManager {
    static let shared = LessonManager()
    
    let lessons: [Lesson] = [
        Lesson(
            id: 1,
            title: "1. Foundations",
            instruction: "Find a horizontal surface and TAP to place an Anchor.",
            codeSnippet: """
            // 1. Detect Plane
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            
            // 2. Add Anchor
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            """
        ),
        Lesson(
            id: 2,
            title: "2. Gestures & Materials",
            instruction: "TAP the blue box to change its material to Red.",
            codeSnippet: """
            // 1. Raycast to find Entity
            let entity = arView.entity(at: tapLocation)
            
            // 2. Change Material
            var mat = SimpleMaterial(color: .red, isMetallic: true)
            entity.model?.materials = [mat]
            """
        ),
        Lesson(
            id: 3,
            title: "3. Physics & Gravity",
            instruction: "TAP anywhere to spawn a cube carrying physics!",
            codeSnippet: """
            // 1. Add Physics Component
            model.components[PhysicsBodyComponent.self] = 
                PhysicsBodyComponent(massProperties: .default, 
                                   material: .default, 
                                   mode: .dynamic)
            
            // 2. Add Collision
            model.components[CollisionComponent.self] = 
                CollisionComponent(shapes: [.generateBox(size: ...)])
            """
        ),
        Lesson(
            id: 4,
            title: "4. Forces",
            instruction: "TAP to shoot a ball and knock over the cubes.",
            codeSnippet: """
            // 1. Create Force Vector
            let force = SIMD3<Float>(0, 0, -10)
            
            // 2. Apply Impulse
            projectile.applyLinearImpulse(force, relativeTo: nil)
            """
        ),
        Lesson(
            id: 5,
            title: "5. UI & Text",
            instruction: "TAP an object to attach a 3D Label.",
            codeSnippet: """
            // 1. Create Text Mesh
            let mesh = MeshResource.generateText(
                "ARchitect",
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.1)
            )
            """
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
