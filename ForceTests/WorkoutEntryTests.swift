//
//  WorkoutEntryTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class WorkoutEntryTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        // Create in-memory model container for testing
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
    
    // MARK: - Initialization Tests
    
    func testWorkoutEntryDefaultInitialization() {
        // When
        let entry = WorkoutEntry()
        
        // Then
        XCTAssertNotNil(entry.date)
        XCTAssertEqual(entry.workoutMinutes, 0)
        XCTAssertEqual(entry.weightKg, 0.0)
        XCTAssertEqual(entry.notes, "")
        XCTAssertEqual(entry.isMockData, false)
    }
    
    func testWorkoutEntryCustomInitialization() {
        // Given
        let date = Date()
        let minutes = 45
        let weight = 75.5
        let notes = "Great workout!"
        
        // When
        let entry = WorkoutEntry(
            date: date,
            workoutMinutes: minutes,
            weightKg: weight,
            notes: notes,
            isMockData: true
        )
        
        // Then
        XCTAssertEqual(entry.date, date)
        XCTAssertEqual(entry.workoutMinutes, minutes)
        XCTAssertEqual(entry.weightKg, weight)
        XCTAssertEqual(entry.notes, notes)
        XCTAssertTrue(entry.isMockData)
    }
    
    // MARK: - Persistence Tests
    
    func testWorkoutEntryPersistence() throws {
        // Given
        let entry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 60,
            weightKg: 70.0,
            notes: "Test entry",
            isMockData: false
        )
        
        // When
        modelContext.insert(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.workoutMinutes, 60)
        XCTAssertEqual(entries.first?.weightKg, 70.0)
        XCTAssertEqual(entries.first?.notes, "Test entry")
        XCTAssertFalse(entries.first?.isMockData ?? true)
    }
    
    func testMultipleEntriesPersistence() throws {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let entry1 = WorkoutEntry(date: today, workoutMinutes: 30, weightKg: 70.0)
        let entry2 = WorkoutEntry(date: yesterday, workoutMinutes: 45, weightKg: 70.5)
        
        // When
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 2)
    }
    
    func testWorkoutEntryDeletion() throws {
        // Given
        let entry = WorkoutEntry(date: Date(), workoutMinutes: 30, weightKg: 70.0)
        modelContext.insert(entry)
        try modelContext.save()
        
        // When
        modelContext.delete(entry)
        try modelContext.save()
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 0)
    }
    
    // MARK: - Property Tests
    
    func testWorkoutMinutesRange() {
        // Test various workout durations
        let shortWorkout = WorkoutEntry(workoutMinutes: 5)
        let mediumWorkout = WorkoutEntry(workoutMinutes: 60)
        let longWorkout = WorkoutEntry(workoutMinutes: 180)
        
        XCTAssertEqual(shortWorkout.workoutMinutes, 5)
        XCTAssertEqual(mediumWorkout.workoutMinutes, 60)
        XCTAssertEqual(longWorkout.workoutMinutes, 180)
    }
    
    func testWeightKgPrecision() {
        // Test weight with decimal precision
        let entry = WorkoutEntry(weightKg: 75.567)
        XCTAssertEqual(entry.weightKg, 75.567, accuracy: 0.001)
    }
    
    func testNotesWithSpecialCharacters() {
        // Test notes with various characters
        let notes = "Great workout! 💪🏋️‍♂️ Felt strong today. 100% effort."
        let entry = WorkoutEntry(notes: notes)
        
        XCTAssertEqual(entry.notes, notes)
    }
    
    func testMockDataFlag() {
        let realEntry = WorkoutEntry(isMockData: false)
        let mockEntry = WorkoutEntry(isMockData: true)
        
        XCTAssertFalse(realEntry.isMockData)
        XCTAssertTrue(mockEntry.isMockData)
    }
}
