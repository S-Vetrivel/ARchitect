import SwiftUI

struct LevelMapView: View {
    // Keeping your existing managers
    @ObservedObject var gameManager = GameManager.shared
    @State private var showBadges = false
    
    // Animation state for the background blobs
    @State private var animateBlobs = false
    
    var body: some View {
        ZStack {
            // MARK: - Layer 1: Animated Ambient Background
            GeometryReader { proxy in
                ZStack {
                    Color(uiColor: .systemGroupedBackground) // Adaptive light/dark base
                        .ignoresSafeArea()
                    
                    // Blob 1 (Purple/Blue)
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: animateBlobs ? -100 : 100, y: animateBlobs ? -150 : -50)
                    
                    // Blob 2 (Cyan/Teal)
                    Circle()
                        .fill(Color.cyan.opacity(0.4))
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .offset(x: animateBlobs ? 150 : -50, y: animateBlobs ? 200 : 0)
                    
                    // Blob 3 (Indigo)
                    Circle()
                        .fill(Color.indigo.opacity(0.3))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: animateBlobs ? -50 : 120, y: animateBlobs ? 300 : 100)
                }
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                        animateBlobs.toggle()
                    }
                }
            }
            
            // MARK: - Layer 2: Main Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- Modern Header ---
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(gameManager.userName)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .primaryGradient()
                        }
                        Spacer()
                        
                        // Level Pill
                        HStack(spacing: 12) {
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("LEVEL")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                Text("\(gameManager.currentLevelInfo.level)")
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .foregroundColor(.blue)
                            }
                            
                            // Avatar Placeholder
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44)
                                .foregroundColor(.gray.opacity(0.3))
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // --- Glass Stats Row ---
                    HStack(spacing: 15) {
                        // You can hook these up to real data if you have it
                        GlassStatPill(icon: "checkmark.circle.fill", title: "Completed", value: "3", color: .green)
                        GlassStatPill(icon: "lock.open.fill", title: "Unlocked", value: "1", color: .orange)
                        GlassStatPill(icon: "star.fill", title: "Badges", value: "12", color: .yellow)
                    }
                    .padding(.horizontal)
                    
                    // --- Mission List ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("MISSION PROTOCOLS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(Array(LessonManager.shared.lessons.enumerated()), id: \.element.id) { index, lesson in
                            GlassMissionRow(
                                lesson: lesson,
                                isUnlocked: isLessonUnlocked(id: lesson.id),
                                isCompleted: gameManager.isLessonCompleted(id: lesson.id)
                            )
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            
            // MARK: - Layer 3: Floating Footer
            VStack {
                Spacer()
                Button(action: { showBadges.toggle() }) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.headline)
                        Text("View Service Record")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                            .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    )
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showBadges) {
            BadgeGalleryView()
        }
    }
    
    // Helper to keep your existing logic
    func isLessonUnlocked(id: Int) -> Bool {
        if id == 1 { return true }
        return gameManager.isLessonCompleted(id: id - 1)
    }
}

// MARK: - Subviews

struct GlassMissionRow: View {
    let lesson: Lesson
    let isUnlocked: Bool
    let isCompleted: Bool
    @ObservedObject var gameManager = GameManager.shared
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                gameManager.startLesson(lesson.id)
            }
        }) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(statusColor)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("SECTOR 0\(lesson.id)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.1))
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                    
                    Text(lesson.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(isUnlocked ? .primary : .gray)
                        .multilineTextAlignment(.leading)
                    
                    // You can uncomment this if your Lesson model has a description
                    // Text(lesson.description)
                    //    .font(.caption)
                    //    .foregroundColor(.secondary)
                    //    .lineLimit(1)
                }
                
                Spacer()
                
                // Action Arrow
                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(16)
            .background(.ultraThinMaterial) // The key Glass effect
            .cornerRadius(24)
            // Frost border
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
            .opacity(isUnlocked ? 1 : 0.6)
            .scaleEffect(isUnlocked ? 1 : 0.98)
            .saturation(isUnlocked ? 1 : 0)
        }
        .disabled(!isUnlocked)
        .buttonStyle(BouncyButtonStyle())
    }
    
    var statusColor: Color {
        if isCompleted { return .green }
        if isUnlocked { return .blue }
        return .gray
    }
    
    var statusIcon: String {
        if isCompleted { return "checkmark" }
        if isUnlocked { return "play.fill" }
        return "lock.fill"
    }
}

struct GlassStatPill: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .font(.caption)
            
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Utilities

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension Text {
    func primaryGradient() -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: [.primary, .blue.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}