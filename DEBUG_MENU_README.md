# Debug Menu - Force App

## Overview

The Force app now includes a comprehensive debug menu that allows you to switch between real data and mock data for testing and development purposes.

## Features

### 1. **Data Source Toggle**
- Switch between real workout data and generated mock data
- Visual indicator in the UI when using mock data (orange "MOCK" label)

### 2. **Mock Data Generation**
- Generate 10-100 entries of realistic workout data
- Configurable count (adjustable in increments of 10)
- Generated data includes:
  - Random workout durations (15-120 minutes)
  - Realistic weight fluctuations (around 70kg ± 3kg)
  - Varied dates (covers the last N days with ~70% workout frequency)
  - Randomized motivational notes

### 3. **Data Management**
- **Generate Mock Data**: Creates new mock entries (requires "Use Mock Data" toggle to be ON)
- **Clear All Data**: Removes all workout entries from the database

## How to Access

### Method 1: Debug Button (Recommended)
- Look for the ladybug icon 🐞 in the top-left corner of the Home screen
- Tap it to open the debug menu
- When mock data is enabled, you'll see "MOCK" next to the icon

### Method 2: Shake Gesture
- Shake your device while the app is open
- The debug menu will automatically appear

## Using the Debug Menu

1. **Enable Mock Data Mode**
   - Open the debug menu
   - Toggle "Use Mock Data" to ON
   - Adjust the "Mock Data Count" slider (10-100 entries)

2. **Generate Mock Data**
   - Ensure "Use Mock Data" is enabled
   - Tap "Generate Mock Data"
   - Confirm the action (this will replace ALL existing data)
   - The app will populate with realistic test data

3. **Switch Back to Real Data**
   - Toggle "Use Mock Data" to OFF
   - Your real workout entries will be displayed again

4. **Clear All Data**
   - Tap "Clear All Data" (works in both modes)
   - Confirm the action to remove all entries

## Settings Persistence

Debug settings are saved using UserDefaults and persist across app launches:
- Mock data mode state
- Mock data count preference

## Visual Indicators

- **Debug Button**: Shows ladybug icon in the toolbar
- **Mock Mode Badge**: Orange "MOCK" label appears when mock data is active
- **Data Mode**: Displayed in the Statistics section of the debug menu

## Safety Features

- All destructive actions (Generate Mock Data, Clear All Data) require confirmation
- Clear warnings about data loss
- Settings can be reset to defaults using "Reset Debug Settings"

## Technical Details

### Files Added
- `DebugSettings.swift` - Manages debug configuration state
- `MockDataGenerator.swift` - Generates realistic workout entries
- `DebugMenuView.swift` - Debug menu UI
- `ShakeGesture.swift` - Shake gesture detection

### Mock Data Characteristics
- **Frequency**: ~70% of days have workouts (realistic adherence rate)
- **Workout Duration**: Random selection from common durations (15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 90, 120 minutes)
- **Weight Variation**: ±3kg from base weight (70kg)
- **Notes**: Randomly selected from a pool of motivational messages
- **Date Range**: Covers the last N days (configurable count)

## Best Practices

1. **Testing**: Use mock data for UI testing and screenshot generation
2. **Development**: Enable mock data when working on analytics features
3. **Production**: Keep mock data OFF for real usage
4. **Data Safety**: Always backup your real data before generating mock data

## Reset Everything

If you want to completely reset the debug menu:
1. Open the debug menu
2. Scroll to the bottom
3. Tap "Reset Debug Settings"
4. Optionally, tap "Clear All Data" to remove all entries

---

**Version**: 1.0  
**Last Updated**: January 7, 2026
