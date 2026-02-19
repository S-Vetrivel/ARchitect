import SwiftUI

struct TutorialOverlayView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var pulseAnimation = false
    @State private var arrowBounce = false
    
    let totalSteps = 7
    
    var stepData: (icon: String, title: String, instruction: String, hint: String) {
        let isSim = gameManager.isSimulationMode
        
        switch gameManager.tutorialStep {
        case 0:
            if isSim {
                 return ("hand.tap.fill", "Welcome (Simulation Mode)", "Welcome to ARchitect Academy!\nYou are in Simulation Mode.\nTap to begin.", "AR Mode available on iPad/iPhone")
            } else {
                 return ("hand.tap.fill", "Welcome!", "Welcome to ARchitect Academy!\nTap anywhere on the screen to begin.", "")
            }
        case 1:
            return ("hand.tap.fill", "Step 1: Get Started", "Tap anywhere on the 3D view to begin your journey.", "Just tap!")
        case 2:
            if isSim {
                return ("hand.draw.fill", "Step 2: Look Around", "Drag on the screen to rotate your view of the studio.", "Try dragging to look around")
            } else {
                 return ("hand.draw.fill", "Step 2: Look Around", "Move your device around to scan the room.", "Scan the area")
            }
        case 3:
            if isSim {
                return ("circle.circle.fill", "Step 3: Navigate", "Use the joystick (bottom-right) to fly the camera.\nMove toward the glowing marker!", "Use joystick to move")
            } else {
                return ("figure.walk", "Step 3: Walk", "Walk physically or use the joystick to move.\nMove toward the glowing marker!", "Walk forward or use joystick")
            }
        case 4:
            if isSim {
                return ("arrow.up.left.and.arrow.down.right", "Step 4: Zoom", "Pinch the screen to zoom in and out.\nOn Mac: use scroll wheel.", "Try zooming in and out")
            } else {
                return ("arrow.up.left.and.arrow.down.right", "Step 4: Move Closer", "Physically move your device closer to objects to see details.", "Move closer")
            }
        case 5:
            return ("cube.fill", "Step 5: Place Object", "Tap anywhere on the floor to place your first 3D object!", "Tap the floor!")
        case 6:
            return ("chevron.left.forwardslash.chevron.right", "Step 6: Edit Code", "Open the code editor and change\n`color: .blue` to `color: .red`\nThen tap your object to apply!", "Edit the code, then tap the object")
        case 7:
             if isSim {
                 return ("checkmark.circle.fill", "Tutorial Complete! 🎉", "You're ready to build!\n(Note: Switch to a device for full AR experience)", "")
             } else {
                 return ("checkmark.circle.fill", "Tutorial Complete! 🎉", "You're ready to build in AR!\nYou now know how to navigate, build, and code.", "")
             }
        default:
            return ("questionmark", "Unknown", "", "")
        }
    }
    
    var body: some View {
        VStack {
            // Coach Card
            if gameManager.tutorialStep < 7 {
                Color.clear // Transparent background that allows touches through? No, Color.clear BLOCKS touches by default unless contentShape is used or allowsHitTesting(false)
                    .allowsHitTesting(false) // Ensure the full screen background doesn't block touches
                VStack(spacing: 16) {
                    // Step indicator dots
                    HStack(spacing: 6) {
                        ForEach(1...totalSteps, id: \.self) { step in
                            Circle()
                                .fill(step <= gameManager.tutorialStep ? Color.studioAccent : Color.white.opacity(0.2))
                                .frame(width: step == gameManager.tutorialStep ? 10 : 6,
                                       height: step == gameManager.tutorialStep ? 10 : 6)
                                .animation(.spring(), value: gameManager.tutorialStep)
                        }
                    }
                    
                    // Icon
                    Image(systemName: stepData.icon)
                        .font(.system(size: 36))
                        .foregroundColor(.studioAccent)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    // Title
                    Text(stepData.title)
                        .font(.studioHeadline())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Instruction
                    Text(stepData.instruction)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                    
                    // Hint
                    if !stepData.hint.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(.studioWarning)
                            Text(stepData.hint)
                                .font(.studioCaption())
                                .foregroundColor(.studioWarning.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.studioWarning.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Step 0: Start Button
                    if gameManager.tutorialStep == 0 {
                        Button(action: {
                            withAnimation { gameManager.advanceTutorial() }
                        }) {
                            Text("START TUTORIAL")
                                .font(.studioHeadline())
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.studioAccent)
                                .cornerRadius(12)
                                .shadow(color: .studioAccent.opacity(0.5), radius: 8)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 360)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.studioAccent.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.studioAccent.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space but don't force alignment
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                pulseAnimation = true
            }
        }
    }
}
