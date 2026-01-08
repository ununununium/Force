//
//  ForceApp.swift
//  Force
//
//  Created by Yuting Zhong on 1/6/26.
//

import SwiftUI
import SwiftData

@main
struct ForceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Theme.primaryCTA)
                .fontDesign(.rounded)
        }
        .modelContainer(for: [WorkoutEntry.self])
    }
}
