//
//  DebugSettings.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import Foundation
import SwiftUI

@Observable
class DebugSettings {
    static let shared = DebugSettings()
    
    var useMockData: Bool {
        didSet {
            UserDefaults.standard.set(useMockData, forKey: "useMockData")
        }
    }
    
    var mockDataCount: Int {
        didSet {
            UserDefaults.standard.set(mockDataCount, forKey: "mockDataCount")
        }
    }
    
    private init() {
        self.useMockData = UserDefaults.standard.bool(forKey: "useMockData")
        self.mockDataCount = UserDefaults.standard.integer(forKey: "mockDataCount")
        
        // Default to 30 entries if not set
        if mockDataCount == 0 {
            mockDataCount = 30
        }
    }
    
    func reset() {
        useMockData = false
        mockDataCount = 30
    }
}
