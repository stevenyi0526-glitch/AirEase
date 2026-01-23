//
//  ScoringService.swift
//  AirEase
//
//  Scoring Calculation Service
//

import Foundation

final class ScoringService {
    static let shared = ScoringService()
    
    private init() {}
    
    /// Recalculate flight overall score based on user persona
    func recalculateScore(for flightWithScore: FlightWithScore, persona: UserPersona) -> FlightScore {
        let dimensions = flightWithScore.score.dimensions
        let weights = persona.scoreWeights
        
        let newOverallScore = weights.weightedScore(dimensions: dimensions)
        let roundedScore = (newOverallScore * 10).rounded() / 10 // Round to one decimal place
        
        return FlightScore(
            overallScore: roundedScore,
            dimensions: dimensions,
            highlights: flightWithScore.score.highlights,
            explanations: flightWithScore.score.explanations,
            personaWeightsApplied: persona.rawValue
        )
    }
    
    /// Batch recalculate scores for multiple flights
    func recalculateScores(for flights: [FlightWithScore], persona: UserPersona) -> [FlightWithScore] {
        return flights.map { flightWithScore in
            let newScore = recalculateScore(for: flightWithScore, persona: persona)
            return FlightWithScore(
                flight: flightWithScore.flight,
                score: newScore,
                facilities: flightWithScore.facilities
            )
        }
    }
    
    /// Generate radar chart data from dimension scores
    func radarChartData(from dimensions: ScoreDimensions) -> [RadarChartDataPoint] {
        return [
            RadarChartDataPoint(label: "Safety", value: dimensions.safety, maxValue: 10),
            RadarChartDataPoint(label: "Comfort", value: dimensions.comfort, maxValue: 10),
            RadarChartDataPoint(label: "Service", value: dimensions.service, maxValue: 10),
            RadarChartDataPoint(label: "Value", value: dimensions.value, maxValue: 10)
        ]
    }
    
    /// Generate weighted score breakdown for visualization
    func weightedScoreBreakdown(dimensions: ScoreDimensions, weights: ScoreWeights) -> [WeightedScoreItem] {
        return [
            WeightedScoreItem(
                dimension: "Safety",
                icon: "shield.fill",
                score: dimensions.safety,
                weight: weights.safety,
                weightedScore: dimensions.safety * weights.safety
            ),
            WeightedScoreItem(
                dimension: "Comfort",
                icon: "chair.lounge.fill",
                score: dimensions.comfort,
                weight: weights.comfort,
                weightedScore: dimensions.comfort * weights.comfort
            ),
            WeightedScoreItem(
                dimension: "Service",
                icon: "person.crop.circle.fill",
                score: dimensions.service,
                weight: weights.service,
                weightedScore: dimensions.service * weights.service
            ),
            WeightedScoreItem(
                dimension: "Value",
                icon: "dollarsign.circle.fill",
                score: dimensions.value,
                weight: weights.value,
                weightedScore: dimensions.value * weights.value
            )
        ]
    }
}

// MARK: - Weighted Score Item
struct WeightedScoreItem: Identifiable {
    let id = UUID()
    let dimension: String
    let icon: String
    let score: Double
    let weight: Double
    let weightedScore: Double
    
    var weightPercentage: Int {
        Int(weight * 100)
    }
}

// MARK: - Radar Chart Data
struct RadarChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let maxValue: Double
    
    var normalizedValue: Double {
        return value / maxValue
    }
}
