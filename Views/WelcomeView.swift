import SwiftUI

struct WelcomeView: View {
    @ObservedObject var gameManager = GameManager.shared
    
    // Sequenced animation states
    @State private var showStars = false
    @State private var showPlanet = false
    @State private var planetScale: CGFloat = 0.3
    @State private var showRing = false
    @State private var ringRotation: Double = 0
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showButton = false
    @State private var buttonPulse = false
    
    var body: some View {
        ZStack {
            // Layer 0: Absolute black (instant)
            Color.black.ignoresSafeArea()
            
            // Layer 1: Stars fade in
            StarfieldBackground()
                .opacity(showStars ? 1 : 0)
            
            // Layer 2: Content
            VStack(spacing: 0) {
                Spacer()
                
                // --- PLANET + RING ---
                ZStack {
                    // Orbital ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.nebulaCyan.opacity(0.5), .nebulaAccent.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(ringRotation))
                        .scaleEffect(showRing ? 1 : 0.5)
                        .opacity(showRing ? 1 : 0)
                    
                    // Second ring (counter-rotate)
                    Circle()
                        .stroke(Color.nebulaAccent.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [3, 8]))
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-ringRotation * 0.6))
                        .scaleEffect(showRing ? 1 : 0.3)
                        .opacity(showRing ? 0.6 : 0)
                    
                    // Small orbiting moon
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 8)
                        .shadow(color: .white, radius: 4)
                        .offset(x: 100)
                        .rotationEffect(.degrees(ringRotation * 1.5))
                        .opacity(showRing ? 1 : 0)
                    
                    // Planet glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.nebulaAccent.opacity(0.3),
                                    Color.nebulaCyan.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .opacity(showPlanet ? 1 : 0)
                    
                    // The Planet
                    ZStack {
                        // Planet body
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.1, blue: 0.4),
                                        Color(red: 0.05, green: 0.02, blue: 0.15),
                                        Color.black
                                    ],
                                    center: UnitPoint(x: 0.35, y: 0.35),
                                    startRadius: 5,
                                    endRadius: 70
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Planet atmosphere edge
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.nebulaCyan.opacity(0.6), .clear, .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 120, height: 120)
                        
                        // Planet surface detail (bands)
                        Circle()
                            .trim(from: 0.2, to: 0.4)
                            .stroke(Color.nebulaAccent.opacity(0.15), lineWidth: 40)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-20))
                            .clipShape(Circle().scale(1.0))
                            .frame(width: 120, height: 120)
                            .clipped()
                    }
                    .scaleEffect(planetScale)
                    .opacity(showPlanet ? 1 : 0)
                }
                .padding(.bottom, 50)
                
                // --- TITLE ---
                VStack(spacing: 12) {
                    Text("NEBULA")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(12)
                        .shadow(color: .nebulaAccent.opacity(0.5), radius: 20)
                        .shadow(color: .nebulaCyan.opacity(0.3), radius: 40)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 15)
                    
                    Text("SPACE ACADEMY")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.nebulaCyan.opacity(0.7))
                        .tracking(6)
                        .opacity(showSubtitle ? 1 : 0)
                        .offset(y: showSubtitle ? 0 : 10)
                    
                    // Thin divider line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .nebulaCyan.opacity(0.4), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200, height: 1)
                        .opacity(showSubtitle ? 1 : 0)
                        .padding(.top, 4)
                    
                    Text("Master Physics. Build Worlds.")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.gray.opacity(0.6))
                        .opacity(showSubtitle ? 1 : 0)
                }
                
                Spacer()
                
                // --- LAUNCH BUTTON ---
                VStack(spacing: 12) {
                    Button(action: {
                        HapticsManager.shared.play(.medium)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            gameManager.appState = .levelMap
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16))
                                .rotationEffect(.degrees(-45))
                            Text("LAUNCH MISSION")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .tracking(2)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color.nebulaAccent, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.nebulaCyan.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .nebulaAccent.opacity(buttonPulse ? 0.6 : 0.3), radius: buttonPulse ? 20 : 10)
                        .scaleEffect(buttonPulse ? 1.02 : 1.0)
                    }
                    
                    Text("v2.0 · Nebula Engine")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 60)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            runCinematicSequence()
        }
    }
    
    // MARK: - Cinematic Reveal Sequence
    func runCinematicSequence() {
        // 0.0s — Stars begin to fade in from black
        withAnimation(.easeIn(duration: 2.0)) {
            showStars = true
        }
        
        // 0.8s — Planet fades in + scales up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 1.5)) {
                showPlanet = true
            }
            withAnimation(.spring(response: 2.0, dampingFraction: 0.7)) {
                planetScale = 1.0
            }
        }
        
        // 1.5s — Rings appear + start rotating
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 1.0)) {
                showRing = true
            }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
        }
        
        // 2.2s — Title slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                showTitle = true
            }
        }
        
        // 2.8s — Subtitle + tagline
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.6)) {
                showSubtitle = true
            }
        }
        
        // 3.5s — Button appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                showButton = true
            }
            // Start button glow pulse
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    buttonPulse = true
                }
            }
        }
    }
}
