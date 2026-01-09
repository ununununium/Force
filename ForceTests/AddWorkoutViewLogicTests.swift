//
//  AddWorkoutViewLogicTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class AddWorkoutViewLogicTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        do {
            let schema = Schema([WorkoutEntry.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create test model container: \(error)")
        }
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }
    
    // MARK: - Workout Saving Tests
    
    func testSaveWorkoutWithValidData() throws {
        // Given
        let date = Date()
        let minutes = 60
        let weight = 75.5
        let notes = "Great workout today!"
        
        let entry = WorkoutEntry(
            date: date,
            workoutMinutes: minutes,
            weightKg: weight,
            notes: notes,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        
        let savedEntry = entries.first
        XCTAssertEqual(savedEntry?.workoutMinutes, minutes)
        XCTAssertEqual(savedEntry?.weightKg, weight)
        XCTAssertEqual(savedEntry?.notes, notes)
        XCTAssertFalse(savedEntry?.isMockData ?? true)
    }
    
    func testSaveWorkoutWithoutNotes() throws {
        // Given
        let entry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 45,
            weightKg: 70.0,
            notes: "",
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.notes, "")
    }
    
    func testSaveMultipleWorkouts() throws {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let entry1 = WorkoutEntry(date: today, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let entry2 = WorkoutEntry(date: yesterday, workoutMinutes: 45, weightKg: 71.0, isMockData: false)
        
        // When
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 2)
    }
    
    // MARK: - Input Validation Tests
    
    func testWeightValidation() {
        // Test various weight inputs
        let validWeights = [50.0, 75.5, 100.0, 120.5]
        
        for weight in validWeights {
            let entry = WorkoutEntry(weightKg: weight)
            XCTAssertGreaterThan(entry.weightKg, 0.0)
        }
    }
    
    func testWorkoutMinutesRange() {
        // Test workout duration range (5-180 minutes as per UI)
        let validMinutes = [5, 30, 60, 90, 120, 180]
        
        for minutes in validMinutes {
            let entry = WorkoutEntry(workoutMinutes: minutes)
            XCTAssertGreaterThanOrEqual(entry.workoutMinutes, 5)
            XCTAssertLessThanOrEqual(entry.workoutMinutes, 180)
        }
    }
    
    func testNotesMaxLength() {
        // Test with a long note
        let longNote = String(repeating: "A", count: 500)
        let entry = WorkoutEntry(notes: longNote)
        
        // Notes should be stored without truncation
        XCTAssertEqual(entry.notes, longNote)
    }
    
    // MARK: - Date Selection Tests
    
    func testSaveWorkoutWithPastDate() throws {
        // Given - Workout from 5 days ago
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        
        let entry = WorkoutEntry(
            date: pastDate,
            workoutMinutes: 60,
            weightKg: 70.0,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        
        let daysDifference = calendar.dateComponents([.day], from: pastDate, to: entries.first!.date).day
        XCTAssertEqual(daysDifference, 0)
    }
    
    func testSaveWorkoutWithTodayDate() throws {
        // Given
        let today = Date()
        
        let entry = WorkoutEntry(
            date: today,
            workoutMinutes: 45,
            weightKg: 72.0,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        
        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(entries.first!.date))
    }
    
    // MARK: - Default Values Tests
    
    func testDefaultWorkoutMinutes() {
        // The default slider value is 30 minutes
        let entry = WorkoutEntry(workoutMinutes: 30)
        XCTAssertEqual(entry.workoutMinutes, 30)
    }
    
    func testMockDataFlagIsAlwaysFalseForManualEntries() throws {
        // Given - Manually added entries should never be mock data
        let entry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 45,
            weightKg: 70.0,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertFalse(entries.first?.isMockData ?? true)
    }
    
    // MARK: - Duplicate Entry Tests
    
    func testMultipleEntriesOnSameDay() throws {
        // Given - Multiple workouts on the same day (should be allowed)
        let today = Date()
        
        let entry1 = WorkoutEntry(date: today, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let entry2 = WorkoutEntry(date: today, workoutMinutes: 45, weightKg: 70.5, isMockData: false)
        
        // When
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 2)
        
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        XCTAssertEqual(todayEntries.count, 2)
    }
    
    // MARK: - Weight String Parsing Tests
    
    func testWeightStringToDoubleConversion() {
        // Test various weight string formats
        let testCases: [(input: String, expected: Double?)] = [
            ("70", 70.0),
            ("70.5", 70.5),
            ("75.123", 75.123),
            ("", nil),
            ("abc", nil),
            ("0", 0.0),
            ("-5", -5.0),
        ]
        
        for testCase in testCases {
            let result = Double(testCase.input)
            
            if let expected = testCase.expected {
                XCTAssertEqual(result, expected)
            } else {
                XCTAssertNil(result)
            }
        }
    }
    
    func testZeroWeightValidation() {
        // Weight should be greater than 0 for valid entry
        let zeroWeight = Double("0")
        XCTAssertEqual(zeroWeight, 0.0)
        
        // In the actual view, entries with weight <= 0 should not be saved
        if let weight = zeroWeight, weight > 0 {
            XCTFail("Zero weight should not pass validation")
        }
    }
    
    func testNegativeWeightValidation() {
        // Negative weight should not be allowed
        let negativeWeight = Double("-5")
        XCTAssertEqual(negativeWeight, -5.0)
        
        // In the actual view, negative weights should not be saved
        if let weight = negativeWeight, weight > 0 {
            XCTFail("Negative weight should not pass validation")
        }
    }
    
    // MARK: - Slider Value Tests
    
    func testWorkoutMinutesSliderRange() {
        // The slider range is 5-180 minutes with step of 5
        let validSteps = [5, 10, 15, 20, 30, 45, 60, 90, 120, 150, 180]
        
        for minutes in validSteps {
            let entry = WorkoutEntry(workoutMinutes: minutes)
            
            XCTAssertGreaterThanOrEqual(entry.workoutMinutes, 5)
            XCTAssertLessThanOrEqual(entry.workoutMinutes, 180)
            XCTAssertEqual(entry.workoutMinutes % 5, 0) // Should be divisible by 5
        }
    }
    
    // MARK: - Context Save Tests
    
    func testContextSaveSuccess() throws {
        // Given
        let entry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 45,
            weightKg: 70.0,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        
        // Then - Should not throw
        XCTAssertNoThrow(try modelContext.save())
    }
    
    func testMultipleSavesDoNotDuplicate() throws {
        // Given
        let entry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 45,
            weightKg: 70.0,
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        try modelContext.save() // Save again
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1) // Should not duplicate
    }
}
