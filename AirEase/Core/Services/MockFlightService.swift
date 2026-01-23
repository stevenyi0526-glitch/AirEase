//
//  MockFlightService.swift
//  AirEase
//
//  Mock航班服务 - 用于开发和演示
//

import Foundation

final class MockFlightService: FlightServiceProtocol {
    
    private var mockFlights: [FlightWithScore] = []
    
    init() {
        loadMockData()
    }
    
    // MARK: - FlightServiceProtocol
    
    func searchFlights(query: SearchQuery) async throws -> [FlightWithScore] {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        
        // 过滤航班
        let filtered = mockFlights.filter { flightWithScore in
            let flight = flightWithScore.flight
            
            // 检查出发城市
            let matchesFrom = flight.departureCity.contains(query.fromCity) ||
                              query.fromCity.contains(flight.departureCity) ||
                              flight.departureCityCode == query.fromCity
            
            // 检查到达城市
            let matchesTo = flight.arrivalCity.contains(query.toCity) ||
                            query.toCity.contains(flight.arrivalCity) ||
                            flight.arrivalCityCode == query.toCity
            
            // 检查舱位
            let matchesCabin = flight.cabin == query.cabin
            
            return matchesFrom && matchesTo && matchesCabin
        }
        
        // 如果没有精确匹配，返回所有航班（演示用）
        if filtered.isEmpty {
            return mockFlights
        }
        
        return filtered
    }
    
    func getFlightDetail(flightId: String) async throws -> FlightDetail {
        // 模拟网络延迟
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3秒
        
        guard let flightWithScore = mockFlights.first(where: { $0.flight.id == flightId }) else {
            throw FlightServiceError.notFound
        }
        
        let priceHistory = generatePriceHistory(for: flightWithScore.flight)
        
        return FlightDetail(
            flight: flightWithScore.flight,
            score: flightWithScore.score,
            facilities: flightWithScore.facilities,
            priceHistory: priceHistory
        )
    }
    
    func getPriceHistory(flightId: String) async throws -> PriceHistory {
        guard let flightWithScore = mockFlights.first(where: { $0.flight.id == flightId }) else {
            throw FlightServiceError.notFound
        }
        
        return generatePriceHistory(for: flightWithScore.flight)
    }
    
    // MARK: - Private Methods
    
    private func loadMockData() {
        mockFlights = MockDataGenerator.generateFlights()
    }
    
    private func generatePriceHistory(for flight: Flight) -> PriceHistory {
        let calendar = Calendar.current
        let today = Date()
        
        var points: [PricePoint] = []
        let basePrice = flight.price
        let trends: [PriceTrend] = [.rising, .falling, .stable]
        let trend = trends.randomElement() ?? .stable
        
        // Generate more realistic price fluctuations with daily variations
        var previousPrice = basePrice
        let volatility = basePrice * 0.08 // 8% max daily change
        
        for i in (0..<7).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            var price: Double
            
            // Calculate base trend direction
            let trendFactor: Double
            switch trend {
            case .rising:
                // Overall rising trend: prices were lower in the past
                trendFactor = Double(7 - i) * (basePrice * 0.02) // 2% per day increase
            case .falling:
                // Overall falling trend: prices were higher in the past
                trendFactor = Double(i) * (basePrice * 0.025) // 2.5% per day from high
            case .stable:
                trendFactor = 0
            }
            
            // Add daily random fluctuation for realistic market behavior
            let dailyNoise = Double.random(in: -volatility...volatility)
            
            // Add some momentum from previous day
            let momentum = (previousPrice - basePrice) * 0.3
            
            switch trend {
            case .rising:
                price = basePrice - (basePrice * 0.15) + trendFactor + dailyNoise
            case .falling:
                price = basePrice + trendFactor + dailyNoise
            case .stable:
                price = basePrice + dailyNoise + momentum
            }
            
            // Ensure price stays within reasonable bounds (±20% of base)
            price = max(basePrice * 0.80, min(basePrice * 1.20, price))
            
            // Round to whole number
            price = round(price)
            
            points.append(PricePoint(date: date, price: price))
            previousPrice = price
        }
        
        // Make sure the last point (today) is close to current price
        if let lastIndex = points.indices.last {
            points[lastIndex] = PricePoint(date: today, price: basePrice)
        }
        
        return PriceHistory(
            flightId: flight.id,
            points: points,
            currentPrice: basePrice,
            trend: trend
        )
    }
}

// MARK: - Mock Data Generator
enum MockDataGenerator {
    
    static func generateFlights() -> [FlightWithScore] {
        let flightsData: [(String, String, String, String, String, Int, Int, Double, String?, Double, Bool?, Bool?, Int?, Bool?, String?, Bool?)] = [
            // flightNumber, airline, from, to, cabin, duration, stops, price, aircraft, score, wifi, power, pitch, ife, ifeType, meal
            ("CA1234", "Air China", "Beijing", "Shanghai", "Economy", 150, 0, 1280, "Boeing 787-9", 8.5, true, true, 34, true, "Personal Screen", true),
            ("MU5678", "China Eastern", "Beijing", "Shanghai", "Economy", 145, 0, 980, "Airbus A320", 7.2, false, true, 31, false, nil, true),
            ("CZ3456", "China Southern", "Beijing", "Shanghai", "Economy", 155, 0, 1150, "Boeing 737-800", 7.8, true, false, 32, true, "Shared Screen", true),
            ("HU7890", "Hainan Airlines", "Beijing", "Shanghai", "Economy", 160, 0, 890, "Airbus A330", 8.2, true, true, 33, true, "Personal Screen", true),
            ("3U8901", "Sichuan Airlines", "Beijing", "Shanghai", "Economy", 165, 0, 780, "Airbus A321", 6.5, nil, true, 30, false, nil, true),
            
            ("CA2345", "Air China", "Beijing", "Shanghai", "Business", 150, 0, 3580, "Boeing 787-9", 9.2, true, true, 42, true, "Personal Screen", true),
            ("MU6789", "China Eastern", "Beijing", "Shanghai", "Business", 145, 0, 3200, "Airbus A350", 8.8, true, true, 40, true, "Personal Screen", true),
            
            ("CA3456", "Air China", "Beijing", "Guangzhou", "Economy", 195, 0, 1680, "Boeing 777-300", 8.0, true, true, 33, true, "Personal Screen", true),
            ("CZ7890", "China Southern", "Beijing", "Guangzhou", "Economy", 185, 0, 1450, "Airbus A380", 8.7, true, true, 34, true, "Personal Screen", true),
            ("HU1234", "Hainan Airlines", "Beijing", "Guangzhou", "Economy", 200, 1, 1280, "Boeing 737-800", 6.8, false, true, 31, false, nil, true),
            
            ("CA4567", "Air China", "Shanghai", "Chengdu", "Economy", 180, 0, 1380, "Airbus A321neo", 7.5, true, true, 32, true, "Personal Screen", true),
            ("3U2345", "Sichuan Airlines", "Shanghai", "Chengdu", "Economy", 175, 0, 980, "Airbus A320", 7.0, nil, false, 30, false, nil, true),
            
            ("MU8901", "China Eastern", "Guangzhou", "Hangzhou", "Economy", 120, 0, 880, "Boeing 737 MAX", 7.3, true, true, 31, false, nil, true),
            ("CZ5678", "China Southern", "Shenzhen", "Beijing", "Economy", 195, 0, 1580, "Airbus A350", 8.4, true, true, 34, true, "Personal Screen", true),
            ("HU3456", "Hainan Airlines", "Shenzhen", "Beijing", "Economy", 210, 1, 1180, "Boeing 787-8", 7.1, true, true, 33, true, "Personal Screen", true),
        ]
        
        return flightsData.enumerated().map { index, data in
            let (flightNumber, airline, from, to, cabin, duration, stops, price, aircraft, score, wifi, power, pitch, ife, ifeType, meal) = data
            
            let flight = createFlight(
                id: "flight-\(index + 1)",
                flightNumber: flightNumber,
                airline: airline,
                from: from,
                to: to,
                cabin: cabin,
                durationMinutes: duration,
                stops: stops,
                price: price,
                aircraftModel: aircraft
            )
            
            let flightScore = createScore(
                overallScore: score,
                persona: "business",
                flight: flight,
                hasWifi: wifi,
                hasPower: power,
                seatPitch: pitch
            )
            
            let facilities = FlightFacilities(
                hasWifi: wifi,
                hasPower: power,
                seatPitchInches: pitch,
                seatPitchCategory: pitchCategory(pitch),
                hasIFE: ife,
                ifeType: ifeType,
                mealIncluded: meal,
                mealType: meal == true ? "Full Meal" : nil
            )
            
            return FlightWithScore(flight: flight, score: flightScore, facilities: facilities)
        }
    }
    
    private static func createFlight(
        id: String,
        flightNumber: String,
        airline: String,
        from: String,
        to: String,
        cabin: String,
        durationMinutes: Int,
        stops: Int,
        price: Double,
        aircraftModel: String?
    ) -> Flight {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate random departure time
        let hour = Int.random(in: 6...21)
        let minute = [0, 15, 30, 45].randomElement() ?? 0
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = hour
        components.minute = minute
        
        let departureTime = calendar.date(from: components) ?? today
        let arrivalTime = departureTime.addingTimeInterval(Double(durationMinutes) * 60)
        
        let airlineCode = String(flightNumber.prefix(2))
        let fromCode = Constants.Cities.cityToCode[from] ?? "XXX"
        let toCode = Constants.Cities.cityToCode[to] ?? "XXX"
        
        return Flight(
            id: id,
            flightNumber: flightNumber,
            airline: airline,
            airlineCode: airlineCode,
            departureCity: from,
            departureCityCode: fromCode,
            departureAirport: airportName(for: from),
            departureAirportCode: fromCode,
            departureTime: departureTime,
            arrivalCity: to,
            arrivalCityCode: toCode,
            arrivalAirport: airportName(for: to),
            arrivalAirportCode: toCode,
            arrivalTime: arrivalTime,
            durationMinutes: durationMinutes,
            stops: stops,
            stopCities: stops > 0 ? ["Wuhan"] : nil,
            cabin: cabin,
            aircraftModel: aircraftModel,
            price: price,
            currency: "CNY",
            seatsRemaining: Int.random(in: 3...50)
        )
    }
    
    private static func createScore(
        overallScore: Double,
        persona: String,
        flight: Flight,
        hasWifi: Bool?,
        hasPower: Bool?,
        seatPitch: Int?
    ) -> FlightScore {
        // Generate dimension scores (fluctuating around overall score)
        let safetyScore = min(10, max(0, overallScore + Double.random(in: -0.5...0.5)))
        let comfortScore = min(10, max(0, overallScore + Double.random(in: -0.8...0.8)))
        let serviceScore = min(10, max(0, overallScore + Double.random(in: -0.6...0.6)))
        let valueScore = min(10, max(0, overallScore + Double.random(in: -1.0...1.0)))
        
        // Generate highlights
        var highlights: [String] = []
        if hasWifi == true { highlights.append("In-flight WiFi") }
        if seatPitch ?? 0 >= 33 { highlights.append("Spacious Seats") }
        if flight.stops == 0 { highlights.append("Direct Flight") }
        if hasPower == true { highlights.append("Power Outlet") }
        if overallScore >= 8.0 { highlights.append("Top Rated") }
        
        // Generate explanations
        var explanations: [ScoreExplanation] = []
        
        explanations.append(ScoreExplanation(
            dimension: "safety",
            title: "Airline Safety Record",
            detail: "\(flight.airline) has an excellent safety record",
            isPositive: safetyScore >= 7.0
        ))
        
        if flight.stops == 0 {
            explanations.append(ScoreExplanation(
                dimension: "safety",
                title: "Direct Flight",
                detail: "No layovers, reducing travel uncertainty",
                isPositive: true
            ))
        }
        
        if let pitch = seatPitch {
            explanations.append(ScoreExplanation(
                dimension: "comfort",
                title: "Seat Space",
                detail: "Seat pitch \(pitch) inches, \(pitch >= 33 ? "above industry average" : "somewhat compact")",
                isPositive: pitch >= 33
            ))
        }
        
        if let aircraft = flight.aircraftModel {
            let isWidebody = aircraft.contains("787") || aircraft.contains("777") || 
                            aircraft.contains("350") || aircraft.contains("380") ||
                            aircraft.contains("330")
            if isWidebody {
                explanations.append(ScoreExplanation(
                    dimension: "comfort",
                    title: "Wide-body Aircraft",
                    detail: "\(aircraft) features a wide-body design with a spacious and quiet cabin",
                    isPositive: true
                ))
            }
        }
        
        explanations.append(ScoreExplanation(
            dimension: "service",
            title: "In-flight Service",
            detail: "\(flight.airline) provides standard \(flight.cabin) service",
            isPositive: serviceScore >= 7.0
        ))
        
        explanations.append(ScoreExplanation(
            dimension: "value",
            title: "Price Assessment",
            detail: "Current price is \(valueScore >= 7 ? "below" : "close to") the route average",
            isPositive: valueScore >= 7.0
        ))
        
        return FlightScore(
            overallScore: overallScore,
            dimensions: ScoreDimensions(
                safety: safetyScore,
                comfort: comfortScore,
                service: serviceScore,
                value: valueScore
            ),
            highlights: Array(highlights.prefix(3)),
            explanations: explanations,
            personaWeightsApplied: persona
        )
    }
    
    private static func airportName(for city: String) -> String {
        let airports: [String: String] = [
            "Beijing": "Capital International Airport",
            "Shanghai": "Hongqiao International Airport",
            "Guangzhou": "Baiyun International Airport",
            "Shenzhen": "Bao'an International Airport",
            "Chengdu": "Tianfu International Airport",
            "Hangzhou": "Xiaoshan International Airport",
            "Wuhan": "Tianhe International Airport",
            "Xi'an": "Xianyang International Airport",
            "Chongqing": "Jiangbei International Airport",
            "Nanjing": "Lukou International Airport"
        ]
        return airports[city] ?? "\(city) Airport"
    }
    
    private static func pitchCategory(_ pitch: Int?) -> String? {
        guard let pitch = pitch else { return nil }
        if pitch >= 34 { return "Spacious" }
        if pitch >= 32 { return "Standard" }
        return "Compact"
    }
}
