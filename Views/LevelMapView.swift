import SwiftUI

// MARK: - Galaxy Level Map

struct LevelMapView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var selectedPage: Int = 0
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        ZStack {
            // Deep black space
            Color.black.ignoresSafeArea()
            
            // Subtle nebula wisps
            RadialGradient(
                colors: [Color(red: 0.04, green: 0.0, blue: 0.1).opacity(0.4), .clear],
                center: UnitPoint(x: 0.8, y: 0.15),
                startRadius: 20, endRadius: 500
            ).ignoresSafeArea()
            
            RadialGradient(
                colors: [Color(red: 0.0, green: 0.02, blue: 0.08).opacity(0.3), .clear],
                center: UnitPoint(x: 0.1, y: 0.9),
                startRadius: 10, endRadius: 400
            ).ignoresSafeArea()
            
            // Sparse static stars
            GeometryReader { geo in
                Canvas { context, size in
                    let positions: [(CGFloat, CGFloat, CGFloat)] = [
                        (0.1, 0.05, 1.2), (0.85, 0.12, 0.8), (0.3, 0.08, 1.5),
                        (0.65, 0.03, 1.0), (0.92, 0.35, 0.7), (0.05, 0.45, 1.3),
                        (0.78, 0.55, 0.9), (0.15, 0.7, 1.1), (0.55, 0.85, 0.8),
                        (0.9, 0.78, 1.4), (0.4, 0.92, 0.6), (0.25, 0.3, 1.0),
                        (0.7, 0.42, 0.7), (0.45, 0.15, 0.9), (0.6, 0.68, 1.1),
                    ]
                    for (px, py, s) in positions {
                        let rect = CGRect(x: px * size.width, y: py * size.height, width: s, height: s)
                        context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.4)))
                    }
                }
            }.ignoresSafeArea()
            
            // MARK: - Main Content
            VStack(spacing: 0) {
                // Header
                GalaxyHeader()
                    .padding(.top, isLandscape ? 8 : 16)
                    .padding(.bottom, isLandscape ? 4 : 8)
                
                // Page indicator
                LevelIndicatorBar(
                    total: LessonManager.shared.lessons.count,
                    current: $selectedPage,
                    getLessonState: { getLessonState(id: $0) }
                )
                .padding(.bottom, isLandscape ? 4 : 10)
                
                // Paging carousel
                TabView(selection: $selectedPage) {
                    ForEach(LessonManager.shared.lessons) { lesson in
                        GeometryReader { geo in
                            let midX = geo.frame(in: .global).midX
                            let screenMidX = UIScreen.main.bounds.width / 2
                            let distance = abs(midX - screenMidX)
                            let maxDist: CGFloat = UIScreen.main.bounds.width * 0.6
                            let normalizedDist = min(distance / maxDist, 1.0)
                            let scale = 1.0 - (normalizedDist * 0.3)
                            let blurAmount = normalizedDist * 8
                            
                            NebulaLevelNode(
                                lesson: lesson,
                                state: getLessonState(id: lesson.id),
                                isLandscape: isLandscape
                            )
                            .scaleEffect(scale)
                            .blur(radius: blurAmount)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tag(lesson.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onAppear {
                    selectedPage = gameManager.highestUnlockedLevelIndex
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    func getLessonState(id: Int) -> LessonNodeState {
        if gameManager.isLessonCompleted(id: id) {
            return .completed
        } else if gameManager.isLessonUnlocked(id: id) {
             return .current
        } else {
            return .locked
        }
    }
}

// MARK: - Lesson Node State

enum LessonNodeState {
    case locked, current, completed
}

// MARK: - Star Color Palette (each level = unique nebula color)

struct StarPalette {
    let core: Color
    let glow: Color
    let ring: Color
    
    // Each level gets a unique nebula / neutron star color
    static func forLevel(_ id: Int) -> StarPalette {
        switch id {
        case 1:  return StarPalette(core: Color(red: 0.2, green: 0.5, blue: 1.0),   glow: Color(red: 0.1, green: 0.3, blue: 0.9),   ring: Color(red: 0.3, green: 0.6, blue: 1.0))   // Blue Supergiant
        case 2:  return StarPalette(core: Color(red: 0.6, green: 0.2, blue: 1.0),   glow: Color(red: 0.4, green: 0.1, blue: 0.8),   ring: Color(red: 0.7, green: 0.3, blue: 1.0))   // Violet Nebula
        case 3:  return StarPalette(core: Color(red: 0.0, green: 0.9, blue: 0.8),   glow: Color(red: 0.0, green: 0.6, blue: 0.6),   ring: Color(red: 0.0, green: 1.0, blue: 0.9))   // Teal Pulsar
        case 4:  return StarPalette(core: Color(red: 1.0, green: 0.4, blue: 0.1),   glow: Color(red: 0.8, green: 0.2, blue: 0.0),   ring: Color(red: 1.0, green: 0.5, blue: 0.2))   // Red Giant
        case 5:  return StarPalette(core: Color(red: 1.0, green: 0.8, blue: 0.0),   glow: Color(red: 0.9, green: 0.6, blue: 0.0),   ring: Color(red: 1.0, green: 0.9, blue: 0.3))   // Gold Star
        case 6:  return StarPalette(core: Color(red: 0.0, green: 1.0, blue: 0.4),   glow: Color(red: 0.0, green: 0.7, blue: 0.3),   ring: Color(red: 0.2, green: 1.0, blue: 0.5))   // Emerald Quasar
        case 7:  return StarPalette(core: Color(red: 1.0, green: 0.2, blue: 0.5),   glow: Color(red: 0.8, green: 0.1, blue: 0.4),   ring: Color(red: 1.0, green: 0.4, blue: 0.6))   // Pink Neutron
        case 8:  return StarPalette(core: Color(red: 0.1, green: 0.8, blue: 1.0),   glow: Color(red: 0.0, green: 0.5, blue: 0.8),   ring: Color(red: 0.2, green: 0.9, blue: 1.0))   // Cyan Dwarf
        case 9:  return StarPalette(core: Color(red: 1.0, green: 0.5, blue: 0.0),   glow: Color(red: 0.9, green: 0.3, blue: 0.0),   ring: Color(red: 1.0, green: 0.6, blue: 0.1))   // Solar Flare
        case 10: return StarPalette(core: Color(red: 0.8, green: 0.8, blue: 1.0),   glow: Color(red: 0.6, green: 0.6, blue: 0.9),   ring: Color(red: 0.9, green: 0.9, blue: 1.0))   // White Dwarf
        default: return StarPalette(core: Color(red: 0.5, green: 0.5, blue: 0.5),   glow: .gray,                                     ring: .gray)
        }
    }
}

// MARK: - Nebula Level Node

struct NebulaLevelNode: View {
    let lesson: Lesson
    let state: LessonNodeState
    let isLandscape: Bool
    @ObservedObject var gameManager = GameManager.shared
    
    @State private var ringRotation: Double = 0
    @State private var corePulse: Bool = false
    @State private var outerPulse: Bool = false
    
    var palette: StarPalette { StarPalette.forLevel(lesson.id) }
    
    var activeColor: Color {
        state == .locked ? Color(white: 0.25) : palette.core
    }
    var glowColor: Color {
        state == .locked ? Color(white: 0.1) : palette.glow
    }
    var ringColor: Color {
        state == .locked ? Color(white: 0.15) : palette.ring
    }
    
    var circleSize: CGFloat { isLandscape ? 150 : 180 }
    var ringSize: CGFloat { isLandscape ? 190 : 230 }
    
    var body: some View {
        VStack(spacing: isLandscape ? 16 : 28) {
            // Star system label
            HStack(spacing: 6) {
                Rectangle().fill(activeColor.opacity(0.3)).frame(width: 20, height: 1)
                Text("SYSTEM \(String(format: "%02d", lesson.id))")
                    .font(.system(size: isLandscape ? 10 : 12, weight: .bold, design: .monospaced))
                    .foregroundColor(activeColor.opacity(0.8))
                    .tracking(3)
                Rectangle().fill(activeColor.opacity(0.3)).frame(width: 20, height: 1)
            }
            
            // The Star
            Button(action: {
                if state != .locked {
                    HapticsManager.shared.selection()
                    gameManager.startLesson(lesson.id)
                }
            }) {
                ZStack {
                    // Outer pulse ring
                    if state != .locked {
                        Circle()
                            .stroke(activeColor.opacity(0.08), lineWidth: 1)
                            .frame(width: ringSize + 30, height: ringSize + 30)
                            .scaleEffect(outerPulse ? 1.2 : 1.0)
                            .opacity(outerPulse ? 0.0 : 0.5)
                    }
                    
                    // Orbital ring 1 (dashed, rotating)
                    if state != .locked {
                        Circle()
                            .stroke(ringColor.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [5, 6]))
                            .frame(width: ringSize, height: ringSize)
                            .rotationEffect(.degrees(ringRotation))
                        
                        // Small orbiting body
                        Circle()
                            .fill(ringColor.opacity(0.9))
                            .frame(width: 6, height: 6)
                            .shadow(color: ringColor, radius: 4)
                            .offset(x: ringSize / 2)
                            .rotationEffect(.degrees(ringRotation * 1.2))
                    }
                    
                    // Orbital ring 2 (counter-rotate)
                    if state == .current {
                        Circle()
                            .stroke(ringColor.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [3, 10]))
                            .frame(width: ringSize - 20, height: ringSize - 20)
                            .rotationEffect(.degrees(-ringRotation * 0.5))
                    }
                    
                    // Nebula glow (large soft halo)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [glowColor.opacity(0.35), glowColor.opacity(0.05), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: circleSize * 0.8
                            )
                        )
                        .frame(width: circleSize + 60, height: circleSize + 60)
                        .blur(radius: 15)
                        .opacity(state == .locked ? 0.2 : 1)
                    
                    // Core star body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    activeColor.opacity(state == .locked ? 0.08 : 0.9),
                                    activeColor.opacity(state == .locked ? 0.03 : 0.3),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.4, y: 0.4),
                                startRadius: 5,
                                endRadius: circleSize / 2
                            )
                        )
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(corePulse ? 1.03 : 1.0)
                    
                    // Hard bright core
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(state == .locked ? 0.05 : 0.8), activeColor.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 5)
                        .opacity(state == .locked ? 0.3 : 1)
                    
                    // Icon overlay
                    if state == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: isLandscape ? 40 : 50, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 12)
                    } else if state == .locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isLandscape ? 28 : 34))
                            .foregroundColor(.white.opacity(0.2))
                    } else {
                        Text("\(lesson.id)")
                            .font(.system(size: isLandscape ? 48 : 56, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 16)
                    }
                }
            }
            .disabled(state == .locked)
            .buttonStyle(StarButtonStyle())
            
            // Title + Status
            VStack(spacing: 8) {
                Text(lesson.title.uppercased())
                    .font(.system(size: isLandscape ? 16 : 18, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(state == .locked ? .white.opacity(0.2) : .white.opacity(0.9))
                    .lineLimit(2)
                    .frame(maxWidth: 280)
                
                if state == .current {
                    HStack(spacing: 5) {
                        Image(systemName: "play.fill").font(.system(size: 9))
                        Text("ENTER SYSTEM")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(activeColor)
                            .shadow(color: activeColor.opacity(0.7), radius: 8)
                    )
                    .padding(.top, 4)
                } else if state == .completed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 10))
                        Text("EXPLORED")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(activeColor.opacity(0.6))
                    .padding(.top, 4)
                } else {
                    Text("LOCKED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.15))
                        .padding(.top, 4)
                }
            }
        }
        .onAppear {
            if state != .locked {
                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    corePulse = true
                }
            }
            if state == .current {
                withAnimation(.easeInOut(duration: 2.5).repeatForever()) {
                    outerPulse = true
                }
            }
        }
    }
}

// MARK: - Galaxy Header

struct GalaxyHeader: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        VStack(spacing: isLandscape ? 4 : 8) {
            Text("STAR CHART")
                .font(.system(size: isLandscape ? 18 : 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(4)
            
            Text("Select a star system to explore")
                .font(.system(size: isLandscape ? 9 : 11, weight: .medium))
                .foregroundColor(.nebulaCyan.opacity(0.5))
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .nebulaCyan.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, isLandscape ? 120 : 60)
                .padding(.top, 1)
        }
    }
}

// MARK: - Level Indicator Bar

struct LevelIndicatorBar: View {
    let total: Int
    @Binding var current: Int
    let getLessonState: (Int) -> LessonNodeState
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                let lessonId = i + 1
                let state = getLessonState(lessonId)
                let isCurrent = lessonId == current
                let palette = StarPalette.forLevel(lessonId)
                
                Capsule()
                    .fill(barColor(state: state, isCurrent: isCurrent, palette: palette))
                    .frame(width: isCurrent ? 24 : 8, height: 4)
                    .shadow(color: isCurrent ? barColor(state: state, isCurrent: true, palette: palette).opacity(0.6) : .clear, radius: 4)
                    .animation(.easeInOut(duration: 0.3), value: current)
                    .onTapGesture {
                        if state != .locked {
                            withAnimation { current = lessonId }
                        }
                    }
            }
        }
    }
    
    func barColor(state: LessonNodeState, isCurrent: Bool, palette: StarPalette) -> Color {
        if isCurrent {
            switch state {
            case .completed: return palette.core
            case .current: return palette.core
            case .locked: return .white.opacity(0.2)
            }
        }
        switch state {
        case .completed: return palette.core.opacity(0.3)
        case .current: return palette.core.opacity(0.3)
        case .locked: return .white.opacity(0.08)
        }
    }
}

// MARK: - Button Style

struct StarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? 0.15 : 0.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
