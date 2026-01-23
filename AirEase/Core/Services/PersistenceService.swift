//
//  PersistenceService.swift
//  AirEase
//
//  本地持久化服务
//

import Foundation
import SwiftUI

final class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    // MARK: - Published Properties
    @AppStorage(Constants.StorageKeys.didOnboard) var didOnboard: Bool = false
    @AppStorage(Constants.StorageKeys.userPersona) private var userPersonaRaw: String = ""
    
    @Published var recentSearches: [SearchQuery] = []
    @Published var favorites: [String] = [] // Flight IDs
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadRecentSearches()
        loadFavorites()
    }
    
    // MARK: - Persona
    
    var userPersona: UserPersona? {
        get {
            UserPersona(rawValue: userPersonaRaw)
        }
        set {
            userPersonaRaw = newValue?.rawValue ?? ""
        }
    }
    
    func setPersona(_ persona: UserPersona) {
        userPersona = persona
        didOnboard = true
    }
    
    // MARK: - Recent Searches
    
    func addRecentSearch(_ query: SearchQuery) {
        // 移除相同的搜索
        recentSearches.removeAll { 
            $0.fromCity == query.fromCity && 
            $0.toCity == query.toCity && 
            Calendar.current.isDate($0.date, inSameDayAs: query.date) &&
            $0.cabin == query.cabin
        }
        
        // 添加到开头
        recentSearches.insert(query, at: 0)
        
        // 保持最大数量
        if recentSearches.count > Constants.Limits.maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(Constants.Limits.maxRecentSearches))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        guard let data = userDefaults.data(forKey: Constants.StorageKeys.recentSearches) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            recentSearches = try decoder.decode([SearchQuery].self, from: data)
        } catch {
            print("Failed to decode recent searches: \(error)")
            recentSearches = []
        }
    }
    
    private func saveRecentSearches() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentSearches)
            userDefaults.set(data, forKey: Constants.StorageKeys.recentSearches)
        } catch {
            print("Failed to encode recent searches: \(error)")
        }
    }
    
    // MARK: - Favorites
    
    func addFavorite(flightId: String) {
        guard !favorites.contains(flightId) else { return }
        favorites.append(flightId)
        saveFavorites()
    }
    
    func removeFavorite(flightId: String) {
        favorites.removeAll { $0 == flightId }
        saveFavorites()
    }
    
    func isFavorite(flightId: String) -> Bool {
        return favorites.contains(flightId)
    }
    
    func toggleFavorite(flightId: String) {
        if isFavorite(flightId: flightId) {
            removeFavorite(flightId: flightId)
        } else {
            addFavorite(flightId: flightId)
        }
    }
    
    private func loadFavorites() {
        favorites = userDefaults.stringArray(forKey: Constants.StorageKeys.favorites) ?? []
    }
    
    private func saveFavorites() {
        userDefaults.set(favorites, forKey: Constants.StorageKeys.favorites)
    }
    
    // MARK: - Reset (for testing)
    
    func resetAll() {
        didOnboard = false
        userPersonaRaw = ""
        recentSearches = []
        favorites = []
        
        userDefaults.removeObject(forKey: Constants.StorageKeys.recentSearches)
        userDefaults.removeObject(forKey: Constants.StorageKeys.favorites)
    }
}
