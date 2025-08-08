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
    
    /// The selected hours of sleep (defaults to 7.0)
    @State private var selectedHours: Double = 7.0
    
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
    
    /// Array of available sleep hour options (12.0 to 0.0 in reverse order)
    /// This makes scrolling down access larger numbers
    private var sleepHourOptions: [Double] {
        stride(from: 0.0, through: 12.0, by: 0.5).map { $0 }.reversed()
    }
    
    /// Creates a date with 5-minute increments for the DatePicker
    private var roundedBedtime: Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Default to 11:00 PM today
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 23
        components.minute = 0
        
        return calendar.date(from: components) ?? now
    }
    
    /// Helper function to round time to nearest 5-minute increment
    private func roundToFiveMinutes(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let roundedMinute = Int(round(Double(components.minute ?? 0) / 5.0) * 5)
        
        var newComponents = DateComponents()
        newComponents.year = components.year
        newComponents.month = components.month
        newComponents.day = components.day
        newComponents.hour = components.hour
        newComponents.minute = roundedMinute
        
        return calendar.date(from: newComponents) ?? date
    }
    
    /// Checks if the current selection is valid for saving
    private var canSave: Bool {
        // Always require valid hours regardless of bedtime toggle
        return selectedHours > 0
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
            
            // MARK: - Hours Section
            VStack(spacing: 20) {
                Text("How many hours did you sleep?")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 10) {
                    // Large display of selected hours
                    HStack(spacing: 8) {
                        Text(String(format: "%.1f", selectedHours))
                            .font(.system(size: 48, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("hours")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    
                    // Horizontal picker (hidden when bedtime is included)
                    if !includeBedtime {
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(sleepHourOptions, id: \.self) { hour in
                                Text(String(format: "%.1f", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                        .clipShape(Rectangle())
                    }
                }
            }
            .padding(.vertical, 10)
            
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
            
            // MARK: - Bedtime Section (shown when bedtime IS included)
            if includeBedtime {
                VStack(spacing: 20) {
                    FiveMinuteDatePicker(
                        selection: Binding(
                            get: { bedtime ?? roundedBedtime },
                            set: { bedtime = $0 }
                        )
                    )
                    .frame(height: 120)
                }
                .padding(.top, 20) // Extra padding above bedtime picker
                .padding(.vertical, 10)
            }
            
            // MARK: - Bedtime Toggle
            VStack(spacing: 15) {
                HStack {
                    Toggle("Include bedtime", isOn: $includeBedtime)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .contentShape(Rectangle()) // Ensures the entire HStack area is tappable
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
        let hoursToSave: Double
        let bedtimeToSave: Date?
        
        // Always use the manually selected hours
        hoursToSave = selectedHours
        
        // Include bedtime only if toggle is on
        bedtimeToSave = includeBedtime ? bedtime : nil
        
        // Check for recent entries within the last 4 hours
        if let duplicateEntry = findRecentEntry(withinHours: 4) {
            pendingSleepData = (hoursToSave, wasInterrupted, bedtimeToSave)
            recentEntry = duplicateEntry
            showingDuplicateAlert = true
        } else {
            saveSleepEntry(hours: hoursToSave, interrupted: wasInterrupted, bedtime: bedtimeToSave)
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
        selectedHours = 7.0
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

// MARK: - Custom Five-Minute DatePicker

/// A custom DatePicker wrapper that enforces 5-minute intervals natively
struct FiveMinuteDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    
    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = 5 // This is the key - native 5-minute snapping!
        
        datePicker.addTarget(
            context.coordinator,
            action: #selector(Coordinator.dateChanged(_:)),
            for: .valueChanged
        )
        
        return datePicker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selection
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: FiveMinuteDatePicker
        
        init(_ parent: FiveMinuteDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selection = sender.date
        }
    }
}

// MARK: - Preview

#Preview {
    SleepLogView()
        .modelContainer(for: SleepEntry.self, inMemory: true)
}