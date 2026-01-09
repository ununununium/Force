# Force Unit Tests

Comprehensive unit tests for the Force workout tracking app.

## Overview

This test suite covers all major components of the Force app:

1. **WorkoutEntryTests** - Tests for the WorkoutEntry model
2. **MockDataGeneratorTests** - Tests for mock data generation and management
3. **DebugSettingsTests** - Tests for debug settings persistence
4. **HomeViewLogicTests** - Tests for HomeView business logic (streak calculation, filtering, weekly totals)
5. **ChartsViewLogicTests** - Tests for ChartsView statistics and data aggregation
6. **ContributionHeatmapTests** - Tests for heatmap calculations and date range logic
7. **AddWorkoutViewLogicTests** - Tests for workout saving and validation

## Setup Instructions

### 1. Add Test Target to Xcode Project

Since the project doesn't have a test target yet, you'll need to create one:

1. Open `Force.xcodeproj` in Xcode
2. Go to **File → New → Target...**
3. Select **iOS** → **Unit Testing Bundle**
4. Name it `ForceTests`
5. Click **Finish**

### 2. Add Test Files to Test Target

1. In the Project Navigator, right-click on the `ForceTests` group
2. Select **Add Files to "Force"...**
3. Navigate to the `ForceTests` folder
4. Select all `.swift` test files
5. Make sure **"ForceTests" target is checked**
6. Click **Add**

### 3. Configure Test Target Settings

1. Select the `ForceTests` target
2. Go to **Build Settings**
3. Under **Swift Compiler - General**:
   - Set **Module Name** to `ForceTests`
4. Go to **Build Phases** → **Link Binary With Libraries**
   - Add `SwiftData.framework` if not already present
5. Go to **General** → **Frameworks and Libraries**
   - Ensure the Force app is linked

### 4. Import the App Module

The test files use `@testable import Force` to access internal app components. This is already included in all test files.

## Running Tests

### Run All Tests

1. Select **Product → Test** (⌘U)
2. Or click the diamond icon next to the test class/method name

### Run Specific Tests

1. Click the diamond icon next to a specific test method
2. Or use the Test Navigator (⌘6) to run individual tests

### View Test Results

- Test results appear in the **Report Navigator** (⌘9)
- Failed tests show error messages and file locations
- Use the **Test Navigator** (⌘6) to see all tests and their status

## Test Coverage

### WorkoutEntryTests (11 tests)
- ✅ Default initialization
- ✅ Custom initialization with all parameters
- ✅ Persistence to SwiftData
- ✅ Multiple entries persistence
- ✅ Deletion
- ✅ Property validation (minutes, weight, notes)
- ✅ Mock data flag

### MockDataGeneratorTests (11 tests)
- ✅ Generate mock entries with correct count
- ✅ Mock entries are properly marked
- ✅ Generated data is valid (ranges, dates)
- ✅ Entries are sorted by date
- ✅ Clear all data functionality
- ✅ Clear mock data only (preserves real data)
- ✅ Populate mock data
- ✅ Replace old mock data

### DebugSettingsTests (11 tests)
- ✅ Default initialization values
- ✅ UserDefaults persistence for all settings
- ✅ Reset to defaults
- ✅ Toggle behavior
- ✅ Value range validation
- ✅ Multiple settings independence

### HomeViewLogicTests (12 tests)
- ✅ Today entry detection
- ✅ Week entries filtering
- ✅ Weekly total calculation
- ✅ Streak calculation (consecutive days)
- ✅ Streak calculation with gaps
- ✅ Filtering by mock/real data
- ✅ Show all data mode
- ✅ Edge cases (empty state, single entry)

### ChartsViewLogicTests (14 tests)
- ✅ Time range filtering (week, month, 3 months)
- ✅ Total minutes calculation
- ✅ Average weight calculation
- ✅ Workout count calculation
- ✅ Average duration calculation
- ✅ Weekly data aggregation
- ✅ Multiple weeks handling
- ✅ Empty state handling
- ✅ Single entry statistics
- ✅ Very long workout handling

### ContributionHeatmapTests (11 tests)
- ✅ Daily data aggregation
- ✅ Multiple days handling
- ✅ Date range generation
- ✅ Longest streak calculation
- ✅ Streak calculation with gaps
- ✅ Active days counting
- ✅ Total minutes calculation
- ✅ Color intensity mapping
- ✅ Edge cases (no data, zero minutes)

### AddWorkoutViewLogicTests (15 tests)
- ✅ Save workout with valid data
- ✅ Save workout without notes
- ✅ Multiple workouts saving
- ✅ Weight validation
- ✅ Workout minutes range validation
- ✅ Notes handling
- ✅ Past date selection
- ✅ Today date selection
- ✅ Default values
- ✅ Mock data flag for manual entries
- ✅ Multiple entries on same day
- ✅ Weight string to double conversion
- ✅ Zero/negative weight validation
- ✅ Slider value range
- ✅ Context save functionality

## Total Test Coverage

- **Total Tests: 85+**
- **Test Files: 7**
- **Coverage Areas:**
  - Data Models ✅
  - Data Persistence ✅
  - Business Logic ✅
  - Data Validation ✅
  - Date/Time Calculations ✅
  - Statistics & Aggregations ✅
  - Filtering & Sorting ✅
  - Mock Data Management ✅
  - Settings Persistence ✅

## Continuous Integration

To run tests in CI/CD:

```bash
# Run tests from command line
xcodebuild test \
  -project Force.xcodeproj \
  -scheme Force \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Best Practices

1. **Test Isolation**: Each test method is independent
2. **Setup/Teardown**: Proper cleanup in `tearDown()` methods
3. **In-Memory Storage**: Tests use in-memory ModelContainer for speed
4. **Clear Assertions**: Descriptive test names and assertions
5. **Edge Cases**: Tests cover boundary conditions and edge cases
6. **Mock Data**: Tests use realistic test data

## Troubleshooting

### Common Issues

**Issue**: `Module 'Force' not found`
- **Solution**: Make sure the Force app target is built before running tests

**Issue**: `SwiftData` errors
- **Solution**: Ensure `SwiftData.framework` is linked in test target

**Issue**: Tests fail in CI but pass locally
- **Solution**: Check simulator/device compatibility and Xcode version

### Getting Help

If you encounter issues:
1. Check that all test files are added to the `ForceTests` target
2. Verify build settings match the main app target
3. Clean build folder (⌘⇧K) and rebuild
4. Check the Issue Navigator (⌘5) for build errors

## Future Enhancements

Potential areas for additional testing:
- [ ] UI Tests for view interactions
- [ ] Performance tests for large datasets
- [ ] Integration tests with actual database
- [ ] Snapshot tests for UI components
- [ ] Accessibility tests

## Contributing

When adding new features to the app:
1. Write tests first (TDD approach)
2. Ensure all existing tests pass
3. Maintain test coverage above 80%
4. Add edge case tests
5. Update this README with new test information
