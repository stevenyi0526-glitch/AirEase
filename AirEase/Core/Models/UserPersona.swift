//
//  UserPersona.swift
//  AirEase
//
//  User Persona Model
//

import Foundation
import SwiftUI

enum UserPersona: String, Codable, CaseIterable {
    case business = "business"
    case family = "family"
    case student = "student"
    
    var displayName: String {
        switch self {
        case .business: return "Business Travel"
        case .family: return "Family Trip"
        case .student: return "Student"
        }
    }
    
    var shortName: String {
        switch self {
        case .business: return "Business Pro"
        case .family: return "Family Traveler"
        case .student: return "Student Saver"
        }
    }
    
    var description: String {
        switch self {
        case .business: return "Time is precious, comfort and efficiency"
        case .family: return "Safety first, convenient travel"
        case .student: return "Budget-conscious, best value"
        }
    }
    
    var iconName: String {
        switch self {
        case .business: return "briefcase.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .student: return "backpack.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .business: return .blue
        case .family: return .orange
        case .student: return .green
        }
    }
    
    var scoreWeights: ScoreWeights {
        switch self {
        case .business:
            return ScoreWeights(safety: 0.25, comfort: 0.35, service: 0.25, value: 0.15)
        case .family:
            return ScoreWeights(safety: 0.35, comfort: 0.30, service: 0.25, value: 0.10)
        case .student:
            return ScoreWeights(safety: 0.20, comfort: 0.20, service: 0.15, value: 0.45)
        }
    }
}

struct ScoreWeights: Codable {
    let safety: Double
    let comfort: Double
    let service: Double
    let value: Double
    
    func weightedScore(dimensions: ScoreDimensions) -> Double {
        return (dimensions.safety * safety +
                dimensions.comfort * comfort +
                dimensions.service * service +
                dimensions.value * value)
    }
}
