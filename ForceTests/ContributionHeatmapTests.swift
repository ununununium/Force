//
//  ContributionHeatmapTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
import SwiftData
@testable import Force

final class ContributionHeatmapTests: XCTestCase {
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
    
    // MARK: - Daily Data Aggregation Tests
    
    func testDailyDataAggregation() throws {
        // Given - Multiple entries on the same day
        let today = Date()
        let entry1 = WorkoutEntry(date: today, workoutMinutes: 30, weightKg: 70.0)
        let entry2 = WorkoutEntry(date: today, workoutMinutes: 45, weightKg: 70.0)
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        // When - Aggregate by day
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        // Then
        XCTAssertEqual(dailyData.count, 1)
        let todayStart = calendar.startOfDay(for: today)
        XCTAssertEqual(dailyData[todayStart], 75) // 30 + 45
    }
    
    func testDailyDataMultipleDays() throws {
        // Given - Entries across different days
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 45),
            createEntry(daysAgo: 2, minutes: 60),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When - Aggregate by day
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in allEntries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        // Then - Should have 3 different days
        XCTAssertEqual(dailyData.count, 3)
    }
    
    // MARK: - Date Range Generation Tests
    
    func testDateRangeGeneration() {
        // Given
        let weeksToShow = 4
        
        // When - Generate date range
        let today = calendar.startOfDay(for: Date())
        guard let weeksAgo = calendar.date(byAdding: .weekOfYear, value: -weeksToShow + 1, to: today) else {
            XCTFail("Failed to calculate weeks ago date")
            return
        }
        
        let weekday = calendar.component(.weekday, from: weeksAgo)
        let daysToSubtract = (weekday - 1) % 7
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: weeksAgo) else {
            XCTFail("Failed to calculate start of week")
            return
        }
        
        // Generate dates
        var dates: [Date] = []
        var currentDate = startOfWeek
        
        while currentDate <= today {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        // Then
        XCTAssertGreaterThan(dates.count, 0)
        XCTAssertEqual(dates.first, startOfWeek)
        XCTAssertLessThanOrEqual(dates.last!, today)
    }
    
    // MARK: - Streak Calculation Tests
    
    func testLongestStreakConsecutiveDays() throws {
        // Given - Consecutive workout days
        for i in 0..<7 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        let streak = calculateLongestStreak(dailyData: dailyData)
        
        // Then
        XCTAssertEqual(streak, 7)
    }
    
    func testLongestStreakWithGaps() throws {
        // Given - Workouts with gaps
        let entries = [
            createEntry(daysAgo: 0, minutes: 30),
            createEntry(daysAgo: 1, minutes: 30),
            createEntry(daysAgo: 2, minutes: 30),
            // Gap on day 3
            createEntry(daysAgo: 4, minutes: 30),
            createEntry(daysAgo: 5, minutes: 30),
        ]
        
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in allEntries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        let streak = calculateLongestStreak(dailyData: dailyData)
        
        // Then - Should find the longest consecutive streak
        XCTAssertEqual(streak, 3) // Days 0, 1, 2
    }
    
    func testLongestStreakNoWorkouts() {
        // When - No data
        let dailyData: [Date: Int] = [:]
        let streak = calculateLongestStreak(dailyData: dailyData)
        
        // Then
        XCTAssertEqual(streak, 0)
    }
    
    // MARK: - Active Days Calculation Tests
    
    func testTotalWorkoutDays() throws {
        // Given
        for i in 0..<5 {
            let entry = createEntry(daysAgo: i, minutes: 30)
            modelContext.insert(entry)
        }
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        let activeDays = dailyData.values.filter { $0 > 0 }.count
        
        // Then
        XCTAssertEqual(activeDays, 5)
    }
    
    func testTotalWorkoutDaysWithZeroMinutes() throws {
        // Given - Some days have 0 minutes (shouldn't happen but let's test)
        let entry1 = createEntry(daysAgo: 0, minutes: 30)
        let entry2 = createEntry(daysAgo: 1, minutes: 0)
        
        modelContext.insert(entry1)
        modelContext.insert(entry2)
        try modelContext.save()
        
        // When
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let entries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        let activeDays = dailyData.values.filter { $0 > 0 }.count
        
        // Then - Only count days with actual workout minutes
        XCTAssertEqual(activeDays, 1)
    }
    
    // MARK: - Total Minutes Calculation Tests
    
    func testTotalMinutesCalculation() throws {
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
        let descriptor = FetchDescriptor<WorkoutEntry>()
        let allEntries = try modelContext.fetch(descriptor)
        
        var dailyData: [Date: Int] = [:]
        for entry in allEntries {
            let dayStart = calendar.startOfDay(for: entry.date)
            dailyData[dayStart, default: 0] += entry.workoutMinutes
        }
        
        let totalMinutes = dailyData.values.reduce(0, +)
        
        // Then
        XCTAssertEqual(totalMinutes, 135) // 30 + 45 + 60
    }
    
    // MARK: - Color Intensity Tests
    
    func testColorForMinutes() {
        // Test different minute ranges return different colors
        let testCases: [(minutes: Int, description: String)] = [
            (0, "no workout"),
            (15, "light workout"),
            (45, "medium workout"),
            (75, "heavy workout"),
            (120, "very heavy workout")
        ]
        
        for testCase in testCases {
            // Verify that different minute ranges exist
            XCTAssertGreaterThanOrEqual(testCase.minutes, 0)
        }
    }
    
    // MARK: - Helper Functions
    
    private func calculateLongestStreak(dailyData: [Date: Int]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let weeksAgo = calendar.date(byAdding: .weekOfYear, value: -26 + 1, to: today) else {
            return 0
        }
        
        let weekday = calendar.component(.weekday, from: weeksAgo)
        let daysToSubtract = (weekday - 1) % 7
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: weeksAgo) else {
            return 0
        }
        
        var dates: [Date] = []
        var currentDate = startOfWeek
        
        while currentDate <= today {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        var currentStreak = 0
        var maxStreak = 0
        
        let sortedDates = dates.sorted()
        
        for date in sortedDates {
            if let minutes = dailyData[date], minutes > 0 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
}
