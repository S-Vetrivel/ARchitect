import SwiftUI

struct TutorialOverlayView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var pulseAnimation = false
    @State private var arrowBounce = false
    
    let totalSteps = 7
    
    var stepData: (icon: String, title: String, instruction: String, hint: String) {
        switch gameManager.tutorialStep {
        case 0:
            return ("hand.tap.fill", "Welcome!", "Welcome to ARchitect Academy!\nTap anywhere on the screen to begin.", "")
        case 1:
            return ("hand.tap.fill", "Step 1: Get Started", "Tap anywhere on the 3D view to begin your journey.", "Just tap!")
        case 2:
            return ("hand.draw.fill", "Step 2: Look Around", "Swipe or drag the screen to look around your virtual studio.", "Try swiping in any direction")
        case 3:
            return ("circle.circle.fill", "Step 3: Walk", "Use the joystick (bottom-right) to walk forward.\nMove toward the glowing marker!", "Push the joystick forward")
        case 4:
            return ("arrow.up.left.and.arrow.down.right", "Step 4: Zoom", "Pinch the screen to zoom in and out.\nOn Mac: use scroll wheel.", "Try zooming in and out")
        case 5:
            return ("cube.fill", "Step 5: Place Object", "Tap anywhere on the floor to place your first 3D object!", "Tap the floor!")
        case 6:
            return ("chevron.left.forwardslash.chevron.right", "Step 6: Edit Code", "Open the code editor and change\n`color: .blue` to `color: .red`\nThen tap your object to apply!", "Edit the code, then tap the object")
        case 7:
            return ("checkmark.circle.fill", "Tutorial Complete! 🎉", "You're ready to build in AR!\nYou now know how to navigate, build, and code.", "")
        default:
            return ("questionmark", "Unknown", "", "")
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Coach Card
            VStack(spacing: 16) {
                // Step indicator dots
                HStack(spacing: 6) {
                    ForEach(1...totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step <= gameManager.tutorialStep ? Color.cyan : Color.white.opacity(0.2))
                            .frame(width: step == gameManager.tutorialStep ? 10 : 6,
                                   height: step == gameManager.tutorialStep ? 10 : 6)
                            .animation(.spring(), value: gameManager.tutorialStep)
                    }
                }
                
                // Icon
                Image(systemName: stepData.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.cyan)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                
                // Title
                Text(stepData.title)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
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
                            .foregroundColor(.yellow)
                        Text(stepData.hint)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Step 0 / Step 7: Action buttons
                if gameManager.tutorialStep == 0 {
                    Button(action: {
                        withAnimation { gameManager.advanceTutorial() }
                    }) {
                        Text("START TUTORIAL")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.cyan)
                            .cornerRadius(12)
                            .shadow(color: .cyan.opacity(0.5), radius: 8)
                    }
                }
                
                if gameManager.tutorialStep == 7 {
                    Button(action: {
                        withAnimation {
                            gameManager.appState = .levelMap
                        }
                    }) {
                        Text("FINISH")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .green.opacity(0.5), radius: 8)
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
                            .fill(Color.blue.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: .cyan.opacity(0.15), radius: 20, y: 10)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                pulseAnimation = true
            }
        }
    }
}
