//
//  ContentView.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData

/// The main energy logging screen for MySpark
/// This is where users will rate their current energy level on a 1-5 scale
struct ContentView: View {
    
    // MARK: - SwiftData Environment
    
    /// The model context allows us to save and fetch data from SwiftData
    /// Learning Note: @Environment is SwiftUI's dependency injection system
    /// The modelContext was injected in MySparkApp.swift via .modelContainer()
    @Environment(\.modelContext) private var modelContext
    
    /// Query to fetch all energy entries for testing/debugging
    /// Learning Note: @Query automatically fetches data and updates the view when data changes
    /// This is SwiftData's equivalent to Core Data's @FetchRequest
    @Query private var energyEntries: [EnergyEntry]
    
    // MARK: - UI State
    
    /// Tracks which star rating is currently selected (0 = none, 1-5 = rating)
    /// Learning Note: @State is for temporary UI state that doesn't need to persist
    /// When this changes, SwiftUI automatically redraws the affected parts of the view
    @State private var selectedRating: Int = 0
    
    /// Shows feedback when an entry is successfully saved
    /// Learning Note: We'll use this to show a brief "Saved!" message
    @State private var showingSavedMessage: Bool = false
    
    /// Stores the timestamp of the last saved entry for the feedback message
    /// Learning Note: We need this to show the exact time when the entry was logged
    @State private var lastSavedTimestamp: Date = Date()
    
    // MARK: - Computed Properties
    
    /// Creates the feedback message showing star emojis and timestamp
    /// Learning Note: Computed properties recalculate when their dependencies change
    private var feedbackMessage: String {
        // Create string with the number of star emojis matching the rating
        // Learning Note: String(repeating:count:) creates repeated characters
        let starEmojis = String(repeating: "⭐", count: selectedRating)
        
        // Format the timestamp as HH:MM AM/PM
        // Learning Note: DateFormatter is the standard way to format dates in Swift
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // "h" = 12-hour format, "a" = AM/PM
        let timeString = formatter.string(from: lastSavedTimestamp)
        
        return "\(starEmojis) energy logged at \(timeString)!"
    }
    
    // MARK: - View Body
    
    var body: some View {
        // NavigationView provides the overall structure and navigation capabilities
        // Learning Note: NavigationView is the container for navigation-based interfaces
        NavigationView {
            // VStack arranges views vertically (top to bottom)
            // Learning Note: VStack is one of SwiftUI's fundamental layout containers
            VStack(spacing: 30) {
                
                // Top spacing to push content toward center
                Spacer()
                
                // MARK: - Main Prompt
                VStack(spacing: 20) {
                    // Main question text
                    Text("How's your energy right now?")
                        .font(.title2) // Learning Note: .font() modifier sets text styling
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary) // Learning Note: .primary adapts to light/dark mode
                    
                    // Subtitle for guidance
                    Text("Tap a star to rate your energy level")
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Learning Note: .secondary is muted text color
                        .multilineTextAlignment(.center)
                }
                
                // MARK: - Star Rating Interface
                HStack(spacing: 20) {
                    // Create 5 star buttons using ForEach
                    // Learning Note: ForEach creates multiple views from a range or collection
                    ForEach(1...5, id: \.self) { rating in
                        StarButton(
                            rating: rating,
                            isSelected: selectedRating >= rating, // Changed: now shows all stars up to selected rating
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
                        .transition(.opacity) // Learning Note: .transition() animates view appearance/disappearance
                }
                
                // MARK: - Debug Info (will remove later)
                if !energyEntries.isEmpty {
                    VStack {
                        Text("Recent Entries (Debug)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Show the last few entries for testing
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
            .padding(.horizontal, 30) // Learning Note: .padding() adds space around content
            .navigationTitle("MySpark") // Learning Note: Sets the navigation bar title
            .navigationBarTitleDisplayMode(.inline) // Learning Note: Makes title smaller and centered
        }
    }
    
    // MARK: - Actions
    
    /// Handles when a user taps a star to rate their energy
    /// - Parameter rating: The energy rating (1-5) that was tapped
    private func handleStarTap(rating: Int) {
        // Update the selected rating for visual feedback
        selectedRating = rating
        
        // Create and save the energy entry
        // Learning Note: We're creating our custom EnergyEntry model here
        let newEntry = EnergyEntry(rating: rating)
        
        // Store the timestamp for the feedback message
        // Learning Note: We capture this to show the exact time in our success message
        lastSavedTimestamp = newEntry.timestamp
        
        // Insert into SwiftData
        // Learning Note: modelContext.insert() adds the object to the database
        modelContext.insert(newEntry)
        
        // Show success feedback with animation
        // Learning Note: withAnimation {} animates any state changes inside the block
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSavedMessage = true
        }
        
        // Hide the success message after 2 seconds
        // Learning Note: DispatchQueue.main.asyncAfter schedules code to run later
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSavedMessage = false
                selectedRating = 0 // Reset selection
            }
        }
        
        // Try to save changes immediately
        // Learning Note: SwiftData usually auto-saves, but we can force it
        do {
            try modelContext.save()
        } catch {
            // Learning Note: In a production app, we'd show user-friendly error messages
            print("Error saving energy entry: \(error)")
        }
    }
}

// MARK: - Star Button Component

/// A custom button that displays as a star for energy rating
/// Learning Note: Creating custom components keeps our main view clean and reusable
struct StarButton: View {
    let rating: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            // SF Symbols provide system icons that match iOS design
            // Learning Note: "star" vs "star.fill" gives us outline vs filled versions
            Image(systemName: isSelected ? "star.fill" : "star")
                .font(.system(size: 40)) // Learning Note: .system(size:) controls SF Symbol size
                .foregroundColor(isSelected ? .yellow : .gray)
                .scaleEffect(isSelected ? 1.2 : 1.0) // Learning Note: .scaleEffect() makes selected stars bigger
                .animation(.easeInOut(duration: 0.2), value: isSelected) // Learning Note: Animates the scale change
        }
        .buttonStyle(PlainButtonStyle()) // Learning Note: Removes default button styling
    }
}

// MARK: - Preview

/// SwiftUI Preview for development
/// Learning Note: #Preview allows us to see the view in Xcode's canvas while developing
#Preview {
    ContentView()
        .modelContainer(for: EnergyEntry.self, inMemory: true) // Learning Note: inMemory: true for preview testing
}
