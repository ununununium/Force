# Test Setup Verification Checklist

Use this checklist to verify your test setup is working correctly.

## ✅ Pre-Setup Checklist

Before you begin:

- [ ] Xcode 15+ installed
- [ ] Force.xcodeproj opens without errors
- [ ] App builds and runs successfully (⌘R)
- [ ] All test files exist in `ForceTests` folder

## 📝 Setup Steps Checklist

### Step 1: Create Test Target
- [ ] File → New → Target...
- [ ] Selected "Unit Testing Bundle"
- [ ] Named it "ForceTests"
- [ ] Clicked "Activate" when prompted

### Step 2: Add Test Files
- [ ] Right-clicked ForceTests group in Xcode
- [ ] Selected "Add Files to Force..."
- [ ] Added all 7 test files:
  - [ ] WorkoutEntryTests.swift
  - [ ] MockDataGeneratorTests.swift
  - [ ] DebugSettingsTests.swift
  - [ ] HomeViewLogicTests.swift
  - [ ] ChartsViewLogicTests.swift
  - [ ] ContributionHeatmapTests.swift
  - [ ] AddWorkoutViewLogicTests.swift
- [ ] Verified "ForceTests" target is checked
- [ ] Files appear in Project Navigator under ForceTests

### Step 3: Configure Dependencies
- [ ] Selected ForceTests target
- [ ] Build Phases → Dependencies shows "Force"
- [ ] Build Phases → Link Binary shows "Force.app"

### Step 4: Run Initial Tests
- [ ] Selected ForceTests scheme
- [ ] Pressed ⌘U
- [ ] Tests started running

## ✅ Verification Checklist

### Basic Functionality
- [ ] Tests compile without errors
- [ ] At least 85 tests discovered
- [ ] All tests pass (green checkmarks)
- [ ] Test execution completes in < 60 seconds
- [ ] No warnings in test output

### Test Navigator (⌘6)
- [ ] Can see ForceTests bundle
- [ ] Can expand to see all 7 test files
- [ ] Each test class shows individual tests
- [ ] Diamond icons are present for running tests

### Individual Test Execution
- [ ] Can run single test by clicking diamond
- [ ] Can run test class by clicking class diamond
- [ ] Test results appear in editor
- [ ] Failed tests show error messages

### Test Results
Run each test file individually and verify:

- [ ] **WorkoutEntryTests**: 11/11 passing
- [ ] **MockDataGeneratorTests**: 11/11 passing
- [ ] **DebugSettingsTests**: 11/11 passing
- [ ] **HomeViewLogicTests**: 12/12 passing
- [ ] **ChartsViewLogicTests**: 14/14 passing
- [ ] **ContributionHeatmapTests**: 11/11 passing
- [ ] **AddWorkoutViewLogicTests**: 15/15 passing

**Total**: 85/85 tests passing ✅

### Coverage Report
- [ ] Product → Test (⌘U)
- [ ] Open Report Navigator (⌘9)
- [ ] Select latest test run
- [ ] Coverage tab shows data
- [ ] Overall coverage > 70%

## 🔍 Troubleshooting Checklist

If tests don't compile:
- [ ] Clean Build Folder (⌘⇧K)
- [ ] Rebuild (⌘B)
- [ ] Check Build Settings for Swift version
- [ ] Verify @testable import Force works

If tests don't run:
- [ ] ForceTests scheme is selected
- [ ] Target device is set (simulator)
- [ ] Scheme is set to run tests
- [ ] Test target is activated

If some tests fail:
- [ ] Check error messages
- [ ] Verify in-memory storage is working
- [ ] Check date/time calculations
- [ ] Ensure no external dependencies

## 📊 Success Criteria

Your setup is complete when:

### All Green ✅
```
✓ ForceTests (85 tests) — 0.45s
  ✓ WorkoutEntryTests (11 tests)
  ✓ MockDataGeneratorTests (11 tests)
  ✓ DebugSettingsTests (11 tests)
  ✓ HomeViewLogicTests (12 tests)
  ✓ ChartsViewLogicTests (14 tests)
  ✓ ContributionHeatmapTests (11 tests)
  ✓ AddWorkoutViewLogicTests (15 tests)
```

### Performance Metrics
- [ ] Total test time < 60 seconds
- [ ] Average test time < 0.5 seconds
- [ ] No memory leaks reported
- [ ] No threading issues

### Integration
- [ ] Tests run via ⌘U
- [ ] Tests run via Test Navigator
- [ ] Tests run via command line
- [ ] Tests can run in any order

## 🎯 Quick Verification Commands

Run these to verify everything works:

### 1. Run All Tests
```bash
xcodebuild test -project Force.xcodeproj -scheme Force -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```
Expected: ✅ All tests pass

### 2. Run Single Test Class
```bash
xcodebuild test -project Force.xcodeproj -scheme Force -only-testing:ForceTests/WorkoutEntryTests
```
Expected: ✅ 11 tests pass

### 3. Check Coverage
```bash
xcodebuild test -project Force.xcodeproj -scheme Force -enableCodeCoverage YES
```
Expected: ✅ Coverage report generated

## 🎓 Next Steps After Verification

Once all checkmarks are complete:

### Immediate
- [ ] Bookmark Test Navigator (⌘6)
- [ ] Set up keyboard shortcut for ⌘U
- [ ] Read ForceTests/README.md
- [ ] Review test code to understand patterns

### Short Term
- [ ] Run tests before each commit
- [ ] Add tests when adding features
- [ ] Fix failing tests immediately
- [ ] Monitor coverage reports

### Long Term
- [ ] Set up CI/CD for automated testing
- [ ] Add UI tests for critical flows
- [ ] Create performance benchmarks
- [ ] Document testing patterns for team

## 📝 Notes Section

Use this space to track any issues or observations:

### Issues Encountered:
```
(Write any problems you faced during setup)
```

### Solutions Applied:
```
(Write how you resolved them)
```

### Custom Configuration:
```
(Note any custom settings or changes)
```

---

## ✅ Final Confirmation

I confirm that:
- [ ] All 85+ tests pass
- [ ] Tests run in < 60 seconds
- [ ] No errors or warnings
- [ ] Can run tests via ⌘U
- [ ] Can run individual tests
- [ ] Coverage report is accessible

**Setup completed by**: _______________  
**Date**: _______________  
**Xcode version**: _______________  
**iOS target**: _______________  

---

## 🎉 Success!

If all boxes are checked, congratulations! Your test suite is ready.

You can now:
- Write new tests for new features
- Run tests before committing code
- Use tests to catch regressions
- Refactor with confidence

Happy testing! 🚀
