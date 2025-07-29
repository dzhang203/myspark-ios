//
//  HistoryView.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData

/// The History tab showing all energy entries grouped by day
/// Learning Note: This demonstrates list grouping and date formatting in SwiftUI
struct HistoryView: View {
    
    // MARK: - SwiftData Environment
    
    /// Query to fetch all energy entries, sorted by most recent first
    /// Learning Note: @Query with sort descriptors automatically keeps data sorted
    @Query(sort: [SortDescriptor(\EnergyEntry.timestamp, order: .reverse)]) 
    private var energyEntries: [EnergyEntry]
    
    // MARK: - Computed Properties
    
    /// Groups entries by day for organized display
    /// Learning Note: Dictionary(grouping:) is a powerful Swift function for categorizing data
    private var entriesByDay: [Date: [EnergyEntry]] {
        // Group entries by their date (ignoring time)
        // Learning Note: Calendar.current.startOfDay() normalizes dates to midnight
        Dictionary(grouping: energyEntries) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }
    }
    
    /// Get sorted days for consistent display order
    /// Learning Note: Dictionary keys are unordered, so we need to sort them
    private var sortedDays: [Date] {
        entriesByDay.keys.sorted(by: >)  // Most recent day first
    }
    
    // MARK: - View Body
    
    var body: some View {
        NavigationView {
            Group {
                if energyEntries.isEmpty {
                    // Empty state when no entries exist
                    // Learning Note: Providing empty states improves user experience
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Energy Logs Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start logging your energy levels to see your history here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // List of entries grouped by day
                    List {
                        ForEach(sortedDays, id: \.self) { day in
                            Section {
                                // Entries for this day
                                ForEach(entriesByDay[day] ?? [], id: \.id) { entry in
                                    EnergyEntryRow(entry: entry)
                                }
                            } header: {
                                // Day header (e.g., "Today", "Yesterday", "Monday, Jan 15")
                                Text(dayHeaderText(for: day))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large) // Learning Note: .large gives a bigger, scrollable title
        }
    }
    
    // MARK: - Helper Functions
    
    /// Creates user-friendly day headers like "Today", "Yesterday", or formatted dates
    /// - Parameter day: The date to format
    /// - Returns: A user-friendly string representation
    /// Learning Note: This improves UX by using relative date descriptions
    private func dayHeaderText(for day: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(day) {
            return "Today"
        } else if calendar.isDateInYesterday(day) {
            return "Yesterday"
        } else {
            // For older dates, show the full date
            let formatter = DateFormatter()
            formatter.dateStyle = .full // "Monday, January 15, 2024"
            return formatter.string(from: day)
        }
    }
}

// MARK: - Energy Entry Row Component

/// A single row displaying an energy entry in the history list
/// Learning Note: Breaking UI into small components makes code more maintainable
struct EnergyEntryRow: View {
    let entry: EnergyEntry
    
    var body: some View {
        HStack(spacing: 15) {
            // Energy level with emoji and stars
            VStack(alignment: .leading, spacing: 4) {
                // Star rating display
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= entry.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(star <= entry.rating ? .yellow : .gray)
                    }
                }
                
                // Energy description
                Text(entry.energyDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Timestamp
            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.timestamp, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(entry.energyEmoji)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .modelContainer(for: EnergyEntry.self, inMemory: true)
}