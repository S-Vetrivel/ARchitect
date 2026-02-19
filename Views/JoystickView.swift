
import SwiftUI

// MARK: - Floating Joystick Container
// Place this as a full-screen overlay. It detects a long-press,
// spawns a joystick at that location, then tracks drag for movement.

struct JoystickVisuals: View {
    @ObservedObject var gameManager = GameManager.shared
    
    let outerRadius: CGFloat = 60
    let innerRadius: CGFloat = 25
    
    var body: some View {
        ZStack {
            // Only show if active
             if gameManager.isJoystickActive {
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                        .frame(width: outerRadius * 2, height: outerRadius * 2)
                    
                    // Inner Knob
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.9), Color.white.opacity(0.5)],
                                center: .center,
                                startRadius: 0,
                                endRadius: innerRadius
                            )
                        )
                        .frame(width: innerRadius * 2, height: innerRadius * 2)
                        .shadow(color: .white.opacity(0.3), radius: 6)
                        .offset(
                            x: CGFloat(gameManager.joystickInput.x) * (outerRadius - innerRadius),
                            y: CGFloat(-gameManager.joystickInput.y) * (outerRadius - innerRadius) // Invert Y back for visual offset
                        )
                }
                .position(gameManager.joystickOrigin)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .allowsHitTesting(false) // CRITICAL: Never block touches
    }
}

// MARK: - Legacy JoystickView (kept for reference, no longer used in layouts)
struct JoystickView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var position: CGSize = .zero
    
    let outerRadius: CGFloat = 60
    let innerRadius: CGFloat = 25
    
    var body: some View {
        ZStack {
            // Outer Ring
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .background(Circle().fill(Color.black.opacity(0.4)))
                .frame(width: outerRadius * 2, height: outerRadius * 2)
            
            // Inner Knob
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: innerRadius * 2, height: innerRadius * 2)
                .offset(position)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let vector = CGVector(dx: value.translation.width, dy: value.translation.height)
                            let distance = sqrt(vector.dx * vector.dx + vector.dy * vector.dy)
                            let maxDistance = outerRadius - innerRadius
                            
                            var clampedPosition = value.translation
                            if distance > maxDistance {
                                let scale = maxDistance / distance
                                clampedPosition = CGSize(width: vector.dx * scale, height: vector.dy * scale)
                            }
                            
                            self.position = clampedPosition
                            
                            // Normalize to -1...1
                            let x = Float(clampedPosition.width / maxDistance)
                            let y = Float(clampedPosition.height / maxDistance)
                            
                            // Update Manager (invert Y so up is positive forward)
                            gameManager.joystickInput = SIMD2<Float>(x, -y)
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                self.position = .zero
                                gameManager.joystickInput = .zero
                            }
                        }
                )
        }
    }
}
