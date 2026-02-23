import SwiftUI

/// Generic Mission HUD displaying current objective
struct MissionHUDView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var pulseAnimation = false
    
    var lesson: Lesson? {
        gameManager.currentLesson
    }
    
    var steps: [LessonStep] {
        lesson?.steps ?? []
    }
    
    var currentStep: LessonStep? {
        guard gameManager.tutorialStep < steps.count else { return nil }
        return steps[gameManager.tutorialStep]
    }
    
    var isComplete: Bool {
        gameManager.tutorialStep >= steps.count
    }
    
    var body: some View {
        VStack {
            if !isComplete, let step = currentStep {
                // Step Card
                VStack(spacing: 16) {
                    // Step indicator dots
                    if steps.count > 1 {
                        HStack(spacing: 6) {
                            ForEach(0..<steps.count, id: \.self) { i in
                                Circle()
                                    .fill(i < gameManager.tutorialStep ? Color.cyan : (i == gameManager.tutorialStep ? Color.cyan : Color.white.opacity(0.2)))
                                    .frame(width: i == gameManager.tutorialStep ? 10 : 6,
                                           height: i == gameManager.tutorialStep ? 10 : 6)
                                    .animation(.spring(), value: gameManager.tutorialStep)
                            }
                        }
                    }
                    
                    // Icon
                    Image(systemName: step.icon)
                        .font(.system(size: 36))
                        .foregroundColor(.cyan)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    
                    // Title
                    Text(step.title)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Instruction
                    Text(step.instruction)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                    
                    // Hint
                    if !step.hint.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(step.hint)
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Start Button (step 0 only) or Continue Button (for non-autoAdvance steps)
                    if gameManager.tutorialStep == 0 {
                        Button(action: {
                            withAnimation { gameManager.advanceTutorial() }
                        }) {
                            Text("START LESSON")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.cyan)
                                .cornerRadius(12)
                                .shadow(color: .cyan.opacity(0.5), radius: 8)
                        }
                    } else if step.goal == .none {
                        // Manual advance button for non-auto steps
                        Button(action: {
                            withAnimation { gameManager.advanceTutorial() }
                        }) {
                            Text("CONTINUE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.cyan.opacity(0.9))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 360)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.85)) // Dark Cosmic Panel
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.cyan.opacity(0.6), lineWidth: 1.5) // Glowing border
                        )
                )
                .shadow(color: .cyan.opacity(0.3), radius: 15, y: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: gameManager.tutorialStep)
            } else if isComplete {
                // Completion card (last step is the completion step, already shown)
                // This state means we've passed all steps — show nothing, MissionSuccessBadge handles it
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever()) {
                pulseAnimation = true
            }
        }
    }
}
