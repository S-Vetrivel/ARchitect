import SwiftUI

struct WelcomeView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var showText = false
    @State private var rotate = false
    
    var body: some View {
        ZStack {
            // Radial Background
            RadialGradient(
                colors: [.voidBlack.opacity(0.8), .black],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            .overlay(
                // Scanlines
                VStack(spacing: 4) {
                    ForEach(0..<200) { _ in
                        Rectangle()
                            .fill(Color.tacticalAmber.opacity(0.05))
                            .frame(height: 1)
                        Spacer()
                    }
                }
                .ignoresSafeArea()
            )
            
            VStack(spacing: 60) {
                Spacer()
                
                // 3D Visual Logo
                ZStack {
                    Circle()
                        .stroke(Color.tacticalAmber.opacity(0.3), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.tacticalAmber, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 10]))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(rotate ? 360 : 0))
                        .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotate)
                    
                    Image(systemName: "cube.transparent.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .tacticalAmber, radius: 20)
                }
                .onAppear { rotate = true }
                
                // Title
                VStack(spacing: 10) {
                    Text("ARCHITECT")
                        .font(.tacticalHeader(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .tacticalAmber],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .tacticalAmber.opacity(0.5), radius: 10)
                        .kerning(5)
                    
                    Text("BUILDER SIMULATOR v1.0")
                        .font(.tacticalData(size: 14))
                        .foregroundColor(.alertRed)
                        .tracking(3)
                }
                
                Spacer()
                
                // Press Start
                Button(action: {
                    HapticsManager.shared.notify(.success)
                    withAnimation(.easeIn(duration: 0.2)) {
                        gameManager.appState = .levelMap
                    }
                }) {
                    Text("Tap to Start Mission")
                        .font(.tacticalBody(size: 20))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 40)
                        .background(Color.tacticalAmber.opacity(0.2))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.tacticalAmber, lineWidth: 2)
                        )
                        .shadow(color: .tacticalAmber, radius: showText ? 10 : 0)
                        .scaleEffect(showText ? 1.05 : 1.0)
                        .opacity(showText ? 1 : 0.5)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                showText = true
            }
        }
    }
}
