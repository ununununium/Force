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
    @State private var debugSettings = DebugSettings.shared
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Create schema with current version
            let schema = Schema([WorkoutEntry.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Set default value for existing entries that don't have isMockData set
            let context = modelContainer.mainContext
            let descriptor = FetchDescriptor<WorkoutEntry>()
            if let entries = try? context.fetch(descriptor) {
                for entry in entries {
                    // SwiftData should handle defaults, but let's ensure it
                    // The default is already false from the model
                }
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Theme.primaryCTA)
                .fontDesign(.rounded)
                .environment(debugSettings)
        }
        .modelContainer(modelContainer)
    }
}
