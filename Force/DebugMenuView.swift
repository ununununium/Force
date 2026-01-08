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
    @Query private var entries: [WorkoutEntry]
    
    @State private var debugSettings = DebugSettings.shared
    @State private var showingClearAlert = false
    @State private var showingGenerateAlert = false
    
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
                } header: {
                    Text("Data Source")
                } footer: {
                    if debugSettings.useMockData {
                        Text("Mock data will be generated when you tap 'Generate Mock Data' below. This will replace all existing data.")
                    } else {
                        Text("Using real data from your daily recordings")
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
                        showingClearAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                            Text("Clear All Data")
                        }
                    }
                } header: {
                    Text("Actions")
                } footer: {
                    Text("Generate mock data requires 'Use Mock Data' to be enabled")
                }
                
                Section {
                    HStack {
                        Text("Current Entries")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(entries.count)")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                    
                    HStack {
                        Text("Data Mode")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(debugSettings.useMockData ? "Mock" : "Real")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(debugSettings.useMockData ? .orange : .green)
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
                Button("Generate", role: .destructive) {
                    generateMockData()
                }
            } message: {
                Text("This will clear all existing data and generate \(debugSettings.mockDataCount) mock workout entries. This action cannot be undone.")
            }
            .alert("Clear All Data", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all workout entries. This action cannot be undone.")
            }
        }
    }
    
    private func generateMockData() {
        MockDataGenerator.populateMockData(in: modelContext, count: debugSettings.mockDataCount)
    }
    
    private func clearAllData() {
        MockDataGenerator.clearAllData(from: modelContext)
    }
}

#Preview {
    DebugMenuView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}
