//
//  Flight.swift
//  AirEase
//
//  Flight Base Model
//

import Foundation

struct Flight: Codable, Identifiable, Hashable {
    let id: String
    let flightNumber: String
    let airline: String
    let airlineCode: String
    let departureCity: String
    let departureCityCode: String
    let departureAirport: String
    let departureAirportCode: String
    let departureTime: Date
    let arrivalCity: String
    let arrivalCityCode: String
    let arrivalAirport: String
    let arrivalAirportCode: String
    let arrivalTime: Date
    let durationMinutes: Int
    let stops: Int
    let stopCities: [String]?
    let cabin: String
    let aircraftModel: String?
    let price: Double
    let currency: String
    let seatsRemaining: Int?
    
    // Computed properties
    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }
    
    var formattedDepartureTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: departureTime)
    }
    
    var formattedArrivalTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: arrivalTime)
    }
    
    var formattedPrice: String {
        return "¥\(Int(price))"
    }
    
    var stopsDescription: String {
        if stops == 0 {
            return "Nonstop"
        } else if stops == 1 {
            if let cities = stopCities, !cities.isEmpty {
                return "Via \(cities[0])"
            }
            return "1 stop"
        } else {
            return "\(stops) stops"
        }
    }
}

// MARK: - Sample Data for Previews
extension Flight {
    static let sample = Flight(
        id: "sample-1",
        flightNumber: "CA1234",
        airline: "Air China",
        airlineCode: "CA",
        departureCity: "Beijing",
        departureCityCode: "PEK",
        departureAirport: "Capital International Airport",
        departureAirportCode: "PEK",
        departureTime: Date(),
        arrivalCity: "Shanghai",
        arrivalCityCode: "SHA",
        arrivalAirport: "Hongqiao International Airport",
        arrivalAirportCode: "SHA",
        arrivalTime: Date().addingTimeInterval(3600 * 2.5),
        durationMinutes: 150,
        stops: 0,
        stopCities: nil,
        cabin: "Economy",
        aircraftModel: "Boeing 787-9",
        price: 1280,
        currency: "CNY",
        seatsRemaining: 23
    )
}
