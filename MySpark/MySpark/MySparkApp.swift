//
//  MySparkApp.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData

/// The main entry point for the MySpark app
/// Learning Note: @main attribute tells Swift this is where the app starts
/// This is equivalent to a main() function in other languages
@main
struct MySparkApp: App {
    
    /// The shared data container for the entire app
    /// Learning Note: This is a SwiftData ModelContainer that manages our app's persistent storage
    /// All our EnergyEntry objects will be stored and managed through this container
    var sharedModelContainer: ModelContainer = {
        
        // Define the data schema - what types of objects we want to store
        // Learning Note: Schema([...]) tells SwiftData which @Model classes to manage
        // We only have EnergyEntry for now, but we could add more models later
        let schema = Schema([
            EnergyEntry.self,
        ])
        
        // Configure how data should be stored
        // Learning Note: ModelConfiguration controls storage behavior
        // isStoredInMemoryOnly: false means data persists between app launches
        // Setting it to true would make data temporary (useful for testing)
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false
        )

        // Try to create the container, or crash the app if it fails
        // Learning Note: do-catch is Swift's error handling mechanism
        // fatalError() stops the app completely - only use for unrecoverable errors
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// The app's main scene - what gets displayed to the user
    /// Learning Note: 'body' is a computed property that returns a Scene
    /// Scene is SwiftUI's way of describing what gets shown on screen
    var body: some Scene {
        // WindowGroup creates a window that can contain our app's content
        // Learning Note: On iOS, WindowGroup typically creates a full-screen window
        // On macOS, it could create multiple resizable windows
        WindowGroup {
            ContentView()
        }
        // This modifier injects our data container into the SwiftUI environment
        // Learning Note: .modelContainer() makes our data available to all child views
        // Any view in our app can now access and modify EnergyEntry objects
        .modelContainer(sharedModelContainer)
    }
}
