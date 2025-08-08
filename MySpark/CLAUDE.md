# MySpark - Energy Tracker iOS App

## Project Overview
**MySpark** is a personal energy tracking iOS app built with Swift and SwiftUI, inspired by Piyolog. Users can log their energy levels on a 1-5 star scale and view patterns over time.

## Current Status: ✅ ENERGY + SLEEP TRACKING COMPLETE

### Completed Features
- ✅ **Core Data Models**: `EnergyEntry` and `SleepEntry` with SwiftData persistence
- ✅ **Energy Logging**: 1-5 star rating interface with visual feedback
- ✅ **Sleep Logging**: Hours picker (0.5-12.0 hrs) + optional bedtime (5-min increments) + interruption tracking
- ✅ **Duplicate Prevention**: 10-minute window for energy, 4-hour window for sleep
- ✅ **Tab Navigation**: 4-tab structure (Log, Sleep, History, Summary)
- ✅ **History View**: Entries grouped by day with "Today/Yesterday" formatting
- ✅ **Summary View**: Weekly stats, line charts, and insights
- ✅ **App Icon**: Custom MySpark icon installed
- ✅ **Attribution**: "Designed with ❤️ by David Zhang" in main tab

### Technical Architecture
```
MySpark/
├── MySparkApp.swift          # App entry point + SwiftData setup
├── ContentView.swift         # TabView container (4 tabs)
├── EnergyLogView.swift       # Star rating interface
├── SleepLogView.swift        # Sleep hours + bedtime + interruption tracking
├── HistoryView.swift         # Grouped entry list (energy only currently)
├── SummaryView.swift         # Charts & analytics (energy only currently)
├── EnergyEntry.swift         # Energy data model
├── SleepEntry.swift          # Sleep data model
└── Assets.xcassets/
    └── AppIcon.appiconset/   # App icon (myspark-app-icon.png)
```

### Key Technical Implementations

#### Data Models
- **`EnergyEntry.swift`**: SwiftData `@Model` with UUID, rating (1-5), timestamp
  - Computed properties: `energyDescription`, `energyEmoji`, validation helpers
- **`SleepEntry.swift`**: SwiftData `@Model` with UUID, hoursSlept (Double), wasInterrupted (Bool?), bedtime (Date?), timestamp
  - Computed properties: sleep quality descriptions, formatted displays, category classification

#### Energy Logging (`EnergyLogView.swift`)
- 5-star rating system with fill-up animation
- 10-minute duplicate detection with user choice dialog
- Success feedback with star emojis and timestamp
- SwiftData integration for persistence

#### Sleep Logging (`SleepLogView.swift`) 
- Hours picker: 0.0-12.0 in 0.5 increments, defaults to 7.0, scroll up for larger values
- Optional bedtime: Native DatePicker with 5-minute intervals (default 11:00 PM)
- Interruption tracking: Yes/No/Skip toggle buttons
- Conditional UI: Hours picker hidden when bedtime toggle enabled
- 4-hour duplicate detection window
- Custom `UIViewRepresentable` wrapper for native 5-minute DatePicker snapping

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
2. **Sleep Tab**: User selects hours + optional bedtime/interruption → duplicate check → save with feedback
3. **History Tab**: Browse all entries grouped by day (currently energy only)
4. **Summary Tab**: View weekly stats, trends, and insights (currently energy only)

## Today's Progress (Session Summary)

### ✅ What We Built Today
- **Complete sleep tracking system** with separate `SleepEntry` data model
- **Intuitive sleep logging UI** with hours picker, optional bedtime, and interruption tracking
- **Smart UX decisions**: Hours/bedtime as independent fields, conditional picker display
- **Native 5-minute DatePicker** using `UIViewRepresentable` wrapper for instant snapping
- **4-tab navigation** with proper SF Symbol icons and state management

### 🎯 Key Technical Learnings
- **SwiftData multi-model approach**: Separate models vs inheritance trade-offs
- **Custom DatePicker constraints**: `minuteInterval` property for native 5-minute snapping
- **Conditional UI patterns**: Hiding/showing pickers while preserving data display
- **Data independence**: Hours and bedtime as separate, non-calculated fields

### 🔧 Notable Problem Solving
- **Scroll direction preference**: Reversed array for intuitive "scroll down for larger values"
- **Toggle UX refinement**: Hours picker hidden, but text/display remains visible
- **Native vs custom pickers**: Abandoned complex custom solution for simple `UIViewRepresentable`
- **Bedtime calculation bug**: Fixed negative time calculation by treating bedtime/hours as independent

## Tomorrow's Plan

### 🏋️ Phase 1: Workout Logging
1. **Create `WorkoutEntry` data model** with workout type, duration, intensity
2. **Build workout logging interface** - possibly with predefined workout types
3. **Add to SwiftData schema** and navigation structure

### 📊 Phase 2: Multi-Entry History & Analytics
1. **Update HistoryView** to display sleep and workout entries alongside energy
2. **Enhance SummaryView** with sleep analytics (duration trends, bedtime patterns, interruption analysis)
3. **Add workout analytics** (frequency, intensity patterns, correlation insights)

### 🎯 Success Criteria
- All three entry types (Energy, Sleep, Workout) logging and displaying correctly
- Unified history view with clear visual distinction between entry types  
- Comprehensive analytics showing patterns across all three data types

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

### Project Structure Notes
- **Main Branch**: `main` (clean, ready for sideloading)
- **SwiftData Schema**: `EnergyEntry` and `SleepEntry` models (WorkoutEntry coming tomorrow)
- **iOS Version**: Targets iOS 17+ (for SwiftData and Swift Charts)
- **Dependencies**: None (uses built-in frameworks only)

### Sideloading Notes
- **Entitlements cleaned**: Removed iCloud and Push Notifications for free Apple ID compatibility
- **Local storage only**: MySpark uses SwiftData with local persistence (no cloud dependency)
- **Future notifications**: Plan to add local notifications (compatible with free accounts)

---

**Status**: Energy + Sleep tracking complete! Workout logging and unified analytics next. 🚀