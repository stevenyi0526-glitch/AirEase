//
//  TimelineView.swift
//  AirEase
//
//  Flight Timeline Component
//

import SwiftUI

struct TimelineView: View {
    let flight: Flight
    let facilities: FlightFacilities
    
    var boardingTime: Date {
        flight.departureTime.addingTimeInterval(-45 * 60) // 45 minutes before departure
    }
    
    var baggageTime: Date {
        flight.arrivalTime.addingTimeInterval(15 * 60) // 15 minutes after landing
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Departure Airport
            TimelineItem(
                time: boardingTime.timeString,
                title: flight.departureAirport,
                subtitle: "Boarding Gate Open",
                icon: "door.left.hand.open",
                isFirst: true,
                isLast: false
            )
            
            // Takeoff
            TimelineItem(
                time: flight.formattedDepartureTime,
                title: "Takeoff",
                subtitle: flight.departureCity,
                icon: "airplane.departure",
                isFirst: false,
                isLast: false,
                isHighlighted: true
            )
            
            // In-flight services
            TimelineServiceItem(
                duration: flight.formattedDuration,
                services: inflightServices
            )
            
            // Landing
            TimelineItem(
                time: flight.formattedArrivalTime,
                title: "Landing",
                subtitle: flight.arrivalCity,
                icon: "airplane.arrival",
                isFirst: false,
                isLast: false,
                isHighlighted: true
            )
            
            // Baggage
            TimelineItem(
                time: baggageTime.timeString,
                title: "Expected Baggage Claim Arrival",
                subtitle: flight.arrivalAirport,
                icon: "bag.fill",
                isFirst: false,
                isLast: true
            )
        }
    }
    
    private var inflightServices: [String] {
        var services: [String] = []
        
        if facilities.mealIncluded == true {
            services.append("30 min after takeoff: \(facilities.mealType ?? "Meal") service")
        }
        
        if facilities.hasWifi == true {
            services.append("WiFi available throughout flight")
        }
        
        if facilities.hasIFE == true {
            services.append("In-flight entertainment: \(facilities.ifeType ?? "Available")")
        }
        
        if services.isEmpty {
            services.append("Comfortable flight in progress")
        }
        
        return services
    }
}

// MARK: - Timeline Item
struct TimelineItem: View {
    let time: String
    let title: String
    let subtitle: String
    let icon: String
    let isFirst: Bool
    let isLast: Bool
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            Text(time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
            
            // Timeline dot and line
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 10)
                }
                
                Circle()
                    .fill(isHighlighted ? Color.aireasePurple : Color.gray.opacity(0.5))
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 10)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(isHighlighted ? .aireasePurple : .secondary)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(isHighlighted ? .semibold : .regular)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Timeline Service Item
struct TimelineServiceItem: View {
    let duration: String
    let services: [String]
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Spacer for time column
            Text("")
                .frame(width: 50)
            
            // Timeline line
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
            }
            .frame(height: CGFloat(services.count * 24 + 40))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("In Flight")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("(\(duration))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                ForEach(services, id: \.self) { service in
                    HStack(spacing: 6) {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(service)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.aireasePurple.opacity(0.05))
            .cornerRadius(8)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    TimelineView(flight: .sample, facilities: .sample)
        .padding()
}
