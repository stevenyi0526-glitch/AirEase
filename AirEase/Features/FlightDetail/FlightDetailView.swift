//
//  FlightDetailView.swift
//  AirEase
//
//  Flight Detail Screen - Modern Purple Header Design
//

import SwiftUI
import Charts

struct FlightDetailView: View {
    @State private var viewModel: FlightDetailViewModel
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    init(flightWithScore: FlightWithScore) {
        _viewModel = State(initialValue: FlightDetailViewModel(flightWithScore: flightWithScore))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color.white.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Purple Header with Hero Content
                    headerSection
                    
                    // Wave Divider
                    waveDivider
                    
                    // Body Content
                    VStack(spacing: 24) {
                        // Flight Score
                        flightScoreSection
                        
                        // Score Breakdown
                        scoreBreakdownSection
                        
                        // Facilities
                        facilitiesSection
                        
                        // Timeline
                        timelineSection
                        
                        // Price Info
                        priceSection
                        
                        // Action Buttons
                        actionButtonsSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Custom Navigation Bar
            customNavBar
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadDetails()
        }
        .alert("Coming Soon", isPresented: $viewModel.showPriceAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Price monitoring feature is under development")
        }
        .alert("Book Flight", isPresented: $viewModel.showBookingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Booking feature is under development")
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var customNavBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Button(action: { viewModel.showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 50)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Top padding for nav bar
            Color.aireasePurple
                .frame(height: 100)
            
            // Hero Content
            VStack(spacing: 16) {
                // Date
                Text(viewModel.flight.departureTime.formattedDateLong)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                // IATA Codes with Route Line
                HStack(alignment: .center, spacing: 0) {
                    // Departure Code
                    VStack(spacing: 4) {
                        Text(viewModel.flight.departureCityCode)
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundColor(.white)
                        Text(viewModel.flight.departureAirport)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .frame(maxWidth: 100)
                    }
                    
                    Spacer()
                    
                    // Route Line with Plane
                    routeLine
                    
                    Spacer()
                    
                    // Arrival Code
                    VStack(spacing: 4) {
                        Text(viewModel.flight.arrivalCityCode)
                            .font(.system(size: 48, weight: .heavy))
                            .foregroundColor(.white)
                        Text(viewModel.flight.arrivalAirport)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .frame(maxWidth: 100)
                    }
                }
                .padding(.horizontal, 20)
                
                // Duration and Passengers
                HStack(spacing: 24) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(viewModel.flight.formattedDuration)
                            .font(.subheadline)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person")
                            .font(.caption)
                        Text("1 Passenger")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    
                    if viewModel.flight.stops == 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right")
                                .font(.caption)
                            Text("Direct")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
            .background(Color.aireasePurple)
        }
    }
    
    // MARK: - Route Line
    private var routeLine: some View {
        VStack(spacing: 4) {
            // Flight number above the plane
            Text(viewModel.flight.flightNumber)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 0) {
                // Left dotted line
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 40, height: 1)
                
                // Plane icon
                Image(systemName: "airplane")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                
                // Right dotted line
                DottedLine()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 40, height: 1)
            }
        }
    }
    
    // MARK: - Wave Divider
    private var waveDivider: some View {
        WaveShape()
            .fill(Color.aireasePurple)
            .frame(height: 30)
            .offset(y: -1)
    }
    
    // MARK: - Flight Score Section
    private var flightScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flight Score")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(alignment: .top, spacing: 16) {
                // Big Score
                VStack(spacing: 4) {
                    Text(viewModel.score.formattedScore)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(viewModel.score.scoreColor)
                    Text("/ 10")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.scoreGradeText)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(viewModel.personaDescriptionEN)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    // Highlights
                    FlowLayout(spacing: 6) {
                        ForEach(viewModel.highlightsEN.prefix(3), id: \.self) { highlight in
                            Text(highlight)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.aireasePurple.opacity(0.1))
                                .foregroundColor(.aireasePurple)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Score Breakdown Section
    private var scoreBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Radar Chart with weighted scores
            VStack(spacing: 12) {
                RadarChartView(dataPoints: viewModel.radarData)
                    .frame(height: 220)
                
                // Weight legend
                HStack(spacing: 16) {
                    ForEach(viewModel.weightedScoreBreakdown) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.scoreColor(for: item.score))
                                .frame(width: 8, height: 8)
                            Text("\(item.dimension)")
                                .font(.caption2)
                            Text("\(item.weightPercentage)%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            // Collapsible Explanations by Dimension
            VStack(spacing: 8) {
                CollapsibleScoreCard(
                    dimension: "Safety",
                    icon: "shield.fill",
                    score: viewModel.score.dimensions.safety,
                    weight: viewModel.currentWeights.safety,
                    explanations: viewModel.safetyExplanations,
                    isExpanded: viewModel.isDimensionExpanded("safety"),
                    onTap: { viewModel.toggleDimension("safety") }
                )
                
                CollapsibleScoreCard(
                    dimension: "Comfort",
                    icon: "chair.lounge.fill",
                    score: viewModel.score.dimensions.comfort,
                    weight: viewModel.currentWeights.comfort,
                    explanations: viewModel.comfortExplanations,
                    isExpanded: viewModel.isDimensionExpanded("comfort"),
                    onTap: { viewModel.toggleDimension("comfort") }
                )
                
                CollapsibleScoreCard(
                    dimension: "Service",
                    icon: "person.crop.circle.fill",
                    score: viewModel.score.dimensions.service,
                    weight: viewModel.currentWeights.service,
                    explanations: viewModel.serviceExplanations,
                    isExpanded: viewModel.isDimensionExpanded("service"),
                    onTap: { viewModel.toggleDimension("service") }
                )
                
                CollapsibleScoreCard(
                    dimension: "Value",
                    icon: "dollarsign.circle.fill",
                    score: viewModel.score.dimensions.value,
                    weight: viewModel.currentWeights.value,
                    explanations: viewModel.valueExplanations,
                    isExpanded: viewModel.isDimensionExpanded("value"),
                    onTap: { viewModel.toggleDimension("value") }
                )
            }
        }
    }
    
    // MARK: - Facilities Section
    private var facilitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Onboard Facilities")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 10) {
                FacilityRowView(icon: "wifi", label: "WiFi", status: viewModel.facilities.wifiStatusEN)
                FacilityRowView(icon: "bolt", label: "Power Outlet", status: viewModel.facilities.powerStatusEN)
                FacilityRowView(icon: "ruler", label: "Seat Pitch", status: viewModel.facilities.seatPitchDisplayEN)
                FacilityRowView(icon: "tv", label: "Entertainment", status: viewModel.facilities.ifeDisplayEN)
                FacilityRowView(icon: "fork.knife", label: "Meal", status: viewModel.facilities.mealDisplayEN)
            }
        }
    }
    
    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flight Timeline")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 0) {
                TimelineRowView(
                    time: viewModel.boardingTimeString,
                    title: "Boarding Gate Opens",
                    subtitle: viewModel.flight.departureAirport,
                    isFirst: true
                )
                
                TimelineRowView(
                    time: viewModel.flight.formattedDepartureTime,
                    title: "Departure",
                    subtitle: viewModel.flight.departureCity,
                    isHighlighted: true
                )
                
                TimelineRowView(
                    time: viewModel.flight.formattedDuration,
                    title: "In Flight",
                    subtitle: viewModel.inflightServicesEN,
                    isDuration: true
                )
                
                TimelineRowView(
                    time: viewModel.flight.formattedArrivalTime,
                    title: "Arrival",
                    subtitle: viewModel.flight.arrivalCity,
                    isHighlighted: true
                )
                
                TimelineRowView(
                    time: viewModel.baggageTimeString,
                    title: "Baggage Claim",
                    subtitle: viewModel.flight.arrivalAirport,
                    isLast: true
                )
            }
        }
    }
    
    // MARK: - Price Section
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Price Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let history = viewModel.priceHistory {
                    HStack(spacing: 4) {
                        Image(systemName: history.trendIcon)
                        Text(history.trendDescriptionEN)
                    }
                    .font(.caption)
                    .foregroundColor(history.trend == .falling ? .green : (history.trend == .rising ? .red : .secondary))
                }
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text(viewModel.flight.formattedPrice)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.aireasePurple)
                
                Text("/ person")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)
                
                Spacer()
                
                Text(viewModel.flight.cabin)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if let history = viewModel.priceHistory {
                MiniPriceChartView(priceHistory: history)
                    .frame(height: 80)
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Favorite Button
                Button(action: viewModel.toggleFavorite) {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        Text(viewModel.isFavorite ? "Saved" : "Save")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.isFavorite ? .red : .aireasePurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(viewModel.isFavorite ? Color.red.opacity(0.1) : Color.aireasePurple.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Price Alert Button
                Button(action: viewModel.showPriceMonitoring) {
                    HStack(spacing: 6) {
                        Image(systemName: "bell")
                        Text("Price Alert")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Book Button
            Button(action: viewModel.showBooking) {
                HStack(spacing: 8) {
                    Text("Book Now")
                        .fontWeight(.semibold)
                    Text("•")
                    Text(viewModel.flight.formattedPrice)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.aireasePurple)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Supporting Views

struct DottedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height * 0.3))
        
        // Wave curve
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height * 0.3),
            control: CGPoint(x: rect.width / 2, y: rect.height * 1.5)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        
        return path
    }
}

struct ScoreRowView: View {
    let label: String
    let score: Double
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.scoreColor(for: score))
                        .frame(width: geo.size.width * (score / 10), height: 4)
                }
            }
            .frame(width: 80, height: 4)
            
            Text(String(format: "%.1f", score))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.scoreColor(for: score))
                .frame(width: 32, alignment: .trailing)
        }
    }
}

struct FacilityRowView: View {
    let icon: String
    let label: String
    let status: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text(status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct TimelineRowView: View {
    let time: String
    let title: String
    let subtitle: String
    var isFirst: Bool = false
    var isLast: Bool = false
    var isHighlighted: Bool = false
    var isDuration: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            Text(time)
                .font(.caption)
                .fontWeight(isHighlighted ? .semibold : .regular)
                .foregroundColor(isHighlighted ? .aireasePurple : .secondary)
                .frame(width: 50, alignment: .trailing)
            
            // Timeline dot and line
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 16)
                }
                
                Circle()
                    .fill(isHighlighted ? Color.aireasePurple : Color.secondary.opacity(0.4))
                    .frame(width: isDuration ? 6 : 10, height: isDuration ? 6 : 10)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 16)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isHighlighted ? .semibold : .regular)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.bottom, isLast ? 0 : 8)
            
            Spacer()
        }
    }
}

struct MiniPriceChartView: View {
    let priceHistory: PriceHistory
    
    var body: some View {
        Chart {
            ForEach(priceHistory.points, id: \.date) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(Color.aireasePurple)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.aireasePurple.opacity(0.2), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            height = y + lineHeight
        }
    }
}

// MARK: - Collapsible Score Card
struct CollapsibleScoreCard: View {
    let dimension: String
    let icon: String
    let score: Double
    let weight: Double
    let explanations: [ScoreExplanation]
    let isExpanded: Bool
    let onTap: () -> Void
    
    var weightPercentage: Int {
        Int(weight * 100)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible) - tappable
            Button(action: onTap) {
                HStack(spacing: 12) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Color.scoreColor(for: score))
                        .frame(width: 24)
                    
                    // Dimension name
                    Text(dimension)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    // Weight badge
                    Text("\(weightPercentage)%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.scoreColor(for: score).opacity(0.8))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // Score
                    Text(String(format: "%.1f", score))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.scoreColor(for: score))
                    
                    // Expand indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(isExpanded ? 12 : 12)
            }
            .buttonStyle(.plain)
            
            // Expanded content with explanations
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    if explanations.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("No specific factors identified for this dimension")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(explanations, id: \.title) { explanation in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: explanation.isPositive ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(explanation.isPositive ? .green : .orange)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(explanation.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(explanation.detail)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.tertiarySystemBackground).opacity(0.5))
                .cornerRadius(12)
                .padding(.top, -8)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        FlightDetailView(flightWithScore: .sample)
    }
}
