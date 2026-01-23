//
//  ScoreExplanationView.swift
//  AirEase
//
//  Score Explanation Card Component
//

import SwiftUI

struct ScoreExplanationCard: View {
    let dimension: String
    let score: Double
    let explanations: [ScoreExplanation]
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button(action: onTap) {
                HStack {
                    Text(dimension)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    // Score pill
                    Text(String(format: "%.1f", score))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.scoreColor(for: score))
                        .cornerRadius(8)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(isExpanded ? 12 : 12)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(explanations) { explanation in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: explanation.isPositive ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(explanation.isPositive ? .green : .orange)
                                .font(.subheadline)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(explanation.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(explanation.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    if explanations.isEmpty {
                        Text("No detailed analysis available")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color(UIColor.tertiarySystemBackground).opacity(0.5))
                .cornerRadius(12)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        ScoreExplanationCard(
            dimension: "Comfort",
            score: 8.2,
            explanations: [
                ScoreExplanation(
                    dimension: "comfort",
                    title: "Spacious Seating",
                    detail: "Seat pitch of 34 inches, above industry average",
                    isPositive: true
                ),
                ScoreExplanation(
                    dimension: "comfort",
                    title: "Wide-body Aircraft",
                    detail: "Boeing 787-9 features a wide-body design with a more spacious and quiet cabin",
                    isPositive: true
                )
            ],
            isExpanded: true,
            onTap: {}
        )
        
        ScoreExplanationCard(
            dimension: "Safety",
            score: 9.0,
            explanations: [],
            isExpanded: false,
            onTap: {}
        )
    }
    .padding()
}
