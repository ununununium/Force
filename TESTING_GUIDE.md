# Testing Guide - Debug Menu Fix

## Issue Fixed
**Problem**: When in real data mode, logging new workouts didn't show up in the app.

**Root Cause**: Views weren't properly observing changes to the `DebugSettings` shared instance. The `@State` wrapper was capturing the instance but not tracking its changes for view updates.

**Solution**: Injected `DebugSettings` into the SwiftUI environment properly so all views observe changes reactively.

## How to Test

### Test 1: Real Data Mode (Main Use Case)
1. **Open the app** - Default should be real data mode
2. **Check debug button** - Should show ladybug icon WITHOUT "MOCK" label
3. **Add a workout**:
   - Tap the + button
   - Fill in workout details (e.g., 30 minutes, 70kg)
   - Add a note like "Test workout"
   - Save
4. **Verify it appears**:
   - ✅ Should show on Home screen immediately
   - ✅ Should appear in History tab
   - ✅ Should show in Charts tab
5. **Open debug menu** - Check that "Real Data Entries" count increased

### Test 2: Mock Data Mode
1. **Open debug menu** (tap ladybug icon or shake device)
2. **Toggle "Use Mock Data" to ON**
3. **Tap "Generate Mock Data"** and confirm
4. **Verify**:
   - ✅ Mock data appears in all views
   - ✅ Debug button shows "MOCK" label in orange
   - ✅ Your real workout from Test 1 is NOT visible
5. **Check debug menu statistics**:
   - Real Data Entries: 1 (or however many you added)
   - Mock Data Entries: ~21 (varies due to 70% generation rate)
   - Currently Showing: Mock (21)

### Test 3: Switching Between Modes
1. **Start in Mock mode** (with data from Test 2)
2. **Toggle "Use Mock Data" to OFF**
3. **Verify**:
   - ✅ Real data appears immediately
   - ✅ Mock data disappears
   - ✅ "MOCK" label disappears from debug button
4. **Toggle back to ON**
5. **Verify**:
   - ✅ Mock data reappears
   - ✅ "MOCK" label returns

### Test 4: Adding Data in Each Mode
1. **In Real mode**:
   - Add a workout (e.g., "Real workout 1")
   - ✅ Should appear immediately
2. **Switch to Mock mode**:
   - Add a workout (e.g., "Mock workout 1")
   - ✅ Should appear immediately
   - ✅ Should be marked as mock data
3. **Switch back to Real mode**:
   - ✅ "Real workout 1" is visible
   - ✅ "Mock workout 1" is NOT visible
4. **Check debug menu**:
   - Real Data Entries: should show count including "Real workout 1"
   - Mock Data Entries: should show count including "Mock workout 1"

### Test 5: Data Persistence
1. **Add real data** (e.g., "Persistence test")
2. **Generate mock data**
3. **Close and reopen the app**
4. **Verify**:
   - ✅ Mock mode setting is remembered
   - ✅ Real data still exists (check in debug menu)
5. **Toggle to Real mode**
6. **Verify**:
   - ✅ "Persistence test" workout is still there

### Test 6: Clear Operations
1. **Generate mock data**
2. **Add some real data**
3. **Test "Clear Mock Data Only"**:
   - ✅ Mock entries removed
   - ✅ Real data preserved
4. **Generate mock data again**
5. **Test "Clear All Data"**:
   - ✅ Everything removed
   - ✅ Both counts show 0

## Expected Behavior Summary

| Action | Real Mode | Mock Mode |
|--------|-----------|-----------|
| Add workout | Saved as real data, visible in real mode | Saved as mock data, visible in mock mode |
| Generate mock data | Hidden, but preserved | Replaces old mock data |
| Switch mode | Shows real data only | Shows mock data only |
| Debug button | 🐞 (gray) | 🐞 MOCK (orange) |

## Technical Changes Made

### Files Modified:
1. **ForceApp.swift** - Inject `DebugSettings` into environment
2. **ContentView.swift** - Use `@Environment(DebugSettings.self)`
3. **HistoryView.swift** - Use `@Environment(DebugSettings.self)`
4. **ChartsView.swift** - Use `@Environment(DebugSettings.self)`
5. **DebugMenuView.swift** - Use `@Bindable` for mutations

### Key Fix:
Changed from:
```swift
@State private var debugSettings = DebugSettings.shared
```

To:
```swift
// In ForceApp
@State private var debugSettings = DebugSettings.shared
// Inject: .environment(debugSettings)

// In views (read-only)
@Environment(DebugSettings.self) private var debugSettings

// In DebugMenuView (needs mutation)
@Bindable private var debugSettings = DebugSettings.shared
```

This ensures SwiftUI properly observes changes to the `@Observable` object and updates views reactively.

---

If any test fails, please let me know which one and I'll investigate further!
