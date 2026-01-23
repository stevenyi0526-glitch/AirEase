//
//  RadarChartView.swift
//  AirEase
//
//  Radar Chart Component - Drawn using SwiftUI Canvas
//

import SwiftUI

struct RadarChartView: View {
    let dataPoints: [RadarChartDataPoint]
    
    private let gridLevels = 5
    private let primaryColor = Color.aireasePurple
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40
            
            ZStack {
                // Grid circles
                ForEach(1...gridLevels, id: \.self) { level in
                    let levelRadius = radius * CGFloat(level) / CGFloat(gridLevels)
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: levelRadius * 2, height: levelRadius * 2)
                }
                
                // Axis lines and labels
                ForEach(0..<dataPoints.count, id: \.self) { index in
                    let angle = angleForIndex(index)
                    let endpoint = pointOnCircle(center: center, radius: radius, angle: angle)
                    let labelPoint = pointOnCircle(center: center, radius: radius + 25, angle: angle)
                    
                    // Axis line
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: endpoint)
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    
                    // Label
                    VStack(spacing: 2) {
                        Text(dataPoints[index].label)
                            .font(.caption)
                            .fontWeight(.medium)
                        Text(String(format: "%.1f", dataPoints[index].value))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .position(labelPoint)
                }
                
                // Data polygon
                Canvas { context, size in
                    var path = Path()
                    
                    for (index, point) in dataPoints.enumerated() {
                        let angle = angleForIndex(index)
                        let pointRadius = radius * CGFloat(point.normalizedValue)
                        let canvasCenter = CGPoint(x: size.width / 2, y: size.height / 2)
                        let position = pointOnCircle(center: canvasCenter, radius: pointRadius, angle: angle)
                        
                        if index == 0 {
                            path.move(to: position)
                        } else {
                            path.addLine(to: position)
                        }
                    }
                    path.closeSubpath()
                    
                    // Fill
                    context.fill(path, with: .color(primaryColor.opacity(0.3)))
                    
                    // Stroke
                    context.stroke(path, with: .color(primaryColor), lineWidth: 2)
                }
                
                // Data points
                ForEach(0..<dataPoints.count, id: \.self) { index in
                    let angle = angleForIndex(index)
                    let pointRadius = radius * CGFloat(dataPoints[index].normalizedValue)
                    let position = pointOnCircle(center: center, radius: pointRadius, angle: angle)
                    
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 8, height: 8)
                        .position(position)
                }
            }
        }
    }
    
    private func angleForIndex(_ index: Int) -> Double {
        let anglePerSlice = 2 * Double.pi / Double(dataPoints.count)
        // Start from top (negative Y direction)
        return -Double.pi / 2 + anglePerSlice * Double(index)
    }
    
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}

// MARK: - Preview
#Preview {
    RadarChartView(dataPoints: [
        RadarChartDataPoint(label: "Safety", value: 9.0, maxValue: 10),
        RadarChartDataPoint(label: "Comfort", value: 8.2, maxValue: 10),
        RadarChartDataPoint(label: "Service", value: 8.0, maxValue: 10),
        RadarChartDataPoint(label: "Value", value: 7.5, maxValue: 10)
    ])
    .frame(height: 250)
    .padding()
}
