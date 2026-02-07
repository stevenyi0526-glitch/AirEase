//
//  Environment.swift
//  AirEase
//
//  环境变量加载器
//

import Foundation

enum Environment {
    
    private static var envDict: [String: String] = {
        loadEnvFile()
    }()
    
    /// Gemini API Key
    static var geminiAPIKey: String {
        get { envDict["GEMINI_API_KEY"] ?? "" }
    }
    
    /// Flight API Key
    static var flightAPIKey: String {
        get { envDict["FLIGHT_API_KEY"] ?? "" }
    }
    
    /// Flight API Secret
    static var flightAPISecret: String {
        get { envDict["FLIGHT_API_SECRET"] ?? "" }
    }
    
    // MARK: - Private
    
    private static func loadEnvFile() -> [String: String] {
        var result: [String: String] = [:]
        
        // Try to load from bundle
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
           let content = try? String(contentsOfFile: envPath, encoding: .utf8) {
            result = parseEnvContent(content)
        }
        
        // Try to load from project root (development)
        #if DEBUG
        let projectEnvPath = getProjectRootEnvPath()
        if let content = try? String(contentsOfFile: projectEnvPath, encoding: .utf8) {
            let parsed = parseEnvContent(content)
            result.merge(parsed) { _, new in new }
        }
        #endif
        
        // Fallback: hardcoded for development (remove in production)
        if result["GEMINI_API_KEY"] == nil || result["GEMINI_API_KEY"]?.isEmpty == true {
            result["GEMINI_API_KEY"] = "AIzaSyAQoutqlgUTNYhgpy1fWHoBRj9ETwCTkb0"
        }
        
        return result
    }
    
    private static func parseEnvContent(_ content: String) -> [String: String] {
        var result: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE
            if let equalIndex = trimmed.firstIndex(of: "=") {
                let key = String(trimmed[..<equalIndex]).trimmingCharacters(in: .whitespaces)
                let value = String(trimmed[trimmed.index(after: equalIndex)...]).trimmingCharacters(in: .whitespaces)
                result[key] = value
            }
        }
        
        return result
    }
    
    private static func getProjectRootEnvPath() -> String {
        // For development, try to find .env in project root
        let currentFile = #file
        if let range = currentFile.range(of: "/AirEase/AirEase/") {
            let projectRoot = String(currentFile[..<range.upperBound]).replacingOccurrences(of: "/AirEase/", with: "/")
            return projectRoot + ".env"
        }
        return ""
    }
}
