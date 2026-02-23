import RealityKit
import SwiftUI

/// Component to define an object's orbital characteristics.
/// The system will use this data to update the entity's position every frame.
struct OrbitComponent: Component, Codable {
    /// The radius of the orbit in meters.
    var radius: Float = 0.5
    
    /// The shifting speed of the orbit in radians per second.
    var speed: Float = 1.0
    
    /// The center point of the orbit (relative to parent).
    /// Default is [0,0,0], meaning it orbits the parent's origin.
    var center: SIMD3<Float> = .zero
    
    /// The current angle in the orbit (0 to 2pi).
    var currentAngle: Float = 0.0
    
    // Axis of orbit mainly being on XZ plane (Y-up), but could be tilted.
    // For simplicity, we'll stick to flat orbits first.
}

/// Component to define an object's self-rotation (day/night cycle).
struct RotationComponent: Component, Codable {
    /// Rotation speed in radians per second around the Y axis.
    var speed: Float = 1.0
}
