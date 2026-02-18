import SwiftUI

// MARK: - Cyberpunk Level Map

struct LevelMapView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var selectedPage: Int = 0
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        ZStack {
            // MARK: - Background
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.01, blue: 0.08),
                    Color(red: 0.05, green: 0.02, blue: 0.12),
                    Color(red: 0.02, green: 0.01, blue: 0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            CyberpunkGridView()
                .ignoresSafeArea()
            

            
            // MARK: - Main Content
            VStack(spacing: 0) {
                // Header
                CyberpunkHeader(userName: gameManager.userName)
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
                            
                            FullScreenLevelNode(
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
                
                Capsule()
                    .fill(barColor(state: state, isCurrent: isCurrent))
                    .frame(width: isCurrent ? 24 : 8, height: 4)
                    .shadow(color: isCurrent ? barColor(state: state, isCurrent: true).opacity(0.6) : .clear, radius: 4)
                    .animation(.easeInOut(duration: 0.3), value: current)
                    .onTapGesture {
                        if state != .locked {
                            withAnimation {
                                current = lessonId
                            }
                        }
                    }
            }
        }
    }
    
    func barColor(state: LessonNodeState, isCurrent: Bool) -> Color {
        if isCurrent {
            switch state {
            case .completed: return Color(red: 0.0, green: 1.0, blue: 0.4)
            case .current: return .cyan
            case .locked: return Color(red: 0.4, green: 0.3, blue: 0.6)
            }
        }
        switch state {
        case .completed: return Color(red: 0.0, green: 1.0, blue: 0.4).opacity(0.3)
        case .current: return .cyan.opacity(0.3)
        case .locked: return .white.opacity(0.1)
        }
    }
}

// MARK: - Full-Screen Level Node

struct FullScreenLevelNode: View {
    let lesson: Lesson
    let state: LessonNodeState
    let isLandscape: Bool
    @ObservedObject var gameManager = GameManager.shared
    @State private var ringRotation: Double = 0
    @State private var nodeGlow: Bool = false
    @State private var outerPulse: Bool = false
    
    var nodeAccent: Color {
        switch state {
        case .completed: return Color(red: 0.0, green: 1.0, blue: 0.4)
        case .current: return .cyan
        case .locked: return Color(red: 0.3, green: 0.2, blue: 0.5)
        }
    }
    
    // Dynamic sizing based on orientation
    var circleSize: CGFloat { isLandscape ? 160 : 200 }
    var ringSize: CGFloat { isLandscape ? 190 : 240 }
    var outerRingSize: CGFloat { isLandscape ? 220 : 270 }
    var iconSize: CGFloat { isLandscape ? 44 : 56 }
    var numberSize: CGFloat { isLandscape ? 52 : 64 }
    
    var body: some View {
        VStack(spacing: isLandscape ? 16 : 28) {
            // Module tag
            HStack(spacing: 6) {
                Rectangle()
                    .fill(nodeAccent.opacity(0.4))
                    .frame(width: 20, height: 1)
                Text("LEVEL \(String(format: "%02d", lesson.id))")
                    .font(.system(size: isLandscape ? 10 : 12, weight: .heavy, design: .monospaced))
                    .foregroundColor(nodeAccent)
                    .tracking(3)
                Rectangle()
                    .fill(nodeAccent.opacity(0.4))
                    .frame(width: 20, height: 1)
            }
            
            // The Big Circle
            Button(action: {
                if state != .locked {
                    HapticsManager.shared.selection()
                    gameManager.startLesson(lesson.id)
                }
            }) {
                ZStack {
                    // Outermost ambient pulse
                    if state != .locked {
                        Circle()
                            .stroke(nodeAccent.opacity(0.06), lineWidth: 1)
                            .frame(width: outerRingSize, height: outerRingSize)
                            .scaleEffect(outerPulse ? 1.15 : 1.0)
                            .opacity(outerPulse ? 0.0 : 0.6)
                    }
                    
                    // Rotating tech ring
                    if state == .current {
                        CyberpunkRing()
                            .stroke(nodeAccent.opacity(0.5), lineWidth: 2)
                            .frame(width: ringSize, height: ringSize)
                            .rotationEffect(.degrees(ringRotation))
                        
                        // Counter-rotating inner ring
                        CyberpunkRing()
                            .stroke(nodeAccent.opacity(0.2), lineWidth: 1)
                            .frame(width: ringSize - 20, height: ringSize - 20)
                            .rotationEffect(.degrees(-ringRotation * 0.6))
                    }
                    
                    // Glow halo
                    Circle()
                        .fill(nodeAccent.opacity(0.2))
                        .frame(width: circleSize + 30, height: circleSize + 30)
                        .blur(radius: state == .current ? 30 : 15)
                    
                    // Main circle border
                    Circle()
                        .stroke(nodeAccent.opacity(state == .locked ? 0.15 : 0.7), lineWidth: 3)
                        .frame(width: circleSize, height: circleSize)
                    
                    // Fill
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    nodeAccent.opacity(state == .locked ? 0.05 : 0.25),
                                    Color(red: 0.03, green: 0.02, blue: 0.1).opacity(0.9)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: circleSize / 2
                            )
                        )
                        .frame(width: circleSize - 4, height: circleSize - 4)
                    
                    // Inner detail rings
                    Circle()
                        .stroke(nodeAccent.opacity(0.15), lineWidth: 0.5)
                        .frame(width: circleSize * 0.7, height: circleSize * 0.7)
                    
                    Circle()
                        .stroke(nodeAccent.opacity(0.08), lineWidth: 0.5)
                        .frame(width: circleSize * 0.45, height: circleSize * 0.45)
                    
                    // Icon
                    if state == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: iconSize, weight: .bold))
                            .foregroundColor(nodeAccent)
                            .shadow(color: nodeAccent, radius: 12)
                    } else if state == .locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: iconSize * 0.7))
                            .foregroundColor(nodeAccent.opacity(0.3))
                    } else {
                        Text("\(lesson.id)")
                            .font(.system(size: numberSize, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: nodeAccent, radius: 16)
                    }
                }
            }
            .disabled(state == .locked)
            .buttonStyle(CyberpunkButtonStyle())
            
            // Title
            VStack(spacing: 8) {
                Text(lesson.title.uppercased())
                    .font(.system(size: isLandscape ? 16 : 20, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(state == .locked ? .white.opacity(0.25) : .white.opacity(0.9))
                    .lineLimit(2)
                    .frame(maxWidth: 280)
                
                // Status label
                if state == .current {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                        Text("START")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.cyan)
                            .shadow(color: .cyan.opacity(0.7), radius: 8)
                    )
                    .padding(.top, 4)
                } else if state == .completed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                        Text("COMPLETED")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(nodeAccent.opacity(0.6))
                    .padding(.top, 4)
                } else {
                    Text("LOCKED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1.0, green: 0.2, blue: 0.4).opacity(0.4))
                        .padding(.top, 4)
                }
            }
        }
        .onAppear {
            if state == .current {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    ringRotation = 360
                }
            }
            if state != .locked {
                withAnimation(.easeInOut(duration: 2).repeatForever()) {
                    outerPulse.toggle()
                }
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever()) {
                nodeGlow.toggle()
            }
        }
    }
}

// MARK: - Cyberpunk Header

struct CyberpunkHeader: View {
    let userName: String
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var glitchActive = false
    
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        VStack(spacing: isLandscape ? 4 : 8) {
            Text("LEARN ARKIT")
                .font(.system(size: isLandscape ? 18 : 24, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .tracking(2)
            
            Text("Build augmented reality experiences")
                .font(.system(size: isLandscape ? 9 : 11, weight: .medium, design: .monospaced))
                .foregroundColor(.cyan.opacity(0.5))
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, .cyan.opacity(0.4), .cyan.opacity(0.7), .cyan.opacity(0.4), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, isLandscape ? 120 : 60)
                .padding(.top, 1)
        }
        .onAppear { triggerGlitch() }
    }
    
    func triggerGlitch() {
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.05)) { glitchActive = true }
                try? await Task.sleep(nanoseconds: 80_000_000) // 0.08s
                withAnimation(.easeInOut(duration: 0.05)) { glitchActive = false }
            }
        }
    }
}

// MARK: - Cyberpunk Ring Shape

struct CyberpunkRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let segments = 8
        let gapAngle: Double = 8
        let segmentAngle = (360.0 / Double(segments)) - gapAngle
        
        for i in 0..<segments {
            let startAngle = Double(i) * (360.0 / Double(segments))
            let endAngle = startAngle + segmentAngle
            path.addArc(center: center, radius: radius,
                        startAngle: .degrees(startAngle), endAngle: .degrees(endAngle), clockwise: false)
        }
        return path
    }
}

// MARK: - Cyberpunk Grid Background

struct CyberpunkGridView: View {
    var body: some View {
        ZStack {
            Canvas { context, size in
                let spacing: CGFloat = 50
                let cols = Int(size.width / spacing) + 1
                let rows = Int(size.height / spacing) + 1
                
                for i in 0...cols {
                    var path = Path()
                    path.move(to: CGPoint(x: CGFloat(i) * spacing, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * spacing, y: size.height))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.04)), lineWidth: 0.5)
                }
                for i in 0...rows {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * spacing))
                    path.addLine(to: CGPoint(x: size.width, y: CGFloat(i) * spacing))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.04)), lineWidth: 0.5)
                }
                for col in 0...cols {
                    for row in 0...rows {
                        if (col + row) % 7 == 0 {
                            let pt = CGPoint(x: CGFloat(col) * spacing, y: CGFloat(row) * spacing)
                            context.fill(Path(ellipseIn: CGRect(x: pt.x - 1.5, y: pt.y - 1.5, width: 3, height: 3)),
                                         with: .color(Color.cyan.opacity(0.12)))
                        }
                    }
                }
            }
            
            RadialGradient(colors: [Color(red: 0.8, green: 0.0, blue: 0.6).opacity(0.06), .clear],
                           center: .topLeading, startRadius: 0, endRadius: 400)
            RadialGradient(colors: [Color.cyan.opacity(0.05), .clear],
                           center: .bottomTrailing, startRadius: 0, endRadius: 400)
        }
    }
}

// MARK: - Button Styles

struct CyberpunkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .brightness(configuration.isPressed ? 0.15 : 0.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct BouncyScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
