//
//  EnergyEntry.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import Foundation
import SwiftData

/// Represents a single energy level entry in the MySpark app
/// This is our core data model that stores each time a user logs their energy
@Model
final class EnergyEntry {
    // MARK: - Properties
    
    /// Unique identifier for this energy entry
    /// Learning Note: UUID (Universally Unique Identifier) ensures each entry has a unique ID
    /// SwiftData uses this for object identity and relationships
    /// Benefits over String: type safety, validation, performance, optimization (e.g. for indexing)
    var id: UUID
    
    /// The user's energy rating on a scale of 1-5
    /// Learning Note: We use Int instead of an enum to make SwiftData persistence simpler
    /// 1 = Very Low Energy, 2 = Low, 3 = Moderate, 4 = High, 5 = Very High
    var rating: Int
    
    /// When this energy entry was created
    /// Learning Note: Date is Swift's built-in type for timestamps; has nanosecond precision
    /// SwiftData automatically handles Date serialization/deserialization
    var timestamp: Date
    
    // MARK: - Initialization
    
    /// Creates a new energy entry
    /// - Parameters:
    ///   - rating: Energy level from 1-5
    ///   - timestamp: When the entry was created (defaults to now)
    /// Learning Note: Default parameter values make the API more convenient
    /// Most of the time we'll log energy "right now", so timestamp defaults to Date()
    init(rating: Int, timestamp: Date = Date()) {
        // Learning Note: UUID() generates a new random UUID each time
        self.id = UUID()
        self.rating = rating
        self.timestamp = timestamp
    }
    
    // MARK: - Computed Properties
    
    /// Returns a user-friendly description of the energy level
    /// Learning Note: Computed properties are calculated on-demand, not stored
    /// This makes our UI code cleaner by centralizing the rating-to-text logic
    var energyDescription: String {
        switch rating {
        case 1: return "Very Low"
        case 2: return "Low" 
        case 3: return "Moderate"
        case 4: return "High"
        case 5: return "Very High"
        default: return "Unknown" // Safety fallback, should never happen
        }
    }
    
    /// Returns an emoji representation of the energy level
    /// Learning Note: Swift has excellent Unicode support, making emoji easy to use
    var energyEmoji: String {
        switch rating {
        case 1: return "😴" // Very Low - Sleeping
        case 2: return "😔" // Low - Tired
        case 3: return "😐" // Moderate - Neutral
        case 4: return "😊" // High - Happy
        case 5: return "⚡" // Very High - Lightning bolt
        default: return "❓" // Unknown
        }
    }
}

// MARK: - Extensions

/// Learning Note: Extensions allow us to add functionality to existing types
/// We can add convenience methods, computed properties, or protocol conformance
extension EnergyEntry {
    
    /// Validates that the rating is within the acceptable range (1-5)
    /// Learning Note: This is a good practice for data validation
    /// Even though our UI will prevent invalid ratings, defensive programming is important
    var isValidRating: Bool {
        return rating >= 1 && rating <= 5
    }
    
    /// Returns true if this entry was created today
    /// Learning Note: Calendar.current gives us the user's current calendar
    /// isDate(_:inSameDayAs:) is a convenient method for date comparison
    var isFromToday: Bool {
        return Calendar.current.isDate(timestamp, inSameDayAs: Date())
    }
}
