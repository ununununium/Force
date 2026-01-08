//
//  MockDataGenerator.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import Foundation
import SwiftData

struct MockDataGenerator {
    static func generateMockEntries(count: Int = 30) -> [WorkoutEntry] {
        var entries: [WorkoutEntry] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Generate entries for the last 'count' days with some randomness
        for daysAgo in 0..<count {
            // Skip some days randomly to make it more realistic (70% chance of workout)
            if Int.random(in: 0...100) > 70 {
                continue
            }
            
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                continue
            }
            
            // Random workout time between 15-120 minutes
            let workoutMinutes = [15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 90, 120].randomElement() ?? 30
            
            // Random weight with slight variation (simulate weight fluctuation)
            let baseWeight = 70.0
            let weightVariation = Double.random(in: -3.0...3.0)
            let weight = baseWeight + weightVariation
            
            // Random notes
            let possibleNotes = [
                "Great workout today! 💪",
                "Feeling strong",
                "Tough session but pushed through",
                "Easy recovery day",
                "Personal best!",
                "Feeling tired but completed it",
                "Amazing energy today",
                "Full body workout",
                "Cardio focused session",
                "Strength training day",
                ""
            ]
            let notes = possibleNotes.randomElement() ?? ""
            
            let entry = WorkoutEntry(
                date: date,
                workoutMinutes: workoutMinutes,
                weightKg: weight,
                notes: notes,
                isMockData: true
            )
            
            entries.append(entry)
        }
        
        return entries.sorted { $0.date < $1.date }
    }
    
    static func clearAllData(from modelContext: ModelContext) {
        do {
            try modelContext.delete(model: WorkoutEntry.self)
            try modelContext.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
    
    static func clearMockData(from modelContext: ModelContext) {
        do {
            // Fetch only mock data entries
            let descriptor = FetchDescriptor<WorkoutEntry>(
                predicate: #Predicate { $0.isMockData == true }
            )
            let mockEntries = try modelContext.fetch(descriptor)
            
            // Delete each mock entry
            for entry in mockEntries {
                modelContext.delete(entry)
            }
            
            try modelContext.save()
        } catch {
            print("Failed to clear mock data: \(error)")
        }
    }
    
    static func populateMockData(in modelContext: ModelContext, count: Int = 30) {
        // Clear existing mock data first (preserve real data)
        clearMockData(from: modelContext)
        
        // Generate and insert mock entries
        let mockEntries = generateMockEntries(count: count)
        for entry in mockEntries {
            modelContext.insert(entry)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save mock data: \(error)")
        }
    }
}
