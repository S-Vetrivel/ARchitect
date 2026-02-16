import SwiftUI

struct BadgeGalleryView: View {
    @ObservedObject var gameManager = GameManager.shared
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color(red: 0.1, green: 0.15, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
            BlueprintGridView().opacity(0.2)
            
            VStack {
                HStack {
                    Text("ARCHITECTURAL ACHIEVEMENTS")
                        .font(.headline)
                        .foregroundColor(.white)
                        .kerning(2)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Badge.allBadges) { badge in
                            BadgeItemView(
                                badge: badge,
                                isUnlocked: gameManager.isBadgeUnlocked(id: badge.id)
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .padding(20)
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }
}

struct BadgeItemView: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Hexagon()
                    .fill(isUnlocked ? Color.cyan.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 90)
                
                Hexagon()
                    .stroke(isUnlocked ? Color.cyan : Color.gray, lineWidth: 2)
                    .frame(width: 80, height: 90)
                
                Image(systemName: badge.iconName)
                    .font(.largeTitle)
                    .foregroundColor(isUnlocked ? .cyan : .gray)
            }
            .grayscale(isUnlocked ? 0 : 1)
            .opacity(isUnlocked ? 1 : 0.5)
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.caption.bold())
                    .foregroundColor(isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                
                if isUnlocked {
                    Text("+\(badge.xpReward) XP")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let x = rect.midX
        let y = rect.midY
        let side = width / 2
        
        path.move(to: CGPoint(x: x, y: y - height / 2))
        path.addLine(to: CGPoint(x: x + side, y: y - height / 4))
        path.addLine(to: CGPoint(x: x + side, y: y + height / 4))
        path.addLine(to: CGPoint(x: x, y: y + height / 2))
        path.addLine(to: CGPoint(x: x - side, y: y + height / 4))
        path.addLine(to: CGPoint(x: x - side, y: y - height / 4))
        path.closeSubpath()
        return path
    }
}
