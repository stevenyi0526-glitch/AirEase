//
//  FlightServiceProtocol.swift
//  AirEase
//
//  航班服务协议
//

import Foundation

protocol FlightServiceProtocol {
    /// 搜索航班
    func searchFlights(query: SearchQuery) async throws -> [FlightWithScore]
    
    /// 获取航班详情
    func getFlightDetail(flightId: String) async throws -> FlightDetail
    
    /// 获取价格历史
    func getPriceHistory(flightId: String) async throws -> PriceHistory
}

// MARK: - Service Factory
enum FlightServiceFactory {
    static func create() -> FlightServiceProtocol {
        if AppConfiguration.shared.useMockData {
            return MockFlightService()
        } else {
            return RealFlightService()
        }
    }
}

// MARK: - Service Errors
enum FlightServiceError: LocalizedError {
    case networkError
    case invalidResponse
    case notFound
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "网络连接失败，请检查网络设置"
        case .invalidResponse:
            return "服务器响应异常"
        case .notFound:
            return "未找到相关航班"
        case .serverError(let message):
            return "服务器错误: \(message)"
        case .decodingError:
            return "数据解析错误"
        case .unknown:
            return "发生未知错误"
        }
    }
}
