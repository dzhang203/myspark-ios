//
//  SleepEntry.swift
//  MySpark
//
//  Created by David Zhang on 8/8/25.
//

import Foundation
import SwiftData

/// Represents a single sleep entry in the MySpark app
/// This is our sleep tracking data model that stores sleep duration and quality info
@Model
final class SleepEntry {
    // MARK: - Properties
    
    /// Unique identifier for this sleep entry
    var id: UUID
    
    /// The amount of sleep in hours (supports decimal values like 7.5)
    var hoursSlept: Double
    
    /// Optional indicator if sleep was interrupted during the night
    /// nil = not specified, true = interrupted, false = not interrupted
    var wasInterrupted: Bool?
    
    /// Optional time when the user fell asleep (bedtime)
    /// Accurate to 15-minute increments as per requirements
    var bedtime: Date?
    
    /// When this sleep entry was logged/created
    var timestamp: Date
    
    // MARK: - Initialization
    
    /// Creates a new sleep entry
    /// - Parameters:
    ///   - hoursSlept: Amount of sleep in hours (e.g., 7.5)
    ///   - wasInterrupted: Optional - whether sleep was interrupted
    ///   - bedtime: Optional - when user fell asleep
    ///   - timestamp: When the entry was created (defaults to now)
    init(hoursSlept: Double, wasInterrupted: Bool? = nil, bedtime: Date? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.hoursSlept = hoursSlept
        self.wasInterrupted = wasInterrupted
        self.bedtime = bedtime
        self.timestamp = timestamp
    }
    
    // MARK: - Computed Properties
    
    /// Returns a user-friendly description of sleep quality
    var sleepQualityDescription: String {
        guard let interrupted = wasInterrupted else {
            return "Not specified"
        }
        return interrupted ? "Interrupted" : "Uninterrupted"
    }
    
    /// Returns an emoji representation of sleep quality
    var sleepQualityEmoji: String {
        guard let interrupted = wasInterrupted else {
            return "😴" // Default sleep emoji
        }
        return interrupted ? "😵‍💫" : "😴"
    }
    
    /// Returns formatted hours string (e.g., "7.5 hours")
    var formattedHours: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        
        let hoursString = formatter.string(from: NSNumber(value: hoursSlept)) ?? "\(hoursSlept)"
        return "\(hoursString) hours"
    }
    
    /// Returns formatted bedtime string if available
    var formattedBedtime: String? {
        guard let bedtime = bedtime else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: bedtime)
    }
}

// MARK: - Extensions

extension SleepEntry {
    
    /// Validates that the hours slept is within a reasonable range (0-24)
    var isValidHours: Bool {
        return hoursSlept >= 0 && hoursSlept <= 24
    }
    
    /// Returns true if this entry was created today
    var isFromToday: Bool {
        return Calendar.current.isDate(timestamp, inSameDayAs: Date())
    }
    
    /// Returns sleep quality category based on hours
    var sleepCategory: String {
        switch hoursSlept {
        case 0..<4:
            return "Very Short"
        case 4..<6:
            return "Short"
        case 6..<8:
            return "Adequate" 
        case 8..<10:
            return "Good"
        default:
            return "Long"
        }
    }
    
    /// Returns an emoji for the sleep duration category
    var sleepCategoryEmoji: String {
        switch hoursSlept {
        case 0..<4:
            return "😵" // Very tired
        case 4..<6:
            return "😪" // Sleepy
        case 6..<8:
            return "😌" // Content
        case 8..<10:
            return "😊" // Happy
        default:
            return "😴" // Well rested
        }
    }
}