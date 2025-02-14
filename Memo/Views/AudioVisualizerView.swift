import SwiftUI

struct AudioVisualizerView: View {
    let levels: [CGFloat]
    let active: Bool
    
    var body: some View {
        Canvas { context, size in
            let barWidth: CGFloat = 2.5  // Even thinner bars
            let spacing: CGFloat = 1.5    // More spacing
            let midY = size.height / 2
            let maxBars = Int(size.width / (barWidth + spacing))
            let displayLevels = Array(levels.suffix(maxBars))
            
            for (index, level) in displayLevels.enumerated() {
                let amplifiedLevel = pow(level, 0.5) * 3.0  // More amplification
                let normalizedLevel = min(amplifiedLevel * size.height / 2, size.height / 2 - 2)
                let x = CGFloat(index) * (barWidth + spacing)
                
                // Draw upper bar
                let upperPath = Path { path in
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: midY - normalizedLevel))
                    path.addArc(
                        center: CGPoint(x: x + barWidth/2, y: midY - normalizedLevel),
                        radius: barWidth/2,
                        startAngle: .degrees(-180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                    path.addLine(to: CGPoint(x: x + barWidth, y: midY))
                }
                
                let lowerPath = Path { path in
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: midY + normalizedLevel))
                    path.addArc(
                        center: CGPoint(x: x + barWidth/2, y: midY + normalizedLevel),
                        radius: barWidth/2,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: true
                    )
                    path.addLine(to: CGPoint(x: x + barWidth, y: midY))
                }
                
                let color = active ? 
                    Color.red.opacity(0.6 + level * 0.4) : 
                    Color.gray.opacity(0.4 + level * 0.2)
                
                context.stroke(upperPath, with: .color(color))
                context.stroke(lowerPath, with: .color(color))
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Preview with random levels
        AudioVisualizerView(
            levels: (0..<100).map { _ in CGFloat.random(in: 0...1) },
            active: true
        )
        .frame(height: 100)  // Increased height
        .padding()
        
        // Preview with sine wave
        AudioVisualizerView(
            levels: (0..<100).map { i in
                abs(sin(Double(i) * 0.1)) * 0.8 + 0.2
            },
            active: true
        )
        .frame(height: 100)  // Increased height
        .padding()
    }
} 