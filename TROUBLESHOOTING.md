# Troubleshooting Guide - Data Not Showing

## Issue: Data not recording or showing up

### Quick Fix Steps (Try in order):

### **STEP 1: Enable "Show All Data" Mode**
1. Open the app
2. Tap the ladybug icon (🐞) to open Debug Menu
3. Toggle **"Show All Data"** to ON (should turn blue)
4. Go back to the main app
5. Try adding a workout now
6. Check if it appears

**What this does:** Completely bypasses all filtering logic and shows every entry in the database, regardless of the `isMockData` flag.

**If this works:** The issue is with the filtering logic, not data saving. Your data IS being saved but filtered out.

---

### **STEP 2: Check Debug Menu Statistics**
With "Show All Data" still ON:
1. Open Debug Menu
2. Look at the "Statistics" section:
   - **Total Entries**: Should show the actual count in database
   - **Real Data Entries**: Count of entries with `isMockData = false`
   - **Mock Data Entries**: Count of entries with `isMockData = true`
   - **Currently Showing**: Should say "All (X)"

**What to look for:**
- If "Total Entries" is > 0, your data IS being saved ✅
- If "Real Data Entries" matches your expectation, filtering is working ✅
- If "Total Entries" is 0, data is not being saved at all ❌

---

### **STEP 3: Reset to Real Data Mode**
1. In Debug Menu, toggle **"Show All Data"** to OFF
2. Make sure **"Use Mock Data"** is OFF
3. Check "Currently Showing" - should say "Real (X)"
4. Go back and verify your workouts appear

**Expected behavior:**
- Real mode should show only entries with `isMockData = false`
- Mock mode should show only entries with `isMockData = true`

---

### **STEP 4: Clean Start (If Nothing Works)**

If data is still not showing:

1. **Delete the app from simulator/device**
2. Clean build folder in Xcode: `Product > Clean Build Folder`
3. Rebuild and reinstall
4. The database will be recreated fresh

**Why this helps:** Removes any schema migration issues from adding the `isMockData` field.

---

## Understanding the Debug Modes

### Three Operating Modes:

| Mode | Shows | Use Case |
|------|-------|----------|
| **Real Data** | Only `isMockData = false` | Normal daily use |
| **Mock Data** | Only `isMockData = true` | Testing with fake data |
| **Show All Data** 🔍 | Everything | Debugging/troubleshooting |

### Visual Indicators:

- **Real Mode**: 🐞 (gray ladybug)
- **Mock Mode**: 🐞 MOCK (orange)  
- **Show All Mode**: Data count shows "All (X)" in blue

---

## Common Issues & Solutions

### Issue: "I added data but it doesn't show"

**Check:**
1. Are you in the correct mode? (Real vs Mock)
2. Is "Show All Data" OFF? (Could be hiding filtered data)
3. Did you tap "Save" on the add workout screen?
4. Check Debug Menu > Total Entries count

**Solution:** Enable "Show All Data" to see everything

---

### Issue: "Data shows in 'Show All' but not in Real mode"

**Reason:** Your data might be accidentally marked as mock data.

**Check:**
```
Debug Menu > Statistics
- Total Entries: 5
- Real Data Entries: 0 ← Problem!
- Mock Data Entries: 5
```

**Solution:** 
1. Use "Show All Data" mode for now
2. Re-add your workouts (they'll be marked as real)
3. Use "Clear Mock Data Only" to remove the incorrectly marked entries

---

### Issue: "Switching between modes doesn't work"

**Reason:** Environment not updating properly.

**Solution:**
1. Close and reopen the app
2. Or use "Show All Data" mode
3. Check that the toggle actually changes in Debug Menu

---

## Debug Menu Features (Updated)

### New Feature: "Show All Data" Toggle
- **Purpose**: Bypass all filtering for debugging
- **When to use**: When data isn't showing and you want to see what's actually in the database
- **Visual**: Turns blue when enabled
- **Effect**: All views show every workout entry regardless of flags

### How Filtering Works:

```
When "Show All Data" = ON:
  → Show everything (no filtering)

When "Show All Data" = OFF:
  If "Use Mock Data" = ON:
    → Show only isMockData = true
  If "Use Mock Data" = OFF:
    → Show only isMockData = false (real data)
```

---

## Technical Details

### Changes Made to Fix:

1. **Added explicit `try modelContext.save()`** in AddWorkoutView
2. **Improved filtering logic** - clearer if/else conditions
3. **Added "Show All Data" debug mode** - bypass all filtering
4. **Better model container initialization** - explicit schema setup
5. **Enhanced debug statistics** - show total count + breakdown

### Files Modified:
- `ForceApp.swift` - Better ModelContainer init
- `AddWorkoutView.swift` - Explicit save call
- `DebugSettings.swift` - Added `showAllData` property
- `ContentView.swift` - Added "Show All" filtering logic
- `HistoryView.swift` - Added "Show All" filtering logic
- `ChartsView.swift` - Added "Show All" filtering logic
- `DebugMenuView.swift` - Added "Show All" toggle

---

## Testing Checklist

After making these fixes:

- [ ] Enable "Show All Data"
- [ ] Add a test workout
- [ ] Verify it appears immediately
- [ ] Check Debug Menu > Total Entries increased
- [ ] Disable "Show All Data"
- [ ] Ensure "Use Mock Data" is OFF
- [ ] Verify workout still appears
- [ ] Switch to Mock mode
- [ ] Verify workout disappears (it's real data)
- [ ] Switch back to Real mode
- [ ] Verify workout reappears

---

**If none of these steps work, please:**
1. Note which step failed
2. Share the counts from Debug Menu > Statistics
3. Let me know if "Show All Data" mode works

The "Show All Data" toggle is your emergency bypass - it will show everything in the database without any filtering.
