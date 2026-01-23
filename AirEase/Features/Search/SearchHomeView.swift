//
//  SearchHomeView.swift
//  AirEase
//
//  搜索首页
//

import SwiftUI

struct SearchHomeView: View {
    @State private var viewModel = SearchHomeViewModel()
    @State private var navigateToResults = false
    @State private var showSettings = false
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Search Form
                    searchFormSection
                    
                    // AI Search Entry (P1)
                    if AppConfiguration.shared.enableAISearch {
                        aiSearchSection
                    }
                    
                    // Recent Searches
                    if !viewModel.recentSearches.isEmpty {
                        recentSearchesSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationDestination(isPresented: $navigateToResults) {
                if let query = viewModel.currentSearchQuery {
                    FlightListView(searchQuery: query)
                }
            }
            .onChange(of: viewModel.shouldNavigateToResults) { _, newValue in
                if newValue {
                    navigateToResults = true
                    viewModel.shouldNavigateToResults = false
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.greetingText)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(languageManager.isEnglish ? "Find your perfect flight" : "找到最适合您的航班")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Settings Button
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(Color.aireasePurple)
                    .frame(width: 40, height: 40)
                    .background(Color.aireasePurpleLight)
                    .clipShape(Circle())
            }
            
            // Persona Badge
            if let persona = viewModel.userPersona {
                HStack(spacing: 6) {
                    Image(systemName: persona.iconName)
                        .font(.caption)
                    Text(L10n.personaName(persona))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(persona.color.opacity(0.1))
                .foregroundColor(persona.color)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Search Form Section
    private var searchFormSection: some View {
        VStack(spacing: 16) {
            // Cities
            HStack(spacing: 12) {
                // From City
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.from)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField(languageManager.isEnglish ? "Beijing" : "北京", text: $viewModel.fromCity)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Swap Button
                Button(action: viewModel.swapCities) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.aireasePurple)
                        .frame(width: 36, height: 36)
                        .background(Color.aireasePurple.opacity(0.1))
                        .cornerRadius(18)
                }
                
                // To City
                VStack(alignment: .trailing, spacing: 6) {
                    Text(L10n.to)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField(languageManager.isEnglish ? "Shanghai" : "上海", text: $viewModel.toCity)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.trailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            Divider()
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                
                DatePicker(
                    L10n.departureDate,
                    selection: $viewModel.selectedDate,
                    in: viewModel.minimumDate...,
                    displayedComponents: .date
                )
                .labelsHidden()
            }
            
            Divider()
            
            // Cabin
            HStack {
                Image(systemName: "seat.fill")
                    .foregroundStyle(.secondary)
                
                Picker(L10n.cabin, selection: $viewModel.selectedCabin) {
                    ForEach(Constants.Cabin.allCabins, id: \.self) { cabin in
                        Text(cabin).tag(cabin)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Search Button
            Button(action: viewModel.search) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text(L10n.searchFlights)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canSearch ? Color.aireasePurple : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canSearch)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 4)
    }
    
    // MARK: - AI Search Section (P1)
    private var aiSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text(languageManager.isEnglish ? "AI Smart Search" : "AI 智能搜索")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isAIProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            HStack {
                TextField(L10n.aiSearchPlaceholder, text: $viewModel.aiSearchText)
                    .textFieldStyle(.plain)
                    .disabled(viewModel.isAIProcessing)
                
                if !viewModel.aiSearchText.isEmpty {
                    Button(action: {
                        Task {
                            await viewModel.parseAISearchWithGemini()
                        }
                    }) {
                        Image(systemName: viewModel.isAIProcessing ? "hourglass" : "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                    .disabled(viewModel.isAIProcessing)
                }
            }
            .padding(12)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
            
            // Error message
            if !viewModel.aiErrorMessage.isEmpty {
                Text(viewModel.aiErrorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Hint
            Text(languageManager.isEnglish ? "Powered by Gemini AI" : "由 Gemini AI 提供支持")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Recent Searches Section
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.recentSearches)
                    .font(.headline)
                
                Spacer()
                
                Button(languageManager.isEnglish ? "Clear" : "清除") {
                    viewModel.clearRecentSearches()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            ForEach(viewModel.recentSearches) { search in
                Button(action: {
                    viewModel.fillFromRecentSearch(search)
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.secondary)
                        
                        Text(search.displayText)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(search.cabin)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    SearchHomeView()
}
