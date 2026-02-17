import SwiftUI

struct WelcomeView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var showText = false
    @State private var rotate = false
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
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
            
            if isLandscape {
                landscapeContent
            } else {
                portraitContent
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                showText = true
            }
        }
    }
    
    // MARK: - Portrait Layout (Vertical stack)
    
    var portraitContent: some View {
        VStack(spacing: 60) {
            Spacer()
            
            logoView(size: 200, iconSize: 80)
            
            titleBlock(titleSize: 60, subtitleSize: 14)
            
            Spacer()
            
            startButton(fontSize: 20)
                .padding(.bottom, 50)
        }
    }
    
    // MARK: - Landscape Layout (Side-by-side)
    
    var landscapeContent: some View {
        HStack(spacing: 40) {
            Spacer()
            
            // Left: Logo
            logoView(size: 140, iconSize: 56)
            
            // Right: Title + Button
            VStack(spacing: 24) {
                Spacer()
                
                titleBlock(titleSize: 42, subtitleSize: 12)
                
                startButton(fontSize: 16)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Shared Components
    
    func logoView(size: CGFloat, iconSize: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.tacticalAmber.opacity(0.3), lineWidth: 2)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(Color.tacticalAmber, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [10, 10]))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: rotate)
            
            Image(systemName: "cube.transparent.fill")
                .font(.system(size: iconSize))
                .foregroundColor(.white)
                .shadow(color: .tacticalAmber, radius: 20)
        }
        .onAppear { rotate = true }
    }
    
    func titleBlock(titleSize: CGFloat, subtitleSize: CGFloat) -> some View {
        VStack(spacing: 10) {
            Text("ARCHITECT")
                .font(.tacticalHeader(size: titleSize))
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
                .font(.tacticalData(size: subtitleSize))
                .foregroundColor(.alertRed)
                .tracking(3)
        }
    }
    
    func startButton(fontSize: CGFloat) -> some View {
        Button(action: {
            HapticsManager.shared.notify(.success)
            withAnimation(.easeIn(duration: 0.2)) {
                gameManager.appState = .levelMap
            }
        }) {
            Text("Tap to Start Mission")
                .font(.tacticalBody(size: fontSize))
                .foregroundColor(.white)
                .padding(.vertical, isLandscape ? 10 : 15)
                .padding(.horizontal, isLandscape ? 30 : 40)
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
    }
}
