# Debug Menu Implementation Summary

## What Was Added

### New Files Created

1. **DebugSettings.swift**
   - Observable singleton class for managing debug state
   - Persists settings using UserDefaults
   - Properties: `useMockData` (Bool), `mockDataCount` (Int)

2. **MockDataGenerator.swift**
   - Static methods for generating realistic mock workout data
   - `generateMockEntries(count:)` - Creates mock WorkoutEntry objects
   - `populateMockData(in:count:)` - Clears and populates database with mock data
   - `clearAllData(from:)` - Removes all entries from database

3. **DebugMenuView.swift**
   - Full-featured SwiftUI debug menu interface
   - Toggle for mock data mode
   - Stepper for adjusting mock data count (10-100 entries)
   - Buttons for generating mock data and clearing all data
   - Statistics display showing current entry count and data mode
   - Confirmation alerts for destructive actions

4. **ShakeGesture.swift**
   - UIKit integration for shake gesture detection
   - ViewModifier for easy SwiftUI integration
   - Extension on View for `.onShake()` modifier

### Modified Files

1. **WorkoutEntry.swift** ⭐ CRITICAL CHANGE
   - Added `isMockData: Bool` property to distinguish real from mock data
   - Updated initializer to include `isMockData` parameter (defaults to `false`)

2. **ContentView.swift**
   - Added debug menu state management
   - Added debug button in HomeView toolbar (ladybug icon)
   - Added visual "MOCK" indicator when using mock data
   - Integrated shake gesture to open debug menu
   - Updated HomeView signature to include `showingDebugMenu` binding
   - Added filtering to show only real or mock data based on settings

3. **HistoryView.swift**
   - Added data filtering based on `isMockData` flag and debug settings
   
4. **ChartsView.swift**
   - Added data filtering based on `isMockData` flag and debug settings
   
5. **AddWorkoutView.swift**
   - Ensures manually added workouts are marked as real data (`isMockData = false`)

6. **MockDataGenerator.swift**
   - Added `clearMockData()` method to remove only mock entries
   - Updated `populateMockData()` to preserve real data

### Documentation

1. **DEBUG_MENU_README.md**
   - Comprehensive user guide for the debug menu
   - Feature descriptions and usage instructions
   - Technical details and best practices

2. **IMPLEMENTATION_SUMMARY.md** (this file)
   - Technical implementation overview

## Features Implemented

### ✅ Debug Menu Access
- **Toolbar Button**: Ladybug icon in top-left of Home screen
- **Shake Gesture**: Shake device to open debug menu
- **Visual Indicator**: Orange "MOCK" badge when mock data is active

### ✅ Mock Data System
- **Realistic Data**: Generates workout entries with varied characteristics
  - Random durations: 15-120 minutes
  - Weight fluctuations: 70kg ± 3kg
  - Realistic workout frequency: ~70% adherence
  - Motivational notes pool
  - Date range covering last N days

- **Configurable Count**: Adjust between 10-100 entries (steps of 10)
- **Proper Cleanup**: Clears existing data before generating new

### ✅ Data Management
- **Toggle Mock/Real Data**: Seamless switching between data sources
- **Generate Mock Data**: One-tap generation with confirmation
- **Clear All Data**: Remove all entries with confirmation
- **Settings Persistence**: Preferences saved across app launches

### ✅ Safety Features
- **Confirmation Dialogs**: All destructive actions require confirmation
- **Clear Warnings**: Explicit messaging about data loss
- **Reset Option**: "Reset Debug Settings" button
- **Disabled States**: Generate button disabled when mock mode is off

### ✅ Visual Design
- **Consistent UI**: Matches app's existing design language (Theme.swift)
- **Material Backgrounds**: .ultraThinMaterial cards
- **SF Symbols Icons**: Ladybug, refresh, trash, statistics
- **Color Coding**: Orange for mock mode, green for real data
- **Organized Sections**: Clear section headers and footers

## How It Works

### Mock Data Flow ⭐ UPDATED
1. User enables "Use Mock Data" toggle
2. User adjusts count (optional)
3. User taps "Generate Mock Data"
4. Confirmation alert appears
5. On confirmation:
   - **Only existing mock entries are deleted** (real data preserved!)
   - New mock entries are generated with `isMockData = true`
   - Entries are inserted into SwiftData model context
   - UI updates automatically via filtered @Query
6. When toggling back to real data:
   - Views automatically filter to show only `isMockData = false` entries
   - Mock data remains in database but is hidden
   - No data loss occurs

### Settings Persistence
```swift
UserDefaults.standard.set(useMockData, forKey: "useMockData")
UserDefaults.standard.set(mockDataCount, forKey: "mockDataCount")
```

### Mock Data Generation Algorithm
```swift
for daysAgo in 0..<count {
    // 70% chance of having a workout
    if random > 70 { continue }
    
    // Create entry with:
    - date: today - daysAgo
    - workoutMinutes: random from [15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 90, 120]
    - weightKg: 70.0 ± random(-3.0...3.0)
    - notes: random from motivational messages pool
    - isMockData: true  ⭐ NEW
}
```

### Data Filtering System ⭐ NEW
```swift
// All views now filter data based on mode
@Query private var allEntries: [WorkoutEntry]
@State private var debugSettings = DebugSettings.shared

private var entries: [WorkoutEntry] {
    allEntries.filter { $0.isMockData == debugSettings.useMockData }
}

// Results in:
// - Mock mode ON: shows only mock entries
// - Mock mode OFF: shows only real entries
// - Both types coexist in database
```

## Integration Points

### SwiftData
- Uses existing `WorkoutEntry` model
- Works with existing `@Query` in views
- Respects model relationships and constraints

### SwiftUI
- Native SwiftUI views with no UIKit except shake detection
- Uses `@Observable` for state management (modern observation)
- Integrated with existing navigation patterns

### Theme System
- Uses existing `Theme.swift` colors and spacing
- Consistent with app's design language
- Material backgrounds and rounded corners

## Testing Recommendations

1. **Test Mock Data Generation**
   - Generate different counts (10, 30, 50, 100)
   - Verify data appears in all views (Home, Charts, History)
   - Check date distribution and variety

2. **Test Data Switching**
   - Add real data
   - Generate mock data
   - Toggle between modes
   - Verify correct data displays

3. **Test Shake Gesture**
   - Shake device in simulator (Device > Shake)
   - Verify debug menu opens

4. **Test Persistence**
   - Enable mock mode
   - Close and reopen app
   - Verify settings are preserved

5. **Test Charts**
   - Generate mock data
   - Check all chart views render correctly
   - Verify statistics calculations are accurate

## Future Enhancements (Optional)

- [ ] Import/Export mock data presets
- [ ] Custom mock data templates
- [ ] Debug statistics and analytics
- [ ] Performance profiling tools
- [ ] Network simulation settings
- [ ] UI layout debugging overlays
- [ ] Accessibility testing tools

## Notes ⭐ UPDATED

- Mock data uses realistic patterns but is randomly generated each time
- **Real data is ALWAYS preserved** - mock data generation only replaces other mock data
- Settings persist using UserDefaults (not encrypted)
- Debug menu is accessible in all build configurations
- Minimal performance impact - filtering happens in computed properties
- Thread-safe with SwiftData's MainActor requirements
- Data separation is permanent - mock entries remain marked even after app restart

---

**Implementation Date**: January 7, 2026  
**Total Files Added**: 4  
**Total Files Modified**: 1  
**Lines of Code**: ~600
