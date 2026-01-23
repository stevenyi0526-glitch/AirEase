//
//  FlightScore.swift
//  AirEase
//
//  Flight Score Model
//

import Foundation
import SwiftUI

struct FlightScore: Codable, Hashable {
    let overallScore: Double
    let dimensions: ScoreDimensions
    let highlights: [String]
    let explanations: [ScoreExplanation]
    let personaWeightsApplied: String
    
    var formattedScore: String {
        return String(format: "%.1f", overallScore)
    }
    
    var scoreColor: Color {
        switch overallScore {
        case 8.5...10.0:
            return Color(red: 0.133, green: 0.773, blue: 0.369) // Green #22C55E
        case 7.0..<8.5:
            return Color(red: 0.231, green: 0.510, blue: 0.965) // Blue #3B82F6
        case 5.0..<7.0:
            return Color(red: 0.961, green: 0.620, blue: 0.043) // Orange #F59E0B
        default:
            return Color(red: 0.420, green: 0.451, blue: 0.498) // Gray #6B7280
        }
    }
}

struct ScoreDimensions: Codable, Hashable {
    let safety: Double      // Safety
    let comfort: Double     // Comfort
    let service: Double     // Service
    let value: Double       // Value for Money
    
    var asArray: [(String, Double)] {
        return [
            ("Safety", safety),
            ("Comfort", comfort),
            ("Service", service),
            ("Value", value)
        ]
    }
}

struct ScoreExplanation: Codable, Identifiable, Hashable {
    var id: String { "\(dimension)-\(title)" }
    let dimension: String
    let title: String
    let detail: String
    let isPositive: Bool
}

// MARK: - Sample Data
extension FlightScore {
    static let sample = FlightScore(
        overallScore: 8.5,
        dimensions: ScoreDimensions(
            safety: 9.0,
            comfort: 8.2,
            service: 8.0,
            value: 7.5
        ),
        highlights: ["WiFi", "Spacious Seats", "Nonstop"],
        explanations: [
            ScoreExplanation(
                dimension: "safety",
                title: "Excellent Airline Safety Rating",
                detail: "Air China has an excellent safety record with no major incidents in the past 10 years",
                isPositive: true
            ),
            ScoreExplanation(
                dimension: "safety",
                title: "Nonstop Flight",
                detail: "No layovers, reducing travel uncertainty",
                isPositive: true
            ),
            ScoreExplanation(
                dimension: "comfort",
                title: "Ample Seat Space",
                detail: "34-inch seat pitch, above industry average",
                isPositive: true
            ),
            ScoreExplanation(
                dimension: "comfort",
                title: "Wide-body Aircraft",
                detail: "Boeing 787-9 features a wide cabin design for a more spacious and quiet experience",
                isPositive: true
            ),
            ScoreExplanation(
                dimension: "service",
                title: "In-flight Meals",
                detail: "Full meal service with hot food and beverages",
                isPositive: true
            ),
            ScoreExplanation(
                dimension: "value",
                title: "Good Value",
                detail: "Current price is 5% below the route average",
                isPositive: true
            )
        ],
        personaWeightsApplied: "business"
    )
}
