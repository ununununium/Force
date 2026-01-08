//
//  DebugMenuView.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import SwiftUI
import SwiftData

struct DebugMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allEntries: [WorkoutEntry]
    
    // Use @Bindable to allow mutations via Toggle
    @Bindable private var debugSettings = DebugSettings.shared
    @State private var showingClearAllAlert = false
    @State private var showingClearMockAlert = false
    @State private var showingGenerateAlert = false
    
    private var realEntries: [WorkoutEntry] {
        allEntries.filter { !$0.isMockData }
    }
    
    private var mockEntries: [WorkoutEntry] {
        allEntries.filter { $0.isMockData }
    }
    
    private var currentEntries: [WorkoutEntry] {
        debugSettings.useMockData ? mockEntries : realEntries
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "ladybug.fill")
                                .foregroundStyle(.red)
                                .font(.title2)
                            Text("Debug Menu")
                                .font(.title2.bold())
                        }
                        
                        Text("Configure data source and testing options")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Toggle(isOn: $debugSettings.showAllData) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .foregroundStyle(debugSettings.showAllData ? .blue : .secondary)
                                Text("Show All Data")
                                    .font(.headline)
                            }
                            Text("Bypass filtering and show everything (debug mode)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.blue)
                    
                    if !debugSettings.showAllData {
                        Toggle(isOn: $debugSettings.useMockData) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: debugSettings.useMockData ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(debugSettings.useMockData ? .green : .secondary)
                                    Text("Use Mock Data")
                                        .font(.headline)
                                }
                                Text("Switch between real and generated test data")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(Theme.primaryCTA)
                        
                        if debugSettings.useMockData {
                            Stepper(value: $debugSettings.mockDataCount, in: 10...100, step: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Mock Data Count")
                                        .font(.headline)
                                    Text("\(debugSettings.mockDataCount) entries")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Data Source")
                } footer: {
                    if debugSettings.showAllData {
                        Text("Showing ALL data without filtering. Use this to debug issues. Turn off to use normal filtering.")
                    } else if debugSettings.useMockData {
                        Text("Mock data will be generated when you tap 'Generate Mock Data' below. Your real data will be preserved and can be restored by toggling this off.")
                    } else {
                        Text("Using real data from your daily recordings. Mock data is hidden but preserved in the database.")
                    }
                }
                
                Section {
                    Button {
                        showingGenerateAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundStyle(Theme.primaryCTA)
                            Text("Generate Mock Data")
                            Spacer()
                            Text("\(debugSettings.mockDataCount)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .disabled(!debugSettings.useMockData)
                    
                    Button(role: .destructive) {
                        showingClearMockAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .foregroundStyle(.orange)
                            Text("Clear Mock Data Only")
                        }
                    }
                    .disabled(mockEntries.isEmpty)
                    
                    Button(role: .destructive) {
                        showingClearAllAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Clear All Data")
                        }
                    }
                    .disabled(allEntries.isEmpty)
                } header: {
                    Text("Actions")
                } footer: {
                    Text("Generate mock data requires 'Use Mock Data' to be enabled. 'Clear Mock Data Only' preserves your real data.")
                }
                
                Section {
                    HStack {
                        Text("Real Data Entries")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(realEntries.count)")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.green)
                    }
                    
                    HStack {
                        Text("Mock Data Entries")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(mockEntries.count)")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                    
                    HStack {
                        Text("Currently Showing")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if debugSettings.showAllData {
                            Text("All (\(allEntries.count))")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(.blue)
                        } else {
                            Text(debugSettings.useMockData ? "Mock (\(mockEntries.count))" : "Real (\(realEntries.count))")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .foregroundStyle(debugSettings.useMockData ? .orange : .green)
                        }
                    }
                    
                    HStack {
                        Text("Total Entries")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(allEntries.count)")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                } header: {
                    Text("Statistics")
                }
                
                Section {
                    Button {
                        debugSettings.reset()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundStyle(.secondary)
                            Text("Reset Debug Settings")
                                .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    Text("Force v1.0\nDebug Menu for Development")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Generate Mock Data", isPresented: $showingGenerateAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Generate") {
                    generateMockData()
                }
            } message: {
                Text("This will replace existing mock data with \(debugSettings.mockDataCount) new mock workout entries. Your real data will be preserved.")
            }
            .alert("Clear Mock Data", isPresented: $showingClearMockAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearMockData()
                }
            } message: {
                Text("This will permanently delete \(mockEntries.count) mock workout entries. Your real data will be preserved.")
            }
            .alert("Clear All Data", isPresented: $showingClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete ALL workout entries (both real and mock). This action cannot be undone.")
            }
        }
    }
    
    private func generateMockData() {
        MockDataGenerator.populateMockData(in: modelContext, count: debugSettings.mockDataCount)
    }
    
    private func clearMockData() {
        MockDataGenerator.clearMockData(from: modelContext)
    }
    
    private func clearAllData() {
        MockDataGenerator.clearAllData(from: modelContext)
    }
}

#Preview {
    DebugMenuView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}
