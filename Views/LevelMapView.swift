import SwiftUI

// MARK: - Galaxy Level Map

struct LevelMapView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var selectedPage: Int = 0
    @State private var selectedCategory: String? = nil
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var filteredLessons: [Lesson] {
        if let cat = selectedCategory {
            return LessonManager.shared.lessonsForCategory(cat)
        }
        return LessonManager.shared.lessons
    }
    
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
                    .padding(.bottom, isLandscape ? 4 : 4)
                
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryPill(name: "All", isSelected: selectedCategory == nil) {
                            withAnimation(.spring(response: 0.35)) {
                                selectedCategory = nil
                                selectedPage = filteredLessons.first?.id ?? 0
                            }
                        }
                        ForEach(LessonManager.categories, id: \.self) { cat in
                            CategoryPill(name: cat, isSelected: selectedCategory == cat) {
                                withAnimation(.spring(response: 0.35)) {
                                    selectedCategory = cat
                                    selectedPage = filteredLessons.first?.id ?? 0
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, isLandscape ? 2 : 8)
                
                // Page indicator
                LevelIndicatorBar(
                    total: filteredLessons.count,
                    current: $selectedPage,
                    lessonIds: filteredLessons.map { $0.id },
                    getLessonState: { getLessonState(id: $0) }
                )
                .padding(.bottom, isLandscape ? 4 : 12)
                
                // Paging carousel
                TabView(selection: $selectedPage) {
                    ForEach(filteredLessons) { lesson in
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
        case 11: return StarPalette(core: Color(red: 0.4, green: 0.7, blue: 0.3),   glow: Color(red: 0.3, green: 0.5, blue: 0.2),   ring: Color(red: 0.5, green: 0.8, blue: 0.4))   // Forest Station
        case 12: return StarPalette(core: Color(red: 0.9, green: 0.1, blue: 0.1),   glow: Color(red: 0.7, green: 0.0, blue: 0.0),   ring: Color(red: 1.0, green: 0.2, blue: 0.2))   // Red Dwarf
        case 13: return StarPalette(core: Color(red: 0.3, green: 0.3, blue: 0.9),   glow: Color(red: 0.2, green: 0.2, blue: 0.7),   ring: Color(red: 0.4, green: 0.4, blue: 1.0))   // Twin Blue
        case 14: return StarPalette(core: Color(red: 0.7, green: 0.5, blue: 0.2),   glow: Color(red: 0.5, green: 0.3, blue: 0.1),   ring: Color(red: 0.8, green: 0.6, blue: 0.3))   // Bronze Dock
        case 15: return StarPalette(core: Color(red: 0.9, green: 0.4, blue: 0.7),   glow: Color(red: 0.7, green: 0.2, blue: 0.5),   ring: Color(red: 1.0, green: 0.5, blue: 0.8))   // Magenta Sweep
        case 16: return StarPalette(core: Color(red: 0.6, green: 0.9, blue: 1.0),   glow: Color(red: 0.4, green: 0.7, blue: 0.8),   ring: Color(red: 0.7, green: 1.0, blue: 1.0))   // Ice Moon
        case 17: return StarPalette(core: Color(red: 0.9, green: 0.7, blue: 0.3),   glow: Color(red: 0.7, green: 0.5, blue: 0.2),   ring: Color(red: 1.0, green: 0.8, blue: 0.4))   // Saturn Gold
        case 18: return StarPalette(core: Color(red: 0.5, green: 0.0, blue: 0.8),   glow: Color(red: 0.3, green: 0.0, blue: 0.6),   ring: Color(red: 0.6, green: 0.1, blue: 0.9))   // Deep Violet
        case 19: return StarPalette(core: Color(red: 1.0, green: 0.3, blue: 0.0),   glow: Color(red: 0.8, green: 0.2, blue: 0.0),   ring: Color(red: 1.0, green: 0.4, blue: 0.1))   // Fireball
        case 20: return StarPalette(core: Color(red: 0.0, green: 0.6, blue: 0.5),   glow: Color(red: 0.0, green: 0.4, blue: 0.3),   ring: Color(red: 0.1, green: 0.7, blue: 0.6))   // Fleet Teal
        case 21: return StarPalette(core: Color(red: 1.0, green: 0.85, blue: 0.4),  glow: Color(red: 0.9, green: 0.7, blue: 0.2),   ring: Color(red: 1.0, green: 0.9, blue: 0.5))   // Crown Gold
        case 22: return StarPalette(core: Color(red: 0.0, green: 1.0, blue: 1.0),   glow: Color(red: 0.0, green: 0.8, blue: 0.8),   ring: Color(red: 0.2, green: 1.0, blue: 1.0))   // Sandbox Cyan
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
            // Level badge
            Text("Level \(lesson.id)")
                .font(.system(size: isLandscape ? 12 : 14, weight: .bold, design: .monospaced))
                .foregroundColor(activeColor)
                .tracking(2)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .strokeBorder(activeColor.opacity(0.4), lineWidth: 1.5)
                        .background(Capsule().fill(activeColor.opacity(0.1)))
                )
                .shadow(color: activeColor.opacity(0.2), radius: 5)
            
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
                        Circle()
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
                    
                    // Nebula glow (thick high-fidelity halo)
                    ZStack {
                        Circle()
                            .fill(glowColor.opacity(0.35))
                            .frame(width: circleSize * 1.6, height: circleSize * 1.6)
                            .blur(radius: 40)
                        
                        Circle()
                            .fill(glowColor.opacity(0.15))
                            .frame(width: circleSize * 2.2, height: circleSize * 2.2)
                            .blur(radius: 60)
                    }
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
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: isLandscape ? 45 : 55, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 15)
                    } else if state == .locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isLandscape ? 30 : 40))
                            .foregroundColor(.white.opacity(0.25))
                    } else {
                        Text("\(lesson.id)")
                            .font(.system(size: isLandscape ? 55 : 75, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: activeColor, radius: 12)
                    }
                }
            }
            .disabled(state == .locked)
            .buttonStyle(StarButtonStyle())
            
            // Title + Status
            VStack(spacing: 8) {
                Text(lesson.title.uppercased())
                    .font(.system(size: isLandscape ? 22 : 28, weight: .black, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(state == .locked ? .white.opacity(0.3) : .white)
                    .tracking(2)
                    .lineLimit(2)
                    .frame(maxWidth: 320)
                    .shadow(color: state == .locked ? .clear : activeColor.opacity(0.6), radius: 12)
                
                if state == .current {
                    Button(action: {
                        HapticsManager.shared.selection()
                        gameManager.startLesson(lesson.id)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill").font(.system(size: 10))
                            Text("Start Challenge")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .tracking(2)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(activeColor)
                                
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                            }
                        )
                        .clipShape(Capsule())
                        .shadow(color: activeColor.opacity(0.6), radius: 15, x: 0, y: 5)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                } else if state == .completed {
                    Button(action: {
                        HapticsManager.shared.selection()
                        gameManager.startLesson(lesson.id)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 12))
                            Text("Completed")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(activeColor.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                } else {
                    HStack(spacing: 5) {
                        Image(systemName: "lock.fill").font(.system(size: 9))
                        Text("Locked")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white.opacity(0.3))
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
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        VStack(spacing: isLandscape ? 4 : 10) {
            Text("Levels")
                .font(.system(size: isLandscape ? 20 : 26, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .tracking(4)
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.cyan)
                    Text("\(gameManager.completedLessonIds.count) / \(LessonManager.shared.lessons.count)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan.opacity(0.8))
                }
                
                Circle().fill(Color.white.opacity(0.2)).frame(width: 3, height: 3)
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.cyan)
                    Text("\(gameManager.totalXP) XP")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan.opacity(0.8))
                }
            }
        }
    }
}

// MARK: - Level Indicator Bar

struct LevelIndicatorBar: View {
    let total: Int
    let lessonIds: [Int]
    @Binding var current: Int
    let getLessonState: (Int) -> LessonNodeState
    
    init(total: Int, current: Binding<Int>, lessonIds: [Int] = [], getLessonState: @escaping (Int) -> LessonNodeState) {
        self.total = total
        self._current = current
        self.lessonIds = lessonIds.isEmpty ? Array(1...max(total, 1)) : lessonIds
        self.getLessonState = getLessonState
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(lessonIds, id: \.self) { lessonId in
                let state = getLessonState(lessonId)
                let isCurrent = lessonId == current
                let palette = StarPalette.forLevel(lessonId)
                
                Rectangle()
                    .fill(barColor(state: state, isCurrent: isCurrent, palette: palette))
                    .frame(width: isCurrent ? 36 : 10, height: 6)
                    .cornerRadius(3)
                    .shadow(color: isCurrent ? barColor(state: state, isCurrent: true, palette: palette).opacity(0.9) : .clear, radius: 6)
                    .overlay(
                         isCurrent ? 
                         Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1) : 
                         nil
                    )
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
                context.stroke(path, with: .color(.cyan.opacity(0.15)), lineWidth: 0.5)
            }
            
            // Horizontal lines
            for y in stride(from: 0, through: height, by: step) {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: width, y: y))
                }
                context.stroke(path, with: .color(.cyan.opacity(0.15)), lineWidth: 0.5)
            }
            
            // Subtle crosshairs at grid intersections
            for x in stride(from: step, through: width - step, by: step * 2) {
                for y in stride(from: step, through: height - step, by: step * 2) {
                    let dot = Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2))
                    context.fill(dot, with: .color(.cyan.opacity(0.3)))
                }
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

// MARK: - Category Pill

struct CategoryPill: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? .black : .white.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.cyan : Color.white.opacity(0.08))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.cyan.opacity(0.8) : Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Safe Array Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
