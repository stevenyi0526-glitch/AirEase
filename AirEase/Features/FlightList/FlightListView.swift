//
//  FlightListView.swift
//  AirEase
//
//  Flight List Screen
//

import SwiftUI

struct FlightListView: View {
    @State private var viewModel: FlightListViewModel
    @State private var navigateToDetail = false
    @ObservedObject private var languageManager = LanguageManager.shared
    
    init(searchQuery: SearchQuery) {
        _viewModel = State(initialValue: FlightListViewModel(searchQuery: searchQuery))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Info
            headerSection
            
            // Sorting Toolbar
            sortingToolbar
            
            // Content
            if viewModel.isLoading {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else if viewModel.filteredFlights.isEmpty {
                emptyView
            } else {
                flightList
            }
        }
        .navigationTitle(languageManager.isEnglish ? "Flights" : "航班列表")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToDetail) {
            if let flight = viewModel.selectedFlight {
                FlightDetailView(flightWithScore: flight)
            }
        }
        .task {
            await viewModel.loadFlights()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(viewModel.routeText)
                .font(.headline)
            
            Text(viewModel.dateAndCabinText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(viewModel.resultCountText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }
    
    // MARK: - Sorting Toolbar
    private var sortingToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FlightSortOption.allCases, id: \.self) { option in
                    SortChip(
                        title: option.rawValue,
                        isSelected: viewModel.selectedSort == option
                    ) {
                        viewModel.selectSort(option)
                    }
                }
                
                Spacer()
                
                // Filter Button (P1 Stub)
                Button(action: {
                    // TODO: Show filter sheet
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filter")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    // MARK: - Flight List
    private var flightList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredFlights) { flightWithScore in
                    FlightCardView(flightWithScore: flightWithScore)
                        .onTapGesture {
                            viewModel.selectFlight(flightWithScore)
                            navigateToDetail = true
                        }
                }
            }
            .padding(16)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text(L10n.loading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "airplane.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text(L10n.noFlightsFound)
                .font(.headline)
            Text(languageManager.isEnglish ? "Try adjusting your search criteria" : "请尝试调整搜索条件")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            Text(L10n.error)
                .font(.headline)
            Text(viewModel.errorMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(L10n.retry) {
                Task {
                    await viewModel.loadFlights()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Sort Chip
struct SortChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.aireasePurple : Color(UIColor.systemBackground))
                .cornerRadius(20)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FlightListView(searchQuery: .sample)
    }
}
