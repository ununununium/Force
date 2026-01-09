//
//  MockDataGeneratorTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class MockDataGeneratorTests: XCTestCase {
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
    
    // MARK: - Generate Mock Entries Tests
    
    func testGenerateMockEntriesCount() {
        // When
        let entries = MockDataGenerator.generateMockEntries(count: 30)
        
        // Then - Should generate some entries (not all days due to randomness)
        XCTAssertGreaterThan(entries.count, 0)
        XCTAssertLessThanOrEqual(entries.count, 30)
    }
    
    func testGenerateMockEntriesAreMarkedAsMock() {
        // When
        let entries = MockDataGenerator.generateMockEntries(count: 10)
        
        // Then - All entries should be marked as mock data
        for entry in entries {
            XCTAssertTrue(entry.isMockData)
        }
    }
    
    func testGenerateMockEntriesHaveValidData() {
        // When
        let entries = MockDataGenerator.generateMockEntries(count: 20)
        
        // Then
        for entry in entries {
            // Workout minutes should be within range
            XCTAssertGreaterThanOrEqual(entry.workoutMinutes, 15)
            XCTAssertLessThanOrEqual(entry.workoutMinutes, 120)
            
            // Weight should be reasonable
            XCTAssertGreaterThan(entry.weightKg, 60.0)
            XCTAssertLessThan(entry.weightKg, 80.0)
            
            // Date should be in the past
            XCTAssertLessThanOrEqual(entry.date, Date())
        }
    }
    
    func testGenerateMockEntriesAreSorted() {
        // When
        let entries = MockDataGenerator.generateMockEntries(count: 20)
        
        // Then - Entries should be sorted by date (oldest first)
        for i in 0..<entries.count - 1 {
            XCTAssertLessThanOrEqual(entries[i].date, entries[i + 1].date)
        }
    }
    
    func testGenerateMockEntriesDateRange() {
        // Given
        let count = 30
        let calendar = Calendar.current
        
        // When
        let entries = MockDataGenerator.generateMockEntries(count: count)
        
        // Then - All entries should be within the last 'count' days
        let oldestAllowedDate = calendar.date(byAdding: .day, value: -count, to: Date())!
        
        for entry in entries {
            XCTAssertGreaterThanOrEqual(entry.date, oldestAllowedDate)
            XCTAssertLessThanOrEqual(entry.date, Date())
        }
    }
    
    // MARK: - Clear All Data Tests
    
    func testClearAllData() throws {
        // Given - Insert some entries
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let mockEntry = WorkoutEntry(workoutMinutes: 45, weightKg: 75.0, isMockData: true)
        
        modelContext.insert(realEntry)
        modelContext.insert(mockEntry)
        try modelContext.save()
        
        // When
        MockDataGenerator.clearAllData(from: modelContext)
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 0)
    }
    
    // MARK: - Clear Mock Data Tests
    
    func testClearMockDataOnly() throws {
        // Given - Insert real and mock entries
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let mockEntry1 = WorkoutEntry(workoutMinutes: 45, weightKg: 75.0, isMockData: true)
        let mockEntry2 = WorkoutEntry(workoutMinutes: 60, weightKg: 72.0, isMockData: true)
        
        modelContext.insert(realEntry)
        modelContext.insert(mockEntry1)
        modelContext.insert(mockEntry2)
        try modelContext.save()
        
        // When
        MockDataGenerator.clearMockData(from: modelContext)
        
        // Then - Only real data should remain
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertFalse(entries.first?.isMockData ?? true)
        XCTAssertEqual(entries.first?.workoutMinutes, 30)
    }
    
    func testClearMockDataWhenNoMockData() throws {
        // Given - Only real entries
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        modelContext.insert(realEntry)
        try modelContext.save()
        
        // When
        MockDataGenerator.clearMockData(from: modelContext)
        
        // Then - Real data should still be there
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertFalse(entries.first?.isMockData ?? true)
    }
    
    // MARK: - Populate Mock Data Tests
    
    func testPopulateMockData() throws {
        // When
        MockDataGenerator.populateMockData(in: modelContext, count: 30)
        
        // Then
        let descriptor = FetchDescriptor<WorkoutEntry>(
            predicate: #Predicate { $0.isMockData == true }
        )
        let mockEntries = try modelContext.fetch(descriptor)
        
        XCTAssertGreaterThan(mockEntries.count, 0)
        XCTAssertLessThanOrEqual(mockEntries.count, 30)
    }
    
    func testPopulateMockDataPreservesRealData() throws {
        // Given - Insert real data first
        let realEntry = WorkoutEntry(
            date: Date(),
            workoutMinutes: 30,
            weightKg: 70.0,
            notes: "Real workout",
            isMockData: false
        )
        modelContext.insert(realEntry)
        try modelContext.save()
        
        // When
        MockDataGenerator.populateMockData(in: modelContext, count: 20)
        
        // Then - Real data should still exist
        let realDescriptor = FetchDescriptor<WorkoutEntry>(
            predicate: #Predicate { $0.isMockData == false }
        )
        let realEntries = try modelContext.fetch(realDescriptor)
        
        XCTAssertEqual(realEntries.count, 1)
        XCTAssertEqual(realEntries.first?.notes, "Real workout")
    }
    
    func testPopulateMockDataReplacesOldMockData() throws {
        // Given - Insert old mock data
        MockDataGenerator.populateMockData(in: modelContext, count: 10)
        
        let descriptor = FetchDescriptor<WorkoutEntry>(
            predicate: #Predicate { $0.isMockData == true }
        )
        let firstCount = try modelContext.fetch(descriptor).count
        
        // When - Populate new mock data
        MockDataGenerator.populateMockData(in: modelContext, count: 20)
        
        // Then - Should have new mock data (not accumulated)
        let mockEntries = try modelContext.fetch(descriptor)
        
        // The count might be different due to randomness, but should be fresh data
        XCTAssertGreaterThan(mockEntries.count, 0)
        XCTAssertLessThanOrEqual(mockEntries.count, 20)
    }
}
