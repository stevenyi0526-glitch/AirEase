//
//  FacilitiesGridView.swift
//  AirEase
//
//  Facilities Grid Component
//

import SwiftUI

struct FacilitiesGridView: View {
    let facilities: FlightFacilities
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            FacilityCard(
                icon: "wifi",
                title: "WiFi",
                status: facilities.wifiStatus,
                detail: facilities.wifiStatus == .available ? "Available" : nil
            )
            
            FacilityCard(
                icon: "bolt.fill",
                title: "Power",
                status: facilities.powerStatus,
                detail: facilities.powerStatus == .available ? "Per Seat" : nil
            )
            
            FacilityCard(
                icon: "chair.fill",
                title: "Seat Pitch",
                status: facilities.seatPitchInches != nil ? .available : .unknown,
                detail: facilities.seatPitchDisplay
            )
            
            FacilityCard(
                icon: "tv.fill",
                title: "Entertainment",
                status: facilities.ifeStatus,
                detail: facilities.ifeDisplay
            )
            
            FacilityCard(
                icon: "fork.knife",
                title: "Meal",
                status: facilities.mealStatus,
                detail: facilities.mealDisplay
            )
        }
    }
}

struct FacilityCard: View {
    let icon: String
    let title: String
    let status: FacilityStatus
    let detail: String?
    
    var iconColor: Color {
        switch status {
        case .available: return .aireasePurple
        case .unavailable: return .gray
        case .unknown: return .gray
        }
    }
    
    var statusColor: Color {
        switch status {
        case .available: return .green
        case .unavailable: return .red
        case .unknown: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                
                Spacer()
                
                Image(systemName: status.iconName)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(detail ?? status.displayText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        FacilitiesGridView(facilities: .sample)
        
        Divider()
        
        FacilitiesGridView(facilities: .partial)
    }
    .padding()
}
