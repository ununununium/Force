# Force App - Testing Setup Guide

Quick guide to add unit tests to your Force workout tracking app.

## Quick Start (5 Minutes)

### Step 1: Create Test Target in Xcode

1. Open `Force.xcodeproj` in Xcode
2. **File** → **New** → **Target...**
3. Select **Unit Testing Bundle**
4. Configure:
   - **Product Name**: `ForceTests`
   - **Team**: Your development team
   - **Organization Identifier**: Match your app's identifier
5. Click **Finish**
6. When prompted "Activate 'ForceTests' scheme?", click **Activate**

### Step 2: Add Test Files

The test files are already created in the `ForceTests` folder. Now add them to your project:

1. In Xcode's Project Navigator, select the `ForceTests` folder (the yellow one, not the file system folder)
2. Right-click → **Add Files to "Force"...**
3. Navigate to and select the `ForceTests` folder (file system folder)
4. Check these options:
   - ✅ **Copy items if needed** (uncheck - files are already in place)
   - ✅ **Create groups** (not folder references)
   - ✅ **Add to targets**: Check **ForceTests** only
5. Click **Add**

### Step 3: Configure Target Settings

1. Select the `Force` project in Project Navigator
2. Select the `ForceTests` target
3. Go to **Build Phases**
4. Expand **"Dependencies"**
   - Click `+` and add the `Force` app target
5. Expand **"Link Binary With Libraries"**
   - Verify `XCTest.framework` is present
   - Click `+` and add `Force.app` if not present

### Step 4: Run Tests

1. Select the `ForceTests` scheme from the scheme selector
2. Press **⌘U** (or **Product** → **Test**)
3. Watch the tests run! 🎉

You should see **85+ tests** pass!

## Detailed Configuration

### Build Settings

If tests fail to compile, verify these settings for the `ForceTests` target:

#### General Tab
- **Deployment Target**: Match your app (iOS 17.0+)
- **Host Application**: Force

#### Build Settings Tab
- **Swift Language Version**: Swift 5
- **Enable Testing Search Paths**: Yes
- **Always Embed Swift Standard Libraries**: Yes

### Scheme Configuration

To run tests automatically on build:

1. **Product** → **Scheme** → **Edit Scheme...**
2. Select **Test** from sidebar
3. Click `+` to add test target if needed
4. Check **Test** checkbox for `ForceTests`

## Running Tests

### From Xcode

**Run All Tests:**
- Press **⌘U**
- Or: **Product** → **Test**

**Run Specific Test Class:**
- Open test file
- Click diamond (◊) icon next to class name
- Or: Right-click class name → **Run "ClassName"**

**Run Single Test:**
- Click diamond icon next to test method
- Or: Place cursor in test method → **⌘U**

### From Test Navigator

1. Open Test Navigator (**⌘6**)
2. See all tests organized by target/class/method
3. Click any diamond icon to run tests
4. Hover to see "Run" arrow buttons

### From Command Line

```bash
# Run all tests
xcodebuild test \
  -project Force.xcodeproj \
  -scheme Force \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test class
xcodebuild test \
  -project Force.xcodeproj \
  -scheme Force \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:ForceTests/WorkoutEntryTests
```

## Test Files Overview

```
ForceTests/
├── README.md                          # Comprehensive testing documentation
├── WorkoutEntryTests.swift            # Model tests (11 tests)
├── MockDataGeneratorTests.swift       # Mock data tests (11 tests)
├── DebugSettingsTests.swift           # Settings tests (11 tests)
├── HomeViewLogicTests.swift           # Home view logic tests (12 tests)
├── ChartsViewLogicTests.swift         # Charts logic tests (14 tests)
├── ContributionHeatmapTests.swift     # Heatmap tests (11 tests)
└── AddWorkoutViewLogicTests.swift     # Add workout tests (15 tests)
```

## What's Being Tested

### ✅ Data Layer
- WorkoutEntry model initialization and persistence
- SwiftData operations (insert, fetch, delete)
- Data validation and constraints

### ✅ Business Logic
- Streak calculation algorithms
- Weekly/monthly data aggregation
- Statistics calculations (averages, totals)
- Date range filtering

### ✅ Mock Data Management
- Mock data generation
- Separation of mock vs real data
- Data clearing operations

### ✅ Settings Management
- UserDefaults persistence
- Debug mode toggles
- Settings synchronization

### ✅ View Logic
- Entry filtering (mock/real/all)
- Today's workout detection
- Time range calculations
- Contribution heatmap logic

## Viewing Test Results

### Success ✅
- Green diamonds (◆) next to passing tests
- Summary: "Test Succeeded" with count and duration

### Failure ❌
- Red X next to failing test
- Click to see failure message and assertion
- File location shows exact line of failure

### Coverage Report

View test coverage:
1. **Product** → **Test** (⌘U)
2. Open **Report Navigator** (⌘9)
3. Select latest test run
4. Click **Coverage** tab
5. See line-by-line code coverage

## Troubleshooting

### "Module 'Force' not found"

**Cause**: Test target can't find the app module

**Solution**:
1. Select `ForceTests` target
2. **Build Phases** → **Dependencies**
3. Add `Force` app target
4. **Build Phases** → **Link Binary With Libraries**
5. Add `Force.app`

### Tests Build But Don't Run

**Cause**: Test target not activated

**Solution**:
1. **Product** → **Scheme** → **Manage Schemes...**
2. Ensure `ForceTests` scheme exists and is shared
3. Or: Select `Force` scheme → **Edit Scheme** → **Test**
4. Verify `ForceTests` is checked

### SwiftData Errors in Tests

**Cause**: In-memory model container issues

**Solution**:
- Tests already use in-memory containers
- Check that `isStoredInMemoryOnly: true` is set
- Ensure proper setup/teardown in each test

### Tests Pass Locally But Fail in CI

**Possible Causes**:
- Different Xcode version
- Different iOS simulator version
- Timing issues with async operations

**Solutions**:
- Match CI environment to local
- Add explicit waits if needed
- Check simulator logs

## Best Practices

### When Writing New Tests

1. **Descriptive Names**: `testStreakCalculationWithConsecutiveDays()`
2. **Arrange-Act-Assert**: Structure tests clearly
3. **One Assertion Per Test**: Focus on single behavior
4. **Isolated Tests**: Don't depend on other tests
5. **Clean Up**: Use `tearDown()` to reset state

### When Adding Features

1. Write tests first (TDD)
2. Run tests before committing
3. Maintain > 80% coverage
4. Update test documentation

### Test Organization

```swift
// Good structure
func testFeatureUnderSpecificCondition() {
    // Given - Setup test data
    let data = createTestData()
    
    // When - Perform action
    let result = performAction(data)
    
    // Then - Verify result
    XCTAssertEqual(result, expectedValue)
}
```

## Performance Testing

Monitor test execution time:
1. Test shouldn't take > 0.5 seconds
2. Use `measure { }` for performance tests
3. Profile slow tests with Instruments

## Continuous Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test \
            -project Force.xcodeproj \
            -scheme Force \
            -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Getting Help

### Resources
- [Apple XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [SwiftData Testing Guide](https://developer.apple.com/documentation/swiftdata)
- ForceTests/README.md - Detailed test documentation

### Common Commands

```bash
# Clean build folder
xcodebuild clean -project Force.xcodeproj -scheme Force

# Build without testing
xcodebuild build -project Force.xcodeproj -scheme Force

# List available simulators
xcrun simctl list devices available

# View test logs
tail -f ~/Library/Logs/DiagnosticReports/*.crash
```

## Next Steps

1. ✅ Add test target
2. ✅ Run all tests
3. ✅ Verify 85+ tests pass
4. 📊 Check coverage report
5. 🎯 Aim for > 80% coverage
6. 🔄 Run tests before each commit
7. 🚀 Set up CI/CD pipeline

## Success Criteria

You'll know setup is complete when:
- ✅ All 85+ tests pass
- ✅ Tests run in < 30 seconds
- ✅ No warnings or errors in test output
- ✅ Coverage report shows > 70% coverage
- ✅ Tests can run via ⌘U and Test Navigator

Happy testing! 🎉
