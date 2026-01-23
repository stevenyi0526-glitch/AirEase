//
//  GeminiService.swift
//  AirEase
//
//  Gemini LLM Service - For AI smart search and natural language processing
//

import Foundation

/// Gemini API Service
final class GeminiService {
    
    static let shared = GeminiService()
    
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    private let model = "gemini-3.0-preview"  // Gemini 3.0 Preview
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        self.apiKey = Environment.geminiAPIKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        
        #if DEBUG
        print("🤖 GeminiService initialized with API key: \(apiKey.prefix(10))...")
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Parse natural language search query
    /// Example: "Business class flight to Shanghai next Wednesday" -> SearchQuery
    func parseFlightSearchQuery(_ naturalLanguageQuery: String) async throws -> ParsedFlightQuery {
        let systemPrompt = """
        You are a flight search assistant. Users will describe flights they want to search in natural language.
        Extract the following information from the user input and return it in JSON format:
        
        {
            "fromCity": "Departure city name (e.g., Beijing, Shanghai, New York)",
            "toCity": "Arrival city name",
            "date": "Date in YYYY-MM-DD format. If it's a relative date like 'tomorrow' or 'next Wednesday', convert it to a specific date. Today is \(todayDateString)",
            "cabin": "Cabin class: Economy, Business, or First. Default is Economy",
            "confidence": A confidence score between 0.0 and 1.0
        }
        
        If a field cannot be determined, set it to null.
        Return only JSON, no other text.
        """
        
        let response = try await generateContent(
            systemPrompt: systemPrompt,
            userMessage: naturalLanguageQuery
        )
        
        // Try to clean response (remove possible markdown code blocks)
        let cleanedResponse = cleanJSONResponse(response)
        guard let cleanedData = cleanedResponse.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }
        
        do {
            let parsed = try decoder.decode(ParsedFlightQuery.self, from: cleanedData)
            return parsed
        } catch {
            print("❌ Failed to parse Gemini response: \(response)")
            throw GeminiError.parsingFailed
        }
    }
    
    /// Generate flight score explanation
    func generateScoreExplanation(
        flight: Flight,
        score: FlightScore,
        persona: UserPersona
    ) async throws -> String {
        let systemPrompt = """
        You are the AirEase flight experience rating system narrator. Please explain this flight's rating in concise, friendly language.
        Based on the user's \(L10n.personaName(persona)) profile, highlight the information most relevant to them.
        Keep it under 50 words.
        """
        
        let userMessage = """
        Flight: \(flight.airline) \(flight.flightNumber)
        Route: \(flight.departureCity) → \(flight.arrivalCity)
        Duration: \(flight.formattedDuration)
        Price: \(flight.formattedPrice)
        Overall Score: \(score.formattedScore)/10
        Safety: \(score.dimensions.safety), Comfort: \(score.dimensions.comfort)
        Service: \(score.dimensions.service), Value: \(score.dimensions.value)
        Highlights: \(score.highlights.joined(separator: ", "))
        """
        
        return try await generateContent(
            systemPrompt: systemPrompt,
            userMessage: userMessage
        )
    }
    
    /// General text generation
    func generateContent(systemPrompt: String, userMessage: String) async throws -> String {
        let endpoint = "\(baseURL)/models/\(model):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw GeminiError.invalidURL
        }
        
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    role: "user",
                    parts: [
                        GeminiPart(text: systemPrompt + "\n\n用户输入: " + userMessage)
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: 0.7,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 1024
            )
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Gemini API error (\(httpResponse.statusCode)): \(errorBody)")
            throw GeminiError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }
        
        let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
        
        guard let text = geminiResponse.candidates?.first?.content?.parts.first?.text else {
            throw GeminiError.noContent
        }
        
        return text
    }
    
    // MARK: - Private Helpers
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
    
    private func cleanJSONResponse(_ response: String) -> String {
        var cleaned = response
        
        // Remove markdown code blocks
        if cleaned.contains("```json") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        }
        if cleaned.contains("```") {
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Request/Response Models

struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
}

struct GeminiContent: Codable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double?
    let topK: Int?
    let topP: Double?
    let maxOutputTokens: Int?
}

struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

// MARK: - Parsed Models

struct ParsedFlightQuery: Codable {
    let fromCity: String?
    let toCity: String?
    let date: String?
    let cabin: String?
    let confidence: Double?
    
    var parsedDate: Date? {
        guard let dateString = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

// MARK: - Errors

enum GeminiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noContent
    case parsingFailed
    case apiError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .noContent:
            return "No content in Gemini response"
        case .parsingFailed:
            return "Failed to parse Gemini response"
        case .apiError(let statusCode, let message):
            return "Gemini API error (\(statusCode)): \(message)"
        }
    }
}
