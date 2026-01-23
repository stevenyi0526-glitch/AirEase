//
//  FlightDetailViewModel.swift
//  AirEase
//
//  Flight Detail ViewModel
//

import Foundation
import SwiftUI

@Observable
final class FlightDetailViewModel {
    // Data
    let flightWithScore: FlightWithScore
    var flightDetail: FlightDetail?
    var priceHistory: PriceHistory?
    
    // UI State
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String = ""
    
    // Expanded sections
    var expandedDimensions: Set<String> = []
    
    // Actions
    var showShareSheet: Bool = false
    var showPriceAlert: Bool = false
    var showBookingAlert: Bool = false
    
    // Dependencies
    private let flightService: FlightServiceProtocol
    private let persistence = PersistenceService.shared
    
    init(flightWithScore: FlightWithScore) {
        self.flightWithScore = flightWithScore
        self.flightService = FlightServiceFactory.create()
    }
    
    var flight: Flight { flightWithScore.flight }
    var score: FlightScore { flightWithScore.score }
    var facilities: FlightFacilities { flightWithScore.facilities }
    
    var isFavorite: Bool {
        persistence.isFavorite(flightId: flight.id)
    }
    
    var personaDescription: String {
        if let persona = persistence.userPersona {
            return "Based on your \(L10n.personaName(persona)) profile"
        }
        return "Overall Score"
    }
    
    var personaDescriptionEN: String {
        if let persona = persistence.userPersona {
            switch persona {
            case .business:
                return "Based on your Business Traveler profile"
            case .family:
                return "Based on your Family Travel profile"
            case .student:
                return "Based on your Student Saver profile"
            }
        }
        return "Overall Score"
    }
    
    var scoreGradeText: String {
        switch score.overallScore {
        case 8.5...10.0:
            return "Excellent"
        case 7.0..<8.5:
            return "Very Good"
        case 5.0..<7.0:
            return "Average"
        default:
            return "Below Average"
        }
    }
    
    var highlightsEN: [String] {
        score.highlights.map { highlight in
            switch highlight {
            case "机上WiFi": return "WiFi"
            case "宽敞座椅": return "Spacious Seats"
            case "直飞": return "Direct Flight"
            case "座位电源": return "Power Outlet"
            case "个人娱乐": return "Entertainment"
            case "高评分": return "Top Rated"
            case "高性价比": return "Great Value"
            case "宽体客机": return "Wide-body"
            case "超值价格": return "Best Price"
            default: return highlight
            }
        }
    }
    
    var boardingTimeString: String {
        let boardingTime = flight.departureTime.addingTimeInterval(-45 * 60)
        return boardingTime.timeString
    }
    
    var baggageTimeString: String {
        let baggageTime = flight.arrivalTime.addingTimeInterval(15 * 60)
        return baggageTime.timeString
    }
    
    var inflightServicesEN: String {
        var services: [String] = []
        
        if facilities.mealIncluded == true {
            services.append("Meal service")
        }
        if facilities.hasWifi == true {
            services.append("WiFi available")
        }
        if facilities.hasIFE == true {
            services.append("In-flight entertainment")
        }
        
        return services.isEmpty ? "Comfortable flight" : services.joined(separator: " • ")
    }
    
    var radarData: [RadarChartDataPoint] {
        ScoringService.shared.radarChartData(from: score.dimensions)
    }
    
    var weightedScoreBreakdown: [WeightedScoreItem] {
        let weights = persistence.userPersona?.scoreWeights ?? ScoreWeights(safety: 0.25, comfort: 0.25, service: 0.25, value: 0.25)
        return ScoringService.shared.weightedScoreBreakdown(dimensions: score.dimensions, weights: weights)
    }
    
    var currentWeights: ScoreWeights {
        persistence.userPersona?.scoreWeights ?? ScoreWeights(safety: 0.25, comfort: 0.25, service: 0.25, value: 0.25)
    }

    // Group explanations by dimension
    var safetyExplanations: [ScoreExplanation] {
        score.explanations.filter { $0.dimension == "safety" }
    }
    
    var comfortExplanations: [ScoreExplanation] {
        score.explanations.filter { $0.dimension == "comfort" }
    }
    
    var serviceExplanations: [ScoreExplanation] {
        score.explanations.filter { $0.dimension == "service" }
    }
    
    var valueExplanations: [ScoreExplanation] {
        score.explanations.filter { $0.dimension == "value" }
    }
    
    // MARK: - Actions
    
    @MainActor
    func loadDetails() async {
        isLoading = true
        hasError = false
        
        do {
            let detail = try await flightService.getFlightDetail(flightId: flight.id)
            flightDetail = detail
            priceHistory = detail.priceHistory
        } catch {
            // Use local data as fallback
            priceHistory = PriceHistory.sample
        }
        
        isLoading = false
    }
    
    func toggleDimension(_ dimension: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedDimensions.contains(dimension) {
                expandedDimensions.remove(dimension)
            } else {
                expandedDimensions.insert(dimension)
            }
        }
    }
    
    func isDimensionExpanded(_ dimension: String) -> Bool {
        expandedDimensions.contains(dimension)
    }
    
    func toggleFavorite() {
        persistence.toggleFavorite(flightId: flight.id)
    }
    
    func showPriceMonitoring() {
        showPriceAlert = true
    }
    
    func showBooking() {
        showBookingAlert = true
    }
}
