import SwiftUI

// MARK: - Deep Space Starfield
// Phase 1: Stars streak fast (warp entry ~2s)
// Phase 2: Stars fade out, leaving pure black void

struct StarfieldBackground: View {
    @State private var warpPhase: CGFloat = 0     // 0 → 1 over ~2s
    @State private var fadeOut: Double = 1.0       // fades to 0 after warp
    
    // Pre-baked star positions
    private let stars: [StaticStar] = {
        var result: [StaticStar] = []
        for _ in 0..<60 {
            result.append(StaticStar(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 0.8...3.0),
                baseOpacity: Double.random(in: 0.4...1.0),
                layer: Int.random(in: 0...2)
            ))
        }
        return result
    }()
    
    var body: some View {
        ZStack {
            // Pure black void (always)
            Color.black.ignoresSafeArea()
            
            // Stars — visible during warp, then fade out
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                Canvas { context, size in
                    for star in stars {
                        let finalX = star.x * w
                        let finalY = star.y * h
                        
                        let layerSpeed: CGFloat = CGFloat(star.layer + 1) * 0.5
                        let warpOffset = (1.0 - warpPhase) * h * layerSpeed
                        let drawY = finalY - warpOffset
                        
                        // Streak during warp
                        let streakFactor = (1.0 - warpPhase) * CGFloat(star.layer + 1) * 10
                        let streakLen = star.size + streakFactor
                        
                        guard drawY > -30 && drawY < h + 30 else { continue }
                        
                        let rect = CGRect(
                            x: finalX - star.size / 2,
                            y: drawY - streakLen / 2,
                            width: star.size,
                            height: streakLen
                        )
                        
                        let opacity = star.baseOpacity * fadeOut
                        context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
                    }
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            // Fast warp in (easeOut = fast start, decelerating)
            withAnimation(.easeOut(duration: 1.8)) {
                warpPhase = 1.0
            }
            // After warp, fade stars out
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.8)) {
                    fadeOut = 0.0
                }
            }
        }
    }
}

// Lightweight data struct
private struct StaticStar {
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let baseOpacity: Double
    let layer: Int
}
