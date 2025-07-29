//
//  ContentView.swift
//  MySpark
//
//  Created by David Zhang on 7/28/25.
//

import SwiftUI
import SwiftData

/// The main container view that provides tab-based navigation for MySpark
/// Learning Note: This is the root view that organizes our app into tabs like Piyolog
struct ContentView: View {
    
    // MARK: - Tab Selection State
    
    /// Tracks which tab is currently selected
    /// Learning Note: @State manages the current tab selection
    /// TabView uses this to determine which view to show
    @State private var selectedTab: Tab = .log
    
    // MARK: - Tab Enumeration
    
    /// Defines the available tabs in our app
    /// Learning Note: Enums are perfect for representing a fixed set of options
    /// CaseIterable allows us to iterate over all cases if needed
    enum Tab: String, CaseIterable {
        case log = "Log"
        case history = "History" 
        case summary = "Summary"
        
        /// SF Symbol icon for each tab
        /// Learning Note: Computed properties on enums provide associated data
        var icon: String {
            switch self {
            case .log: return "star.circle"
            case .history: return "list.bullet.clipboard"
            case .summary: return "chart.line.uptrend.xyaxis"
            }
        }
        
        /// Alternative icon when tab is selected (filled version)
        /// Learning Note: This provides visual feedback for the active tab
        var selectedIcon: String {
            switch self {
            case .log: return "star.circle.fill"
            case .history: return "list.bullet.clipboard.fill"
            case .summary: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        // TabView is SwiftUI's container for tab-based navigation
        // Learning Note: TabView automatically creates a tab bar at the bottom
        TabView(selection: $selectedTab) {
            
            // MARK: - Energy Logging Tab
            NavigationView {
                EnergyLogView()
                    .navigationTitle("MySpark")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                // Tab bar item configuration
                // Learning Note: tabItem defines what appears in the tab bar
                Image(systemName: selectedTab == .log ? Tab.log.selectedIcon : Tab.log.icon)
                Text(Tab.log.rawValue)
            }
            .tag(Tab.log) // Learning Note: tag() connects this view to the enum case
            
            // MARK: - History Tab
            HistoryView()
                .tabItem {
                    Image(systemName: selectedTab == .history ? Tab.history.selectedIcon : Tab.history.icon)
                    Text(Tab.history.rawValue)
                }
                .tag(Tab.history)
            
            // MARK: - Summary Tab
            SummaryView()
                .tabItem {
                    Image(systemName: selectedTab == .summary ? Tab.summary.selectedIcon : Tab.summary.icon)
                    Text(Tab.summary.rawValue)
                }
                .tag(Tab.summary)
        }
        // Customize tab bar appearance
        // Learning Note: These modifiers control the overall tab bar styling
        .accentColor(.blue) // Color for selected tab items
        .onAppear {
            // Customize tab bar appearance when the view appears
            // Learning Note: UITabBar.appearance() allows global styling of tab bars
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            // Apply the appearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview

/// SwiftUI Preview showing the complete tab structure
/// Learning Note: This preview shows how all our tabs work together
#Preview {
    ContentView()
        .modelContainer(for: EnergyEntry.self, inMemory: true)
}