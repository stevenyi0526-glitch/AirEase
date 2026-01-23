//
//  FavoritesView.swift
//  AirEase
//
//  Favorites List Page - P1 Simple Implementation
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var persistence = PersistenceService.shared
    
    var body: some View {
        VStack {
            if persistence.favorites.isEmpty {
                emptyState
            } else {
                favoritesList
            }
        }
        .navigationTitle("My Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Favorites")
                .font(.headline)
            
            Text("Tap the favorite button while browsing flights to add them")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    private var favoritesList: some View {
        List {
            ForEach(persistence.favorites, id: \.self) { flightId in
                HStack {
                    Image(systemName: "airplane")
                        .foregroundColor(.blue)
                    
                    Text("Flight \(flightId)")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Button(action: {
                        persistence.removeFavorite(flightId: flightId)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
