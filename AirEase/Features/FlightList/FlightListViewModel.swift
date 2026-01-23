//
//  FlightListViewModel.swift
//  AirEase
//
//  Flight List ViewModel
//

import Foundation
import SwiftUI

enum FlightSortOption: String, CaseIterable {
    case score = "Best Experience"
    case price = "Lowest Price"
    case duration = "Shortest Duration"
}

@Observable
final class FlightListViewModel {
    // Data
    var flights: [FlightWithScore] = []
    var filteredFlights: [FlightWithScore] = []
    
    // Query
    let searchQuery: SearchQuery
    
    // Sort
    var selectedSort: FlightSortOption = .score
    
    // UI State
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String = ""
    
    // Navigation
    var selectedFlight: FlightWithScore?
    
    // Dependencies
    private let flightService: FlightServiceProtocol
    private let scoringService = ScoringService.shared
    private let persistence = PersistenceService.shared
    
    init(searchQuery: SearchQuery) {
        self.searchQuery = searchQuery
        self.flightService = FlightServiceFactory.create()
    }
    
    var resultCountText: String {
        if filteredFlights.isEmpty {
            return "No flights found"
        }
        return "\(filteredFlights.count) flights found"
    }
    
    var routeText: String {
        return "\(searchQuery.fromCity) → \(searchQuery.toCity)"
    }
    
    var dateAndCabinText: String {
        return "\(searchQuery.formattedDate) · \(searchQuery.cabin)"
    }
    
    // MARK: - Actions
    
    @MainActor
    func loadFlights() async {
        isLoading = true
        hasError = false
        
        do {
            var results = try await flightService.searchFlights(query: searchQuery)
            
            // Recalculate scores based on user persona
            if let persona = persistence.userPersona {
                results = scoringService.recalculateScores(for: results, persona: persona)
            }
            
            flights = results
            applySorting()
        } catch {
            hasError = true
            errorMessage = (error as? FlightServiceError)?.errorDescription ?? "Failed to load, please try again"
            flights = []
            filteredFlights = []
        }
        
        isLoading = false
    }
    
    func selectSort(_ option: FlightSortOption) {
        selectedSort = option
        applySorting()
    }
    
    private func applySorting() {
        switch selectedSort {
        case .score:
            filteredFlights = flights.sorted { $0.score.overallScore > $1.score.overallScore }
        case .price:
            filteredFlights = flights.sorted { $0.flight.price < $1.flight.price }
        case .duration:
            filteredFlights = flights.sorted { $0.flight.durationMinutes < $1.flight.durationMinutes }
        }
    }
    
    func selectFlight(_ flight: FlightWithScore) {
        selectedFlight = flight
    }
}
