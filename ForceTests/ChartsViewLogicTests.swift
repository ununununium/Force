//
//  ChartsViewLogicTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class ChartsViewLogicTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var calendar: Calendar!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        calendar = Calendar.current
        
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
    
    // MARK: - Helper Methods
    
    func createEntry(daysAgo: Int, minutes: Int = 30, weight: Double = 70.0) -> WorkoutEntry {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return WorkoutEntry(date: date, workoutMinutes: minutes, weightKg: weight, isMockData: false)
    }
    
    // MARK: - Time Range Filtering Tests
    
    func testWeekTimeRangeFiltering() throws {
        // Given - Entries across multiple weeks
        let referenceDate = Date()
        for i in 0..<14 {
            let date = calendar.date(byAdding: .day, value: -i, to: referenceDate)!
            let entry = WorkoutEntry(date: date, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Filter for week (7 days)
        let cutoffDate = calendar.date(byAdding: .day, value: -7, to: referenceDate)!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let filteredEntries = allEntries.filter { $0.date >= cutoffDate }
        
        // Then - Should have 8 entries (today + 7 days back)
        XCTAssertEqual(filteredEntries.count, 8)
    }
    
    func testMonthTimeRangeFiltering() throws {
        // Given - Entries across multiple months
        let referenceDate = Date()
        for i in 0..<45 {
            let date = calendar.date(byAdding: .day, value: -i, to: referenceDate)!
            let entry = WorkoutEntry(date: date, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Filter for month (30 days)
        let cutoffDate = calendar.date(byAdding: .day, value: -30, to: referenceDate)!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let filteredEntries = allEntries.filter { $0.date >= cutoffDate }
        
        // Then - Should have 31 entries (today + 30 days back)
        XCTAssertEqual(filteredEntries.count, 31)
    }
    
    func testThreeMonthsTimeRangeFiltering() throws {
        // Given - Entries across multiple months
        let referenceDate = Date()
        for i in 0..<100 {
            let date = calendar.date(byAdding: .day, value: -i, to: referenceDate)!
            let entry = WorkoutEntry(date: date, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Filter for 3 months (90 days)
        let cutoffDate = calendar.date(byAdding: .day, value: -90, to: referenceDate)!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let filteredEntries = allEntries.filter { $0.date >= cutoffDate }
        
        // Then - Should have 91 entries (today + 90 days back)
        XCTAssertEqual(filteredEntries.count, 91)
    }
    
    // MARK: - Statistics Calculation Tests
    
    func testTotalMinutesCalculation() throws {
        // Given
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 45),
            createEntry(daysAgo: 2, minutes: 60),
            createEntry(daysAgo: 3, minutes: 90),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let totalMinutes = allEntries.reduce(0) { $0 + $1.workoutMinutes }
        
        // Then
        XCTAssertEqual(totalMinutes, 225) // 30 + 45 + 60 + 90
    }
    
    func testAverageWeightCalculation() throws {
        // Given
        let entries = [
            createEntry(daysAgo: 0, minutes: 30, weight: 70.0),
            createEntry(daysAgo: 1, minutes: 30, weight: 72.0),
            createEntry(daysAgo: 2, minutes: 30, weight: 68.0),
            createEntry(daysAgo: 3, minutes: 30, weight: 74.0),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let averageWeight = allEntries.reduce(0.0) { $0 + $1.weightKg } / Double(allEntries.count)
        
        // Then
        XCTAssertEqual(averageWeight, 71.0, accuracy: 0.01) // (70 + 72 + 68 + 74) / 4
    }
    
    func testWorkoutCountCalculation() throws {
        // Given
        for i in 0..<5 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let workoutCount = try modelContext.fetch(descriptor).count
        
        // Then
        XCTAssertEqual(workoutCount, 5)
    }
    
    func testAverageDurationCalculation() throws {
        // Given
        let entries = [
            createEntry(daysAgo: 0, minutes: 20),
            createEntry(daysAgo: 1, minutes: 40),
            createEntry(daysAgo: 2, minutes: 60),
            createEntry(daysAgo: 3, minutes: 80),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let totalMinutes = allEntries.reduce(0) { $0 + $1.workoutMinutes }
        let averageDuration = totalMinutes / allEntries.count
        
        // Then
        XCTAssertEqual(averageDuration, 50) // (20 + 40 + 60 + 80) / 4
    }
    
    // MARK: - Weekly Data Aggregation Tests
    
    func testWeeklyDataAggregation() throws {
        // Given - Multiple entries in the same week
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 45),
            createEntry(daysAgo: 2, minutes: 60),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Group by week
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        var weeklyDict: [Date: Int] = [:]
        for entry in allEntries {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
            weeklyDict[weekStart, default: 0] += entry.workoutMinutes
        }
        
        // Then - All entries should be in the same week
        XCTAssertEqual(weeklyDict.count, 1)
        XCTAssertEqual(weeklyDict.values.first, 135) // 30 + 45 + 60
    }
    
    func testWeeklyDataMultipleWeeks() throws {
        // Given - Entries across multiple weeks
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 7, minutes: 45),
            createEntry(daysAgo: 14, minutes: 60),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Group by week
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        var weeklyDict: [Date: Int] = [:]
        for entry in allEntries {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
            weeklyDict[weekStart, default: 0] += entry.workoutMinutes
        }
        
        // Then - Should have 3 different weeks
        XCTAssertEqual(weeklyDict.count, 3)
    }
    
    // MARK: - Empty State Tests
    
    func testEmptyStateWithNoData() throws {
        // When - No entries
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        // Then
        XCTAssertTrue(entries.isEmpty)
    }
    
    func testStatisticsWithNoData() throws {
        // When - No entries
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        let totalMinutes = entries.reduce(0) { $0 + $1.workoutMinutes }
        let workoutCount = entries.count
        let averageWeight = entries.isEmpty ? 0.0 : entries.reduce(0.0) { $0 + $1.weightKg } / Double(entries.count)
        
        // Then
        XCTAssertEqual(totalMinutes, 0)
        XCTAssertEqual(workoutCount, 0)
        XCTAssertEqual(averageWeight, 0.0)
    }
    
    // MARK: - Edge Cases
    
    func testSingleEntryStatistics() throws {
        // Given - Only one entry
        let entry = createEntry(daysAgo: 0, minutes: 45, weight: 70.5)
        modelContext.insert(entry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        let totalMinutes = entries.reduce(0) { $0 + $1.workoutMinutes }
        let averageWeight = entries.reduce(0.0) { $0 + $1.weightKg } / Double(entries.count)
        let averageDuration = totalMinutes / entries.count
        
        // Then
        XCTAssertEqual(totalMinutes, 45)
        XCTAssertEqual(averageWeight, 70.5)
        XCTAssertEqual(averageDuration, 45)
    }
    
    func testVeryLongWorkout() throws {
        // Given - A very long workout (180 minutes = 3 hours)
        let entry = createEntry(daysAgo: 0, minutes: 180)
        modelContext.insert(entry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        let totalMinutes = entries.reduce(0) { $0 + $1.workoutMinutes }
        
        // Then
        XCTAssertEqual(totalMinutes, 180)
    }
}
