# Data Migration Note

## Important: isMockData Field Added

### What Changed
A new boolean field `isMockData` was added to the `WorkoutEntry` model to distinguish between real and mock data.

### For Existing Data
If you had workout data in the app before this update:
- **All existing entries will automatically have `isMockData = false`** (SwiftData default)
- Your existing data is treated as real data ✅
- No manual migration needed
- Everything continues to work normally

### For New Installations
- Fresh installations have no issues
- Mock data is clearly marked with `isMockData = true`
- Real data is marked with `isMockData = false`

### Schema Evolution
SwiftData automatically handles this schema change:
- Adds the new field to existing database
- Sets default value (`false`) for all existing records
- No data loss occurs
- No user action required

### Verification
To verify your data migrated correctly:
1. Open the debug menu
2. Check "Real Data Entries" count
3. Ensure it matches your expected workout count
4. Toggle "Use Mock Data" OFF
5. Verify all your workouts are visible

---

**Date Added**: January 7, 2026  
**Impact**: Low - Automatic migration  
**Action Required**: None
