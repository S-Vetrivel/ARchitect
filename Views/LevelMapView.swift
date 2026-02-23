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
            
            // Holo-Grid Background
            GeometryReader { geo in
                GridBackground()
                    .opacity(0.15)
                    .mask(
                        LinearGradient(
                            colors: [.clear, .white, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .ignoresSafeArea()
            
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
                .padding(.bottom, isLandscape ? 4 : 20)
                
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
    
    var circleSize: CGFloat { isLandscape ? 150 : 200 }
    var ringSize: CGFloat { isLandscape ? 190 : 260 }
    
    var body: some View {
        VStack(spacing: isLandscape ? 16 : 40) {
            // Star system label
            HStack(spacing: 8) {
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 2, bottomLeading: 2, bottomTrailing: 0, topTrailing: 0))
                    .fill(activeColor.opacity(0.6))
                    .frame(width: 4, height: 16)
                
                Text("SYSTEM \(String(format: "%02d", lesson.id))")
                    .font(.custom("CourierNewPS-BoldMT", size: isLandscape ? 12 : 14))
                    .foregroundColor(activeColor)
                    .tracking(4)
                
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: 0, bottomTrailing: 2, topTrailing: 2))
                    .fill(activeColor.opacity(0.6))
                    .frame(width: 4, height: 16)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .strokeBorder(activeColor.opacity(0.3), lineWidth: 1)
            )
            
            // The Star
            Button(action: {
                if state != .locked {
                    HapticsManager.shared.selection()
                    gameManager.startLesson(lesson.id)
                }
            }) {
                ZStack {
                    // Outer pulse ring (HUD Target)
                    if state != .locked {
                        Circle()
                            .strokeBorder(activeColor.opacity(0.3), lineWidth: 1)
                            .frame(width: ringSize + 60, height: ringSize + 60)
                            .scaleEffect(outerPulse ? 1.1 : 1.0)
                            .opacity(outerPulse ? 0.0 : 0.4)
                    }
                    
                    // Orbital ring 1 (Tech dashed)
                    if state != .locked {
                        Circle()
                            .stroke(ringColor.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [10, 10]))
                            .frame(width: ringSize, height: ringSize)
                            .rotationEffect(.degrees(ringRotation))
                        
                        // Tech Nodes on Ring
                        Rectangle()
                            .fill(ringColor)
                            .frame(width: 8, height: 8)
                            .offset(x: ringSize / 2)
                            .rotationEffect(.degrees(ringRotation))
                    }
                    
                    // Orbital ring 2 (counter-rotate)
                    if state == .current {
                        Circle()
                            .stroke(ringColor.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [2, 8]))
                            .frame(width: ringSize - 30, height: ringSize - 30)
                            .rotationEffect(.degrees(-ringRotation * 0.7))
                    }
                    
                    // Nebula glow (large soft halo)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [glowColor.opacity(0.4), glowColor.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: circleSize * 0.8
                            )
                        )
                        .frame(width: circleSize + 80, height: circleSize + 80)
                        .blur(radius: 20)
                        .opacity(state == .locked ? 0.2 : 1)
                    
                    // Core star body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    activeColor.opacity(state == .locked ? 0.1 : 0.95),
                                    activeColor.opacity(state == .locked ? 0.05 : 0.4),
                                    .clear
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5),
                                startRadius: 10,
                                endRadius: circleSize / 2
                            )
                        )
                        .frame(width: circleSize, height: circleSize)
                        .scaleEffect(corePulse ? 1.05 : 1.0)
                        .overlay(
                             Circle()
                                .stroke(activeColor.opacity(0.5), lineWidth: 2)
                                .blur(radius: 4)
                        )
                    
                    // Hard bright core
                    Circle()
                        .fill(Color.white)
                        .frame(width: circleSize * 0.3, height: circleSize * 0.3)
                        .blur(radius: circleSize * 0.1)
                        .opacity(state == .locked ? 0.1 : 0.9)
                        
                    
                    // Icon overlay
                    if state == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: isLandscape ? 40 : 50, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 10)
                    } else if state == .locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isLandscape ? 30 : 40))
                            .foregroundColor(.white.opacity(0.2))
                    } else {
                        Text("\(lesson.id)")
                            .font(.system(size: isLandscape ? 50 : 70, weight: .ultraLight, design: .default))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 10)
                    }
                }
            }
            .disabled(state == .locked)
            .buttonStyle(StarButtonStyle())
            
            // Title + Status
            VStack(spacing: 8) {
                Text(lesson.title.uppercased())
                    .font(.system(size: isLandscape ? 20 : 24, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(state == .locked ? .white.opacity(0.3) : .white)
                    .scaleEffect(x: 1.1, y: 1.0) // Slight stretch for sci-fi feel
                    .lineLimit(2)
                    .frame(maxWidth: 300)
                    .shadow(color: state == .locked ? .clear : activeColor.opacity(0.5), radius: 8)
                
                if state == .current {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill").font(.system(size: 10))
                        Text("INITIATE SEQUENCE")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(activeColor)
                            .shadow(color: activeColor.opacity(0.8), radius: 10)
                    )
                    .padding(.top, 8)
                } else if state == .completed {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 12))
                        Text("SECTOR CLEARED")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(activeColor.opacity(0.8))
                    .padding(.top, 8)
                } else {
                    Text("ACCESS DENIED")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.red.opacity(0.4))
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            if state != .locked {
                withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    corePulse = true
                }
            }
            if state == .current {
                withAnimation(.easeOut(duration: 2).repeatForever(autoreverses: false)) {
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
            HStack {
                Rectangle().frame(height: 1).opacity(0.3)
                Text("STAR CHART")
                    .font(.system(size: isLandscape ? 14 : 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .tracking(6)
                Rectangle().frame(height: 1).opacity(0.3)
            }
            .padding(.horizontal, 40)
            
            Text("Select Destination Coordinates")
                .font(.system(size: isLandscape ? 9 : 10, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1)
        }
    }
}

// MARK: - Level Indicator Bar

struct LevelIndicatorBar: View {
    let total: Int
    @Binding var current: Int
    let getLessonState: (Int) -> LessonNodeState
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                let lessonId = i + 1
                let state = getLessonState(lessonId)
                let isCurrent = lessonId == current
                let palette = StarPalette.forLevel(lessonId)
                
                Rectangle()
                    .fill(barColor(state: state, isCurrent: isCurrent, palette: palette))
                    .frame(width: isCurrent ? 30 : 12, height: 4)
                    .cornerRadius(2)
                    .shadow(color: isCurrent ? barColor(state: state, isCurrent: true, palette: palette).opacity(0.8) : .clear, radius: 4)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: current)
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
        case .completed: return palette.core.opacity(0.4)
        case .current: return palette.core.opacity(0.4)
        case .locked: return .white.opacity(0.1)
        }
    }
}

// MARK: - Tech Grid Background

struct GridBackground: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 40
            let width = size.width
            let height = size.height
            
            // Vertical lines
            for x in stride(from: 0, through: width, by: step) {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: height))
                }
                context.stroke(path, with: .color(.cyan.opacity(0.3)), lineWidth: 0.5)
            }
            
            // Horizontal lines
            for y in stride(from: 0, through: height, by: step) {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: width, y: y))
                }
                context.stroke(path, with: .color(.cyan.opacity(0.3)), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - Button Style

struct StarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? 0.2 : 0.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
