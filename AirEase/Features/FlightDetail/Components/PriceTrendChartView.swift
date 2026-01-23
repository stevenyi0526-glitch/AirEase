//
//  PriceTrendChartView.swift
//  AirEase
//
//  Price Trend Chart Component - Using Swift Charts
//

import SwiftUI
import Charts

struct PriceTrendChartView: View {
    let priceHistory: PriceHistory
    private var isEnglish: Bool { LanguageManager.shared.isEnglish }
    
    var body: some View {
        Chart {
            // Price line
            ForEach(priceHistory.points) { point in
                LineMark(
                    x: .value(isEnglish ? "Date" : "日期", point.date),
                    y: .value(isEnglish ? "Price" : "价格", point.price)
                )
                .foregroundStyle(Color.aireasePurple.gradient)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value(isEnglish ? "Date" : "日期", point.date),
                    y: .value(isEnglish ? "Price" : "价格", point.price)
                )
                .foregroundStyle(Color.aireasePurple)
                .symbolSize(30)
            }
            
            // Current price reference line
            RuleMark(y: .value(isEnglish ? "Current Price" : "当前价格", priceHistory.currentPrice))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text(isEnglish ? "Current ¥\(Int(priceHistory.currentPrice))" : "当前 ¥\(Int(priceHistory.currentPrice))")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(4)
                }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let price = value.as(Double.self) {
                        Text("¥\(Int(price))")
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYScale(domain: priceHistory.minPrice * 0.95...priceHistory.maxPrice * 1.05)
    }
}

// MARK: - Preview
#Preview {
    PriceTrendChartView(priceHistory: .sample)
        .frame(height: 200)
        .padding()
}
