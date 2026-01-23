//
//  FlightCardView.swift
//  AirEase
//
//  航班卡片组件
//

import SwiftUI

struct FlightCardView: View {
    let flightWithScore: FlightWithScore
    
    private var flight: Flight { flightWithScore.flight }
    private var score: FlightScore { flightWithScore.score }
    private var facilities: FlightFacilities { flightWithScore.facilities }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section: Airline + Score
            topSection
            
            Divider()
                .padding(.horizontal, 16)
            
            // Middle Section: Time and Route
            middleSection
            
            Divider()
                .padding(.horizontal, 16)
            
            // Bottom Section: Duration, Highlights, Price
            bottomSection
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack {
            // Airline Logo Placeholder + Info
            HStack(spacing: 10) {
                // Airline logo placeholder
                Text(flight.airlineCode)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.aireasePurple)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.flightNumber)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    if let aircraft = flight.aircraftModel {
                        Text(aircraft)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Score Badge
            ScoreBadgeView(score: score.overallScore)
        }
        .padding(16)
    }
    
    // MARK: - Middle Section
    private var middleSection: some View {
        HStack(alignment: .center) {
            // Departure
            VStack(alignment: .leading, spacing: 4) {
                Text(flight.formattedDepartureTime)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(flight.departureCityCode)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(flight.departureCity)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Flight Path
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 30, height: 1)
                    
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 30, height: 1)
                }
                
                Text(flight.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(flight.stopsDescription)
                    .font(.caption2)
                    .foregroundColor(flight.stops == 0 ? .green : .orange)
            }
            
            Spacer()
            
            // Arrival
            VStack(alignment: .trailing, spacing: 4) {
                Text(flight.formattedArrivalTime)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(flight.arrivalCityCode)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(flight.arrivalCity)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
    
    // MARK: - Bottom Section
    private var bottomSection: some View {
        HStack {
            // Highlights
            HStack(spacing: 6) {
                ForEach(score.highlights.prefix(3), id: \.self) { highlight in
                    HighlightTag(text: highlight, facilities: facilities)
                }
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 2) {
                Text(flight.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(flight.cabin)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }
}

// MARK: - Score Badge View
struct ScoreBadgeView: View {
    let score: Double
    private var isEnglish: Bool { LanguageManager.shared.isEnglish }
    
    var scoreColor: Color {
        Color.scoreColor(for: score)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", score))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(isEnglish ? "Score" : "体验分")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(scoreColor)
        .cornerRadius(10)
    }
}

// MARK: - Highlight Tag
struct HighlightTag: View {
    let text: String
    let facilities: FlightFacilities
    private var isEnglish: Bool { LanguageManager.shared.isEnglish }
    
    var icon: String {
        switch text {
        case "机上WiFi", "WiFi": return "wifi"
        case "宽敞座椅", "Spacious Seats": return "chair.fill"
        case "直飞", "Direct Flight", "Nonstop": return "airplane"
        case "座位电源", "Power Outlet", "Power": return "bolt.fill"
        case "个人娱乐", "Entertainment", "IFE": return "tv.fill"
        case "高评分", "Top Rated": return "star.fill"
        case "高性价比", "Great Value", "Value": return "dollarsign.circle.fill"
        case "宽体客机", "Wide-body": return "airplane.circle.fill"
        default: return "checkmark.circle.fill"
        }
    }
    
    var displayText: String {
        if isEnglish {
            // Map Chinese to English
            switch text {
            case "机上WiFi": return "WiFi"
            case "宽敞座椅": return "Spacious"
            case "直飞": return "Nonstop"
            case "座位电源": return "Power"
            case "个人娱乐": return "IFE"
            case "高评分": return "Top Rated"
            case "高性价比": return "Value"
            case "宽体客机": return "Wide-body"
            default: return text
            }
        }
        return text
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(displayText)
                .font(.caption2)
        }
        .foregroundColor(Color.aireasePurple)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.aireasePurple.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        FlightCardView(flightWithScore: .sample)
            .padding()
    }
    .background(Color(UIColor.systemGroupedBackground))
}
