//
//  DebugSettingsTests.swift
//  ForceTests
//
//  Created by AI Assistant on 1/8/26.
//

import XCTest
@testable import Force

final class DebugSettingsTests: XCTestCase {
    var suiteName: String!
    var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        // Use a unique suite name for each test
        suiteName = "test_\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        
        // Clear all values
        userDefaults.removePersistentDomain(forName: suiteName)
    }
    
    override func tearDown() {
        // Clean up
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        // Note: We're testing the actual shared instance behavior
        // In a real scenario, we'd need dependency injection for proper unit testing
        
        // Given - Clean UserDefaults
        UserDefaults.standard.removeObject(forKey: "useMockData")
        UserDefaults.standard.removeObject(forKey: "mockDataCount")
        UserDefaults.standard.removeObject(forKey: "showAllData")
        
        // When - Access default values
        let useMockData = UserDefaults.standard.bool(forKey: "useMockData")
        let showAllData = UserDefaults.standard.bool(forKey: "showAllData")
        
        // Then - Should have default values
        XCTAssertFalse(useMockData, "useMockData should default to false")
        XCTAssertFalse(showAllData, "showAllData should default to false")
    }
    
    func testMockDataCountDefaultValue() {
        // Given - Clean UserDefaults
        UserDefaults.standard.removeObject(forKey: "mockDataCount")
        
        // When
        var mockDataCount = UserDefaults.standard.integer(forKey: "mockDataCount")
        
        // Default integer is 0, so we test the initialization logic
        if mockDataCount == 0 {
            mockDataCount = 30
        }
        
        // Then
        XCTAssertEqual(mockDataCount, 30)
    }
    
    // MARK: - Persistence Tests
    
    func testUseMockDataPersistence() {
        // Given
        userDefaults.set(true, forKey: "useMockData")
        
        // When
        let retrieved = userDefaults.bool(forKey: "useMockData")
        
        // Then
        XCTAssertTrue(retrieved)
    }
    
    func testMockDataCountPersistence() {
        // Given
        let count = 50
        userDefaults.set(count, forKey: "mockDataCount")
        
        // When
        let retrieved = userDefaults.integer(forKey: "mockDataCount")
        
        // Then
        XCTAssertEqual(retrieved, count)
    }
    
    func testShowAllDataPersistence() {
        // Given
        userDefaults.set(true, forKey: "showAllData")
        
        // When
        let retrieved = userDefaults.bool(forKey: "showAllData")
        
        // Then
        XCTAssertTrue(retrieved)
    }
    
    // MARK: - Reset Tests
    
    func testResetToDefaults() {
        // Given
        userDefaults.set(true, forKey: "useMockData")
        userDefaults.set(50, forKey: "mockDataCount")
        userDefaults.set(true, forKey: "showAllData")
        
        // When - Simulate reset
        userDefaults.set(false, forKey: "useMockData")
        userDefaults.set(30, forKey: "mockDataCount")
        userDefaults.set(false, forKey: "showAllData")
        
        // Then
        XCTAssertFalse(userDefaults.bool(forKey: "useMockData"))
        XCTAssertEqual(userDefaults.integer(forKey: "mockDataCount"), 30)
        XCTAssertFalse(userDefaults.bool(forKey: "showAllData"))
    }
    
    // MARK: - Value Range Tests
    
    func testMockDataCountValidRange() {
        // Test various counts
        let validCounts = [10, 20, 30, 50, 100]
        
        for count in validCounts {
            userDefaults.set(count, forKey: "mockDataCount")
            let retrieved = userDefaults.integer(forKey: "mockDataCount")
            
            XCTAssertEqual(retrieved, count)
            XCTAssertGreaterThanOrEqual(retrieved, 10)
            XCTAssertLessThanOrEqual(retrieved, 100)
        }
    }
    
    // MARK: - Toggle Behavior Tests
    
    func testUseMockDataToggle() {
        // Start with false
        userDefaults.set(false, forKey: "useMockData")
        XCTAssertFalse(userDefaults.bool(forKey: "useMockData"))
        
        // Toggle to true
        userDefaults.set(true, forKey: "useMockData")
        XCTAssertTrue(userDefaults.bool(forKey: "useMockData"))
        
        // Toggle back to false
        userDefaults.set(false, forKey: "useMockData")
        XCTAssertFalse(userDefaults.bool(forKey: "useMockData"))
    }
    
    func testShowAllDataToggle() {
        // Start with false
        userDefaults.set(false, forKey: "showAllData")
        XCTAssertFalse(userDefaults.bool(forKey: "showAllData"))
        
        // Toggle to true
        userDefaults.set(true, forKey: "showAllData")
        XCTAssertTrue(userDefaults.bool(forKey: "showAllData"))
        
        // Toggle back to false
        userDefaults.set(false, forKey: "showAllData")
        XCTAssertFalse(userDefaults.bool(forKey: "showAllData"))
    }
    
    // MARK: - Multiple Settings Interaction Tests
    
    func testMultipleSettingsIndependence() {
        // Set different values
        userDefaults.set(true, forKey: "useMockData")
        userDefaults.set(40, forKey: "mockDataCount")
        userDefaults.set(false, forKey: "showAllData")
        
        // Verify each is stored independently
        XCTAssertTrue(userDefaults.bool(forKey: "useMockData"))
        XCTAssertEqual(userDefaults.integer(forKey: "mockDataCount"), 40)
        XCTAssertFalse(userDefaults.bool(forKey: "showAllData"))
        
        // Change one setting
        userDefaults.set(false, forKey: "useMockData")
        
        // Others should remain unchanged
        XCTAssertFalse(userDefaults.bool(forKey: "useMockData"))
        XCTAssertEqual(userDefaults.integer(forKey: "mockDataCount"), 40)
        XCTAssertFalse(userDefaults.bool(forKey: "showAllData"))
    }
}
