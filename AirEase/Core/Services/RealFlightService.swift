//
//  RealFlightService.swift
//  AirEase
//
//  真实航班API服务 - 用于生产环境
//

import Foundation

final class RealFlightService: FlightServiceProtocol {
    
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init() {
        self.baseURL = AppConfiguration.shared.baseURL
        self.apiKey = AppConfiguration.shared.flightAPIKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfiguration.shared.apiTimeout
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - FlightServiceProtocol
    
    func searchFlights(query: SearchQuery) async throws -> [FlightWithScore] {
        let endpoint = "\(baseURL)/v1/flights/search"
        
        var components = URLComponents(string: endpoint)
        components?.queryItems = [
            URLQueryItem(name: "from", value: query.fromCity),
            URLQueryItem(name: "to", value: query.toCity),
            URLQueryItem(name: "date", value: query.date.isoDateString),
            URLQueryItem(name: "cabin", value: mapCabin(query.cabin))
        ]
        
        guard let url = components?.url else {
            throw FlightServiceError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlightServiceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                let searchResponse = try decoder.decode(FlightSearchResponse.self, from: data)
                return searchResponse.flights
            case 404:
                throw FlightServiceError.notFound
            case 429:
                throw FlightServiceError.serverError("请求过于频繁，请稍后重试")
            case 500...599:
                throw FlightServiceError.serverError("服务器暂时不可用")
            default:
                throw FlightServiceError.invalidResponse
            }
        } catch let error as FlightServiceError {
            throw error
        } catch is DecodingError {
            throw FlightServiceError.decodingError
        } catch {
            throw FlightServiceError.networkError
        }
    }
    
    func getFlightDetail(flightId: String) async throws -> FlightDetail {
        let endpoint = "\(baseURL)/v1/flights/\(flightId)"
        
        guard let url = URL(string: endpoint) else {
            throw FlightServiceError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlightServiceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try decoder.decode(FlightDetail.self, from: data)
            case 404:
                throw FlightServiceError.notFound
            default:
                throw FlightServiceError.invalidResponse
            }
        } catch let error as FlightServiceError {
            throw error
        } catch is DecodingError {
            throw FlightServiceError.decodingError
        } catch {
            throw FlightServiceError.networkError
        }
    }
    
    func getPriceHistory(flightId: String) async throws -> PriceHistory {
        let endpoint = "\(baseURL)/v1/flights/\(flightId)/price-history"
        
        guard let url = URL(string: endpoint) else {
            throw FlightServiceError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FlightServiceError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200:
                return try decoder.decode(PriceHistory.self, from: data)
            case 404:
                throw FlightServiceError.notFound
            default:
                throw FlightServiceError.invalidResponse
            }
        } catch let error as FlightServiceError {
            throw error
        } catch is DecodingError {
            throw FlightServiceError.decodingError
        } catch {
            throw FlightServiceError.networkError
        }
    }
    
    // MARK: - Private Methods
    
    private func mapCabin(_ cabin: String) -> String {
        switch cabin {
        case "经济舱": return "economy"
        case "公务舱": return "business"
        case "头等舱": return "first"
        default: return "economy"
        }
    }
}
