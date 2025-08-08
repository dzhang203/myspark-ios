//
//  SleepLogView.swift
//  MySpark
//
//  Created by David Zhang on 8/8/25.
//

import SwiftUI
import SwiftData

/// The main sleep logging screen where users log their sleep data
struct SleepLogView: View {
    
    // MARK: - SwiftData Environment
    
    /// The model context allows us to save and fetch data from SwiftData
    @Environment(\.modelContext) private var modelContext
    
    /// Query to fetch all sleep entries for duplicate checking and debugging
    @Query private var sleepEntries: [SleepEntry]
    
    // MARK: - UI State
    
    /// The hours of sleep input as a string (supports decimal like "7.5")
    @State private var hoursInput: String = ""
    
    /// Whether sleep was interrupted (nil = not specified)
    @State private var wasInterrupted: Bool? = nil
    
    /// Optional bedtime selection
    @State private var bedtime: Date? = nil
    
    /// Controls whether bedtime picker is enabled
    @State private var includeBedtime: Bool = false
    
    /// Shows feedback when an entry is successfully saved
    @State private var showingSavedMessage: Bool = false
    
    /// Stores the timestamp of the last saved entry for feedback
    @State private var lastSavedTimestamp: Date = Date()
    
    /// Controls whether the duplicate entry alert is shown
    @State private var showingDuplicateAlert: Bool = false
    
    /// The pending sleep data that user tried to log
    @State private var pendingSleepData: (hours: Double, interrupted: Bool?, bedtime: Date?) = (0, nil, nil)
    
    /// The recent entry that would be replaced
    @State private var recentEntry: SleepEntry? = nil
    
    // MARK: - Computed Properties
    
    /// Converts hours input string to Double, returns nil if invalid
    private var hoursValue: Double? {
        Double(hoursInput)
    }
    
    /// Checks if the current input is valid for saving
    private var canSave: Bool {
        guard let hours = hoursValue else { return false }
        return hours > 0 && hours <= 24
    }
    
    /// Creates the feedback message for successful save
    private var feedbackMessage: String {
        guard let recent = sleepEntries.last else { return "Sleep logged!" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let timeString = formatter.string(from: lastSavedTimestamp)
        return "\(recent.formattedHours) sleep logged at \(timeString)!"
    }
    
    /// Creates the duplicate alert message
    private var duplicateAlertMessage: String {
        guard let recent = recentEntry else { return "" }
        let timeAgo = timeAgoString(from: recent.timestamp)
        return "You logged \(recent.formattedHours) sleep \(timeAgo). Replace it with your new entry?"
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack(spacing: 30) {
            
            Spacer()
            
            // MARK: - Header
            VStack(spacing: 8) {
                Text("Sleep Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Log your sleep from last night")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
            
            // MARK: - Hours Input Section
            VStack(spacing: 15) {
                Text("How many hours did you sleep?")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack {
                    TextField("7.5", text: $hoursInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                    
                    Text("hours")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: - Sleep Interruption Section
            VStack(spacing: 15) {
                Text("Was your sleep interrupted?")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    Button("Yes") {
                        wasInterrupted = true
                    }
                    .buttonStyle(ToggleButtonStyle(isSelected: wasInterrupted == true))
                    
                    Button("No") {
                        wasInterrupted = false
                    }
                    .buttonStyle(ToggleButtonStyle(isSelected: wasInterrupted == false))
                    
                    Button("Skip") {
                        wasInterrupted = nil
                    }
                    .buttonStyle(ToggleButtonStyle(isSelected: wasInterrupted == nil, isSkip: true))
                }
            }
            
            // MARK: - Bedtime Section
            VStack(spacing: 15) {
                HStack {
                    Toggle("Include bedtime", isOn: $includeBedtime)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                if includeBedtime {
                    DatePicker(
                        "When did you fall asleep?",
                        selection: Binding(
                            get: { bedtime ?? Date() },
                            set: { bedtime = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 120)
                }
            }
            
            // MARK: - Save Button
            Button("Log Sleep") {
                handleSaveButtonTap()
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: canSave))
            .disabled(!canSave)
            
            // MARK: - Feedback Messages
            if showingSavedMessage {
                Text(feedbackMessage)
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }
            
            // MARK: - Debug Info
            if !sleepEntries.isEmpty {
                VStack {
                    Text("Recent Sleep Entries (Debug)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(sleepEntries.suffix(3), id: \.id) { entry in
                        HStack {
                            Text("\(entry.sleepCategoryEmoji) \(entry.formattedHours)")
                            if let interrupted = entry.wasInterrupted {
                                Text(interrupted ? "😵‍💫" : "😴")
                            }
                            Text(entry.timestamp, format: .dateTime.hour().minute())
                        }
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
                clearPendingData()
            }
        } message: {
            Text(duplicateAlertMessage)
        }
    }
    
    // MARK: - Actions
    
    /// Handles the save button tap
    private func handleSaveButtonTap() {
        guard let hours = hoursValue else { return }
        
        // Check for recent entries within the last 4 hours
        if let duplicateEntry = findRecentEntry(withinHours: 4) {
            pendingSleepData = (hours, wasInterrupted, includeBedtime ? bedtime : nil)
            recentEntry = duplicateEntry
            showingDuplicateAlert = true
        } else {
            saveSleepEntry(hours: hours, interrupted: wasInterrupted, bedtime: includeBedtime ? bedtime : nil)
        }
    }
    
    /// Finds a sleep entry within the specified number of hours from now
    private func findRecentEntry(withinHours hours: Int) -> SleepEntry? {
        guard let cutoffTime = Calendar.current.date(byAdding: .hour, value: -hours, to: Date()) else {
            return nil
        }
        
        let recentEntries = sleepEntries
            .filter { $0.timestamp > cutoffTime }
            .sorted { $0.timestamp > $1.timestamp }
        
        return recentEntries.first
    }
    
    /// Saves a new sleep entry
    private func saveSleepEntry(hours: Double, interrupted: Bool?, bedtime: Date?) {
        let newEntry = SleepEntry(hoursSlept: hours, wasInterrupted: interrupted, bedtime: bedtime)
        lastSavedTimestamp = newEntry.timestamp
        modelContext.insert(newEntry)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSavedMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSavedMessage = false
                resetForm()
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving sleep entry: \(error)")
        }
    }
    
    /// Handles replacing a recent entry with new data
    private func replaceRecentEntry() {
        if let oldEntry = recentEntry {
            modelContext.delete(oldEntry)
        }
        
        saveSleepEntry(
            hours: pendingSleepData.hours,
            interrupted: pendingSleepData.interrupted,
            bedtime: pendingSleepData.bedtime
        )
        
        clearPendingData()
    }
    
    /// Clears pending data and resets form
    private func clearPendingData() {
        pendingSleepData = (0, nil, nil)
        recentEntry = nil
    }
    
    /// Resets the form to initial state
    private func resetForm() {
        hoursInput = ""
        wasInterrupted = nil
        bedtime = nil
        includeBedtime = false
    }
    
    /// Creates a user-friendly "time ago" string from a timestamp
    private func timeAgoString(from date: Date) -> String {
        let hoursAgo = Int(Date().timeIntervalSince(date) / 3600)
        
        if hoursAgo < 1 {
            return "just now"
        } else if hoursAgo == 1 {
            return "1 hour ago"
        } else {
            return "\(hoursAgo) hours ago"
        }
    }
}

// MARK: - Custom Button Styles

/// Button style for Yes/No/Skip toggle buttons
struct ToggleButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isSkip: Bool
    
    init(isSelected: Bool, isSkip: Bool = false) {
        self.isSelected = isSelected
        self.isSkip = isSkip
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                isSelected ? (isSkip ? Color.gray : Color.blue) : Color.gray.opacity(0.2)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Button style for the primary save button
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isEnabled ? Color.blue : Color.gray)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    SleepLogView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}