import Foundation

struct Lesson: Identifiable {
    let id: Int
    let title: String
    let instruction: String
    let conceptExplanation: String // New field for educational content
    let codeSnippet: String
    let challenges: [Challenge]
}

@MainActor
class LessonManager {
    static let shared = LessonManager()
    
    let lessons: [Lesson] = [
        Lesson(
            id: 1,
            title: "1. Foundations",
            instruction: "Find a horizontal surface (floor/table) and TAP to place an Anchor.",
            conceptExplanation: """
            **Anchors & Planes**
            
            Global tracking uses the camera to understand the world.
            
            - **Plane Detection**: Determines where the floor or table is.
            - **Anchor**: A coordinate point (X, Y, Z) that stays fixed in the real world.
            - **Entity**: The 3D object we attach to the anchor.
            """,
            codeSnippet: """
            // 1. Detect Plane
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            
            // 2. Add Anchor & Object
            // Try changing these values!
            // width: 0.15, height: 0.05, chamfer: 0.02
            // color: .blue
            
            let anchor = AnchorEntity(world: transform)
            arView.scene.addAnchor(anchor)
            """,
            challenges: [
                Challenge(id: "L1_C1", description: "Place 3 Anchors", targetCount: 3, xpReward: 30)
            ]
        ),
        Lesson(
            id: 2,
            title: "2. Gestures & Materials",
            instruction: "TAP the blue box to change its material to Red.",
            conceptExplanation: """
            **Materials & Interactivity**
            
            - **Materials**: Define how surface looks (Color, Metallic, Roughness).
            - **Raycasting**: Clicking on 3D objects.
            """,
            codeSnippet: """
            // 1. Raycast to find Entity
            let entity = arView.entity(at: tapLocation)
            
            // 2. Change Material
            var mat = SimpleMaterial(color: .red, isMetallic: true)
            entity.model?.materials = [mat]
            """,
            challenges: [
                Challenge(id: "L2_C1", description: "Change material 5 times", targetCount: 5, xpReward: 40)
            ]
        ),
        Lesson(
            id: 3,
            title: "3. Physics & Gravity",
            instruction: "TAP anywhere to spawn a cube carrying physics!",
            conceptExplanation: """
            **Physics Simulation**
            
            - **PhysicsBody**: Gives mass and gravity.
            - **CollisionComponent**: Solid boundaries.
            """,
            codeSnippet: """
            // 1. Add Physics Component
            model.components[PhysicsBodyComponent.self] = 
                PhysicsBodyComponent(massProperties: .default, 
                                   material: .default, 
                                   mode: .dynamic)
            
            // 2. Add Collision
            model.components[CollisionComponent.self] = 
                CollisionComponent(shapes: [.generateBox(size: ...)])
            """,
            challenges: [
                Challenge(id: "L3_C1", description: "Spawn 10 Cubes", targetCount: 10, xpReward: 50)
            ]
        ),
        Lesson(
            id: 4,
            title: "4. Forces",
            instruction: "TAP to shoot a ball and knock over the cubes.",
            conceptExplanation: """
            **Forces & Impulses**
            
            - **Impulse**: A sudden force (like a kick).
            - **Vector**: Direction + Magnitude.
            """,
            codeSnippet: """
            // 1. Create Force Vector
            let force = SIMD3<Float>(0, 0, -10)
            
            // 2. Apply Impulse
            projectile.applyLinearImpulse(force, relativeTo: nil)
            """,
            challenges: [
                Challenge(id: "L4_C1", description: "Knock over 5 towers", targetCount: 5, xpReward: 60)
            ]
        ),
        Lesson(
            id: 5,
            title: "5. UI & Text",
            instruction: "TAP an object to attach a 3D Label.",
            conceptExplanation: """
            **3D User Interface**
            
            - **MeshResource.generateText**: Creates 3D geometry from strings.
            - **Billboard**: Text that always faces the user.
            """,
            codeSnippet: """
            // 1. Create Text Mesh
            let mesh = MeshResource.generateText(
                "ARchitect",
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.1)
            )
            """,
            challenges: [
                Challenge(id: "L5_C1", description: "Place 3 Labels", targetCount: 3, xpReward: 50)
            ]
        )
    ]
    
    func getLesson(id: Int) -> Lesson? {
        return lessons.first { $0.id == id }
    }
}
