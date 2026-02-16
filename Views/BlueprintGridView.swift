import SwiftUI

struct BlueprintGridView: View {
    let gridPadding: CGFloat = 40
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Main Grid
            Canvas { context, size in
                let columns = Int(size.width / gridPadding) + 1
                let rows = Int(size.height / gridPadding) + 1
                
                for i in 0...columns {
                    var path = Path()
                    path.move(to: CGPoint(x: CGFloat(i) * gridPadding, y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(i) * gridPadding, y: size.height))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.1)), lineWidth: 1)
                }
                
                for i in 0...rows {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: CGFloat(i) * gridPadding))
                    path.addLine(to: CGPoint(x: size.width, y: CGFloat(i) * gridPadding))
                    context.stroke(path, with: .color(Color.cyan.opacity(0.1)), lineWidth: 1)
                }
            }
            
            // Pulsing Scan Line
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .cyan.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 100)
                    .offset(y: offset)
                    .onAppear {
                        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                            offset = geo.size.height
                        }
                    }
            }
        }
    }
}
