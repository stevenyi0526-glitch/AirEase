//
//  SearchHomeViewModel.swift
//  AirEase
//
//  搜索首页视图模型
//

import Foundation
import SwiftUI

@Observable
final class SearchHomeViewModel {
    // Form State
    var fromCity: String = ""
    var toCity: String = ""
    var selectedDate: Date = Date()
    var selectedCabin: String = Constants.Cabin.economy
    
    // AI Search (P1)
    var aiSearchText: String = ""
    var showAISearch: Bool = false
    var isAIProcessing: Bool = false
    var aiErrorMessage: String = ""
    
    // UI State
    var isLoading: Bool = false
    var showError: Bool = false
    var errorMessage: String = ""
    
    // Navigation
    var shouldNavigateToResults: Bool = false
    var currentSearchQuery: SearchQuery?
    
    // Dependencies
    private let persistence = PersistenceService.shared
    private let geminiService = GeminiService.shared
    
    var recentSearches: [SearchQuery] {
        persistence.recentSearches
    }
    
    var userPersona: UserPersona? {
        persistence.userPersona
    }
    
    var greetingText: String {
        if let persona = userPersona {
            return "Hello，\(persona.shortName)"
        }
        return "Hello，Traveler"
    }
    
    var canSearch: Bool {
        !fromCity.trimmingCharacters(in: .whitespaces).isEmpty &&
        !toCity.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Actions
    
    func swapCities() {
        let temp = fromCity
        fromCity = toCity
        toCity = temp
    }
    
    func search() {
        guard canSearch else { return }
        
        let query = SearchQuery(
            fromCity: fromCity.trimmingCharacters(in: .whitespaces),
            toCity: toCity.trimmingCharacters(in: .whitespaces),
            date: selectedDate,
            cabin: selectedCabin
        )
        
        // 保存到最近搜索
        persistence.addRecentSearch(query)
        
        currentSearchQuery = query
        shouldNavigateToResults = true
    }
    
    func fillFromRecentSearch(_ query: SearchQuery) {
        fromCity = query.fromCity
        toCity = query.toCity
        selectedDate = max(query.date, minimumDate) // 确保日期不在过去
        selectedCabin = query.cabin
    }
    
    func clearRecentSearches() {
        persistence.clearRecentSearches()
    }
    
    // MARK: - AI Search with Gemini
    
    @MainActor
    func parseAISearchWithGemini() async {
        guard !aiSearchText.isEmpty else { return }
        
        isAIProcessing = true
        aiErrorMessage = ""
        
        do {
            let parsed = try await geminiService.parseFlightSearchQuery(aiSearchText)
            
            // 填充解析结果
            if let from = parsed.fromCity, !from.isEmpty {
                fromCity = from
            }
            if let to = parsed.toCity, !to.isEmpty {
                toCity = to
            }
            if let date = parsed.parsedDate {
                selectedDate = max(date, minimumDate)
            }
            if let cabin = parsed.cabin, !cabin.isEmpty {
                selectedCabin = cabin
            }
            
            // 清空AI搜索框
            aiSearchText = ""
            showAISearch = false
            
            #if DEBUG
            print("✅ AI Analysis Successful: \(parsed)")
            #endif
            
        } catch {
            aiErrorMessage = "AI Error: Please retry or enter manually"
            #if DEBUG
            print("❌ AI Error: \(error)")
            #endif
            
            // 降级到简单解析
            parseAISearchFallback()
        }
        
        isAIProcessing = false
    }
    
    // MARK: - Fallback Simple Parser
    
    private func parseAISearchFallback() {
        let text = aiSearchText
        
        // 提取城市
        let cities = text.extractCities()
        if cities.count >= 2 {
            fromCity = cities[0]
            toCity = cities[1]
        } else if cities.count == 1 {
            // 假设是目的地
            toCity = cities[0]
        }
        
        // 提取日期
        if let date = text.parsedDate {
            selectedDate = max(date, minimumDate)
        }
        
        // 提取舱位
        if let cabin = text.parsedCabin {
            selectedCabin = cabin
        }
        
        // 清空AI搜索框
        aiSearchText = ""
        showAISearch = false
    }
}
