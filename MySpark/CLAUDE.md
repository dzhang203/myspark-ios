# MySpark - Energy Tracker iOS App

## Project Overview
**MySpark** is a personal energy tracking iOS app built with Swift and SwiftUI, inspired by Piyolog. Users can log their energy levels on a 1-5 star scale and view patterns over time.

## Current Status: ✅ MVP COMPLETE

### Completed Features
- ✅ **Core Data Model**: `EnergyEntry` with SwiftData persistence
- ✅ **Energy Logging**: 1-5 star rating interface with visual feedback
- ✅ **Duplicate Prevention**: 10-minute window with replace/cancel dialog
- ✅ **Tab Navigation**: 3-tab structure (Log, History, Summary)
- ✅ **History View**: Entries grouped by day with "Today/Yesterday" formatting
- ✅ **Summary View**: Weekly stats, line charts, and insights
- ✅ **App Icon**: Custom MySpark icon installed
- ✅ **Attribution**: "Designed with ❤️ by David Zhang" in main tab

### Technical Architecture
```
MySpark/
├── MySparkApp.swift          # App entry point + SwiftData setup
├── ContentView.swift         # TabView container
├── EnergyLogView.swift       # Star rating interface
├── HistoryView.swift         # Grouped entry list
├── SummaryView.swift         # Charts & analytics
├── EnergyEntry.swift         # Data model
└── Assets.xcassets/
    └── AppIcon.appiconset/   # App icon (myspark-app-icon.png)
```

### Key Technical Implementations

#### Data Model (`EnergyEntry.swift`)
- SwiftData `@Model` with UUID, rating (1-5), timestamp
- Computed properties: `energyDescription`, `energyEmoji`, validation helpers
- Extensions for convenience methods

#### Energy Logging (`EnergyLogView.swift`)
- 5-star rating system with fill-up animation
- 10-minute duplicate detection with user choice dialog
- Success feedback with star emojis and timestamp
- SwiftData integration for persistence

#### History (`HistoryView.swift`)
- Entries grouped by day using `Dictionary(grouping:)`
- Smart date headers: "Today", "Yesterday", full dates
- Custom `EnergyEntryRow` component
- Empty state handling

#### Summary (`SummaryView.swift`) 
- Weekly statistics with `StatCard` components
- Swift Charts line graph with energy trends
- Contextual insights based on average energy
- Grid layout for statistics display

#### Navigation (`ContentView.swift`)
- `TabView` with enum-based tab management
- SF Symbol icons with selected/unselected states
- Custom tab bar appearance

### Key Learning Concepts Covered
- **SwiftData**: `@Model`, `@Query`, `ModelContainer`, persistence
- **SwiftUI State**: `@State`, `@Environment`, computed properties
- **Navigation**: `TabView`, `NavigationView`, tab management
- **UI Components**: Custom buttons, animations, alerts
- **Data Processing**: Date arithmetic, array filtering, grouping
- **Charts**: Swift Charts framework integration

### App Flow
1. **Log Tab**: User taps stars → duplicate check → save with feedback
2. **History Tab**: Browse all entries grouped by day
3. **Summary Tab**: View weekly stats, trends, and insights

### Next Steps (Future Development)
- Remove debug info from EnergyLogView
- Add more chart types (daily patterns, weekly comparisons)
- Implement data export functionality
- Add onboarding flow
- Consider widget implementation
- Add settings/preferences
- Enhance insights with more sophisticated analysis

### Development Commands
```bash
# Navigate to project
cd /Users/davidzhang/github/myspark-ios/MySpark

# Open in Xcode
open MySpark.xcodeproj

# Or run from command line (if you have iOS Simulator)
xcodebuild -project MySpark.xcodeproj -scheme MySpark -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Project Structure Notes
- **Main Branch**: `main` (clean, ready for sideloading)
- **SwiftData Schema**: Single `EnergyEntry` model
- **iOS Version**: Targets iOS 17+ (for SwiftData and Swift Charts)
- **Dependencies**: None (uses built-in frameworks only)

### Recent Changes
- Added attribution message to main log screen
- Installed custom app icon (myspark-app-icon.png)
- Completed full MVP with all three tabs functional
- **Fixed sideloading**: Removed iCloud/Push entitlements for personal dev account compatibility

### Sideloading Notes
- **Entitlements cleaned**: Removed iCloud and Push Notifications for free Apple ID compatibility
- **Local storage only**: MySpark uses SwiftData with local persistence (no cloud dependency)
- **Future notifications**: Plan to add local notifications (compatible with free accounts)

---

**Status**: Ready for testing and sideloading! 🚀

All core functionality is complete and the app should run smoothly on device or simulator.