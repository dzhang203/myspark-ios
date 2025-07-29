//
//  SummaryView.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData
import Charts // Learning Note: Swift Charts for data visualization (iOS 16+)

/// The Summary tab showing energy analytics and charts
/// Learning Note: This will demonstrate data aggregation and chart creation
struct SummaryView: View {
    
    // MARK: - SwiftData Environment
    
    /// Query to fetch all energy entries for analysis
    /// Learning Note: We'll analyze this data to show patterns and trends
    @Query(sort: [SortDescriptor(\EnergyEntry.timestamp, order: .reverse)]) 
    private var energyEntries: [EnergyEntry]
    
    // MARK: - Computed Properties
    
    /// Get entries from the last 7 days for the weekly chart
    /// Learning Note: Date filtering is common in analytics views
    private var lastWeekEntries: [EnergyEntry] {
        guard let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
            return []
        }
        return energyEntries.filter { $0.timestamp >= weekAgo }
    }
    
    /// Calculate average energy level for the week
    /// Learning Note: reduce() is a functional programming method for aggregation
    private var weeklyAverage: Double {
        guard !lastWeekEntries.isEmpty else { return 0 }
        let sum = lastWeekEntries.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(lastWeekEntries.count)
    }
    
    /// Group entries by 30-minute intervals for the chart
    /// Learning Note: This creates time-based data points for visualization
    private var chartData: [ChartDataPoint] {
        // For now, we'll create a simple daily average chart
        // Later we can enhance this to show 30-minute intervals
        let dayGroups = Dictionary(grouping: lastWeekEntries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
        
        return dayGroups.compactMap { (day, entries) in
            let average = entries.reduce(0) { $0 + $1.rating } / entries.count
            return ChartDataPoint(date: day, value: Double(average))
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    
                    if energyEntries.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Data to Analyze")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Log some energy levels to see your patterns and trends")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                        
                    } else {
                        // MARK: - Weekly Stats Cards
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            
                            // Total Entries Card
                            StatCard(
                                title: "This Week",
                                value: "\(lastWeekEntries.count)",
                                subtitle: "entries",
                                icon: "calendar.badge.plus",
                                color: .blue
                            )
                            
                            // Average Energy Card
                            StatCard(
                                title: "Average",
                                value: String(format: "%.1f", weeklyAverage),
                                subtitle: "⭐ energy",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Weekly Energy Chart
                        if !chartData.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Energy Over Time")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                // Simple chart placeholder - we'll enhance this later
                                // Learning Note: For now, we'll create a basic line chart
                                Chart(chartData) { dataPoint in
                                    LineMark(
                                        x: .value("Date", dataPoint.date),
                                        y: .value("Energy", dataPoint.value)
                                    )
                                    .foregroundStyle(.blue)
                                    .interpolationMethod(.catmullRom) // Smooth curves
                                    
                                    AreaMark(
                                        x: .value("Date", dataPoint.date),
                                        y: .value("Energy", dataPoint.value)
                                    )
                                    .foregroundStyle(.blue.opacity(0.1))
                                    .interpolationMethod(.catmullRom)
                                }
                                .frame(height: 200)
                                .chartYScale(domain: 1...5) // Energy scale 1-5
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { _ in
                                        AxisGridLine()
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisGridLine()
                                        AxisValueLabel {
                                            if let intValue = value.as(Double.self) {
                                                Text("\(Int(intValue))⭐")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                        
                        // MARK: - Recent Insights
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Insights")
                                .font(.headline)
                            
                            if weeklyAverage > 3.5 {
                                InsightCard(
                                    icon: "sparkles",
                                    title: "Great Energy Week!",
                                    description: "Your average energy this week is above 3.5 stars. Keep it up!",
                                    color: .green
                                )
                            } else if weeklyAverage < 2.5 {
                                InsightCard(
                                    icon: "moon.zzz",
                                    title: "Low Energy Pattern",
                                    description: "Consider what might be affecting your energy levels this week.",
                                    color: .orange
                                )
                            } else {
                                InsightCard(
                                    icon: "chart.line.flattrend.xyaxis",
                                    title: "Moderate Energy",
                                    description: "Your energy levels are steady. Look for patterns to optimize further.",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Supporting Data Types

/// Data structure for chart points
/// Learning Note: Simple data models make chart creation easier
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Supporting View Components

/// A card displaying a statistic with icon and color
/// Learning Note: Reusable components keep views clean and consistent
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// A card displaying insights about energy patterns
/// Learning Note: Contextual insights make data more actionable
struct InsightCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    SummaryView()
        .modelContainer(for: EnergyEntry.self, inMemory: true)
}