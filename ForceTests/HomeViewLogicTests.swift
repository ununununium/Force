//
//  HomeViewLogicTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class HomeViewLogicTests: XCTestCase {
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
    
    // MARK: - Today Entry Tests
    
    func testTodayEntryExists() throws {
        // Given - Add an entry for today
        let todayEntry = createEntry(daysAgo: 0, minutes: 45)
        modelContext.insert(todayEntry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let foundTodayEntry = allEntries.first { calendar.isDateInToday($0.date) }
        
        // Then
        XCTAssertNotNil(foundTodayEntry)
        XCTAssertEqual(foundTodayEntry?.workoutMinutes, 45)
    }
    
    func testTodayEntryDoesNotExist() throws {
        // Given - Add an entry for yesterday only
        let yesterdayEntry = createEntry(daysAgo: 1, minutes: 45)
        modelContext.insert(yesterdayEntry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let foundTodayEntry = allEntries.first { calendar.isDateInToday($0.date) }
        
        // Then
        XCTAssertNil(foundTodayEntry)
    }
    
    // MARK: - Week Entries Tests
    
    func testWeekEntriesFiltering() throws {
        // Given - Add entries for the last 10 days
        let referenceDate = Date()
        for i in 0..<10 {
            let date = calendar.date(byAdding: .day, value: -i, to: referenceDate)!
            let entry = WorkoutEntry(date: date, workoutMinutes: 30, weightKg: 70.0, isMockData: false)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Filter for last 7 days
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: referenceDate)!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let weekEntries = allEntries.filter { $0.date >= weekAgo }
        
        // Then - Should have 8 entries (today + 7 days ago)
        XCTAssertEqual(weekEntries.count, 8)
    }
    
    func testWeekEntriesEmpty() throws {
        // Given - Add entries older than a week
        for i in 8..<15 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Filter for last 7 days
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let weekEntries = allEntries.filter { $0.date >= weekAgo }
        
        // Then - Should have no entries
        XCTAssertEqual(weekEntries.count, 0)
    }
    
    // MARK: - Weekly Total Tests
    
    func testWeeklyTotalCalculation() throws {
        // Given
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 45),
            createEntry(daysAgo: 2, minutes: 60),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let weekEntries = allEntries.filter { $0.date >= weekAgo }
        let total = weekEntries.reduce(0) { $0 + $1.workoutMinutes }
        
        // Then
        XCTAssertEqual(total, 135) // 30 + 45 + 60
    }
    
    func testWeeklyTotalWithNoEntries() throws {
        // When - No entries
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let weekEntries = allEntries.filter { $0.date >= weekAgo }
        let total = weekEntries.reduce(0) { $0 + $1.workoutMinutes }
        
        // Then
        XCTAssertEqual(total, 0)
    }
    
    // MARK: - Streak Calculation Tests
    
    func testStreakCalculationConsecutiveDays() throws {
        // Given - Consecutive workout days
        for i in 0..<5 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        let streak = calculateStreak(from: entries)
        
        // Then
        XCTAssertEqual(streak, 5)
    }
    
    func testStreakCalculationWithGap() throws {
        // Given - Workout streak with a gap
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 30),
            // Gap on day 2
            createEntry(daysAgo: 3, minutes: 30),
            createEntry(daysAgo: 4, minutes: 30),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let streak = calculateStreak(from: allEntries)
        
        // Then - Should only count consecutive days from today
        XCTAssertEqual(streak, 2)
    }
    
    func testStreakCalculationNoWorkouts() throws {
        // When - No entries
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        let streak = calculateStreak(from: entries)
        
        // Then
        XCTAssertEqual(streak, 0)
    }
    
    func testStreakCalculationStartingYesterday() throws {
        // Given - No workout today, but consecutive days before
        for i in 1..<4 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        let streak = calculateStreak(from: entries)
        
        // Then - Streak should be 0 if today has no workout
        XCTAssertEqual(streak, 0)
    }
    
    // MARK: - Entry Filtering Tests
    
    func testFilteringRealDataOnly() throws {
        // Given
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let mockEntry = WorkoutEntry(workoutMinutes: 45, weightKg: 75.0, isMockData: true)
        
        modelContext.insert(realEntry)
        modelContext.insert(mockEntry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let filteredEntries = allEntries.filter { $0.isMockData == false }
        
        // Then
        XCTAssertEqual(filteredEntries.count, 1)
        XCTAssertEqual(filteredEntries.first?.workoutMinutes, 30)
    }
    
    func testFilteringMockDataOnly() throws {
        // Given
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let mockEntry = WorkoutEntry(workoutMinutes: 45, weightKg: 75.0, isMockData: true)
        
        modelContext.insert(realEntry)
        modelContext.insert(mockEntry)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        let filteredEntries = allEntries.filter { $0.isMockData == true }
        
        // Then
        XCTAssertEqual(filteredEntries.count, 1)
        XCTAssertEqual(filteredEntries.first?.workoutMinutes, 45)
    }
    
    func testShowAllDataMode() throws {
        // Given
        let realEntry = WorkoutEntry(workoutMinutes: 30, weightKg: 70.0, isMockData: false)
        let mockEntry = WorkoutEntry(workoutMinutes: 45, weightKg: 75.0, isMockData: true)
        
        modelContext.insert(realEntry)
        modelContext.insert(mockEntry)
        try modelContext.save()
        
        // When - Show all data
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        // Then
        XCTAssertEqual(allEntries.count, 2)
    }
    
    // MARK: - Helper Functions
    
    private func calculateStreak(from entries: [WorkoutEntry]) -> Int {
        var count = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            let hasWorkout = entries.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }
            if hasWorkout {
                count += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return count
    }
}
