//
//  WorkoutEntry.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutEntry {
    var date: Date
    var workoutMinutes: Int
    var weightKg: Double
    var notes: String
    var isMockData: Bool
    
    init(date: Date = Date(), workoutMinutes: Int = 0, weightKg: Double = 0.0, notes: String = "", isMockData: Bool = false) {
        self.date = date
        self.workoutMinutes = workoutMinutes
        self.weightKg = weightKg
        self.notes = notes
        self.isMockData = isMockData
    }
}

