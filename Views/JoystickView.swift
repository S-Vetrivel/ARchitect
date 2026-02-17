
import SwiftUI

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
