import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var currentPage = 0
    @State private var animateIcon = false
    
    private let pages: [(icon: String, title: String, subtitle: String, detail: String)] = [
        ("sparkles", "Welcome to Nebula", "You've been chosen to build\nthe next universe.", "Write code. Shape reality."),
        ("camera.fill", "Use Your Camera", "Point your device at a flat surface.\nObjects appear in the real world.", "Nebula uses Augmented Reality — your camera is your viewport."),
        ("hand.tap.fill", "Tap to Spawn", "Tap anywhere on the surface\nto place 3D objects.", "Stars, planets, ships — anything you can imagine."),
        ("terminal.fill", "Code to Control", "Open the console to edit\nphysics, colors, and behavior.", "Change radius, color, mass, orbit, gravity — all in code."),
        ("crown.fill", "Master the Stars", "Complete missions.\nEarn badges.\nUnlock Sandbox Mode.", "22 levels across 5 categories await you.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.08),
                    Color(red: 0.05, green: 0.03, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Star particles
            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.5)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 360)
                
                Spacer()
                
                // Page dots
                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.cyan : Color.white.opacity(0.2))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.35), value: currentPage)
                    }
                }
                .padding(.bottom, 30)
                
                // Buttons
                HStack {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            finishOnboarding()
                        }
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.5))
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: .cyan.opacity(0.4), radius: 10)
                        }
                    } else {
                        Spacer()
                        
                        Button(action: {
                            finishOnboarding()
                        }) {
                            HStack(spacing: 8) {
                                Text("BEGIN MISSION")
                                Image(systemName: "rocket.fill")
                            }
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [.cyan, .mint, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: .cyan.opacity(0.5), radius: 15)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateIcon = true
            }
        }
    }
    
    @ViewBuilder
    func pageView(_ page: (icon: String, title: String, subtitle: String, detail: String)) -> some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(colors: [.cyan.opacity(0.2), .clear], center: .center, startRadius: 20, endRadius: 60)
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateIcon ? 1.1 : 0.9)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            // Subtitle
            Text(page.subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Detail pill
            Text(page.detail)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.cyan.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 40)
    }
    
    func finishOnboarding() {
        gameManager.hasSeenOnboarding = true
        withAnimation(.easeInOut(duration: 0.5)) {
            gameManager.appState = .welcome
        }
    }
}
