import SwiftUI

struct WelcomeView: View {
    @ObservedObject var gameManager = GameManager.shared
    @State private var animate = false
    @State private var isRevealing = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            
            BlueprintGridView()
                .opacity(isRevealing ? 0 : 1)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo / Title
                VStack(spacing: 15) {
                    ZStack {
                        Image(systemName: "square.3.layers.3d.down.right")
                            .font(.system(size: 80))
                            .foregroundColor(.cyan)
                            .shadow(color: .cyan, radius: 20)
                        
                        // Architectural Braces
                        Image(systemName: "angle")
                            .font(.system(size: 100))
                            .foregroundColor(.cyan.opacity(0.3))
                            .rotationEffect(.degrees(-45))
                    }
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                    
                    Text("ARchitect")
                        .font(.system(size: 60, weight: .black))
                        .foregroundStyle(LinearGradient(colors: [.cyan, .white], startPoint: .top, endPoint: .bottom))
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                        .kerning(4)
                    
                    Text("DESIGN • BUILD • LEARN")
                        .font(.caption.bold())
                        .foregroundColor(.cyan.opacity(0.7))
                        .kerning(2)
                    
                    Rectangle()
                        .fill(Color.cyan.opacity(0.5))
                        .frame(width: 150, height: 1)
                }
                .opacity(isRevealing ? 0 : 1)
                .offset(y: isRevealing ? -50 : 0)
                
                Spacer()
                
                // Start Button
                Button {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isRevealing = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        gameManager.startLesson(1)
                    }
                } label: {
                    HStack {
                        Text("INITIALIZE PROTOCOL")
                            .font(.headline.bold())
                        Image(systemName: "terminal")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        ZStack {
                            Color.cyan.opacity(0.2)
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan, lineWidth: 2)
                        }
                    )
                    .foregroundColor(.cyan)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 60)
                .opacity(isRevealing ? 0 : 1)
                .scaleEffect(isRevealing ? 0.9 : 1.0)
                
                Spacer()
            }
            .blur(radius: isRevealing ? 20 : 0)
        }
        .onAppear {
            animate = true
        }
    }
}
