//
//  EnergyLogView.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData

/// The main energy logging screen where users rate their current energy level
/// Learning Note: This is our core logging interface, extracted from ContentView
struct EnergyLogView: View {
    
    // MARK: - SwiftData Environment
    
    /// The model context allows us to save and fetch data from SwiftData
    /// Learning Note: @Environment is SwiftUI's dependency injection system
    @Environment(\.modelContext) private var modelContext
    
    /// Query to fetch all energy entries for duplicate checking and debugging
    /// Learning Note: @Query automatically fetches data and updates the view when data changes
    @Query private var energyEntries: [EnergyEntry]
    
    // MARK: - UI State
    
    /// Tracks which star rating is currently selected (0 = none, 1-5 = rating)
    /// Learning Note: @State is for temporary UI state that doesn't need to persist
    @State private var selectedRating: Int = 0
    
    /// Shows feedback when an entry is successfully saved
    @State private var showingSavedMessage: Bool = false
    
    /// Stores the timestamp of the last saved entry for the feedback message
    @State private var lastSavedTimestamp: Date = Date()
    
    /// Controls whether the duplicate entry alert is shown
    @State private var showingDuplicateAlert: Bool = false
    
    /// Stores the rating that the user tried to log (for use in the alert)
    @State private var pendingRating: Int = 0
    
    /// The recent entry that would be replaced (if user chooses to replace)
    @State private var recentEntry: EnergyEntry? = nil
    
    // MARK: - Computed Properties
    
    /// Creates the feedback message showing star emojis and timestamp
    /// Learning Note: Computed properties recalculate when their dependencies change
    private var feedbackMessage: String {
        let starEmojis = String(repeating: "⭐", count: selectedRating)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: lastSavedTimestamp)
        return "\(starEmojis) energy logged at \(timeString)!"
    }
    
    /// Creates the duplicate alert message with star emojis for both ratings
    private var duplicateAlertMessage: String {
        guard let recent = recentEntry else { return "" }
        
        let starEmojisRecent = String(repeating: "⭐", count: recent.rating)
        let starEmojisPending = String(repeating: "⭐", count: pendingRating)
        let timeAgo = timeAgoString(from: recent.timestamp)
        
        return "You logged \(starEmojisRecent) energy \(timeAgo). Replace it with your new \(starEmojisPending) rating?"
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Top spacing to push content toward center
            Spacer()
            
            // MARK: - App Title & Attribution
            VStack(spacing: 8) {
                Text("MySpark")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Designed with ❤️ by David Zhang")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // MARK: - Main Prompt
            VStack(spacing: 20) {
                Text("How's your energy right now?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Tap a star to rate your energy level")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // MARK: - Star Rating Interface
            HStack(spacing: 20) {
                ForEach(1...5, id: \.self) { rating in
                    StarButton(
                        rating: rating,
                        isSelected: selectedRating >= rating,
                        action: { handleStarTap(rating: rating) }
                    )
                }
            }
            .padding(.vertical, 20)
            
            // MARK: - Feedback Messages
            if showingSavedMessage {
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            
            // MARK: - Debug Info (will remove later)
            if !energyEntries.isEmpty {
                VStack {
                    Text("Recent Entries (Debug)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(energyEntries.suffix(3), id: \.id) { entry in
                        Text("\(entry.energyEmoji) \(entry.energyDescription) - \(entry.timestamp, format: .dateTime.hour().minute())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
        
        // MARK: - Duplicate Entry Alert
        .alert("Recent Entry Found", isPresented: $showingDuplicateAlert) {
            Button("Replace") {
                replaceRecentEntry()
            }
            
            Button("Cancel", role: .cancel) {
                selectedRating = 0
                pendingRating = 0
                recentEntry = nil
            }
        } message: {
            Text(duplicateAlertMessage)
        }
    }
    
    // MARK: - Actions
    
    /// Handles when a user taps a star to rate their energy
    private func handleStarTap(rating: Int) {
        selectedRating = rating
        
        // Check for recent entries within the last 10 minutes
        if let duplicateEntry = findRecentEntry(withinMinutes: 10) {
            pendingRating = rating
            recentEntry = duplicateEntry
            showingDuplicateAlert = true
        } else {
            saveEnergyEntry(rating: rating)
        }
    }
    
    /// Finds an energy entry within the specified number of minutes from now
    private func findRecentEntry(withinMinutes minutes: Int) -> EnergyEntry? {
        guard let cutoffTime = Calendar.current.date(byAdding: .minute, value: -minutes, to: Date()) else {
            return nil
        }
        
        let recentEntries = energyEntries
            .filter { $0.timestamp > cutoffTime }
            .sorted { $0.timestamp > $1.timestamp }
        
        return recentEntries.first
    }
    
    /// Saves a new energy entry
    private func saveEnergyEntry(rating: Int) {
        let newEntry = EnergyEntry(rating: rating)
        lastSavedTimestamp = newEntry.timestamp
        modelContext.insert(newEntry)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSavedMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSavedMessage = false
                selectedRating = 0
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving energy entry: \(error)")
        }
    }
    
    /// Handles replacing a recent entry with a new rating
    private func replaceRecentEntry() {
        if let oldEntry = recentEntry {
            modelContext.delete(oldEntry)
        }
        
        saveEnergyEntry(rating: pendingRating)
        
        recentEntry = nil
        pendingRating = 0
    }
    
    /// Creates a user-friendly "time ago" string from a timestamp
    private func timeAgoString(from date: Date) -> String {
        let secondsAgo = Int(Date().timeIntervalSince(date))
        
        if secondsAgo < 60 {
            return "just now"
        } else if secondsAgo < 120 {
            return "1 minute ago"
        } else {
            let minutesAgo = secondsAgo / 60
            return "\(minutesAgo) minutes ago"
        }
    }
}

// MARK: - Star Button Component

/// A custom button that displays as a star for energy rating
struct StarButton: View {
    let rating: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "star.fill" : "star")
                .font(.system(size: 40))
                .foregroundColor(isSelected ? .yellow : .gray)
                .scaleEffect(isSelected ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    EnergyLogView()
        .modelContainer(for: EnergyEntry.self, inMemory: true)
}