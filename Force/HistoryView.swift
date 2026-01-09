//
//  HistoryView.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutEntry.date, order: .reverse) private var allEntries: [WorkoutEntry]
    @Environment(DebugSettings.self) private var debugSettings
    @State private var showingAddWorkout = false
    @State private var selectedEntry: WorkoutEntry?
    @State private var showingDeleteAlert = false
    @State private var editingEntry: WorkoutEntry?
    
    private var entries: [WorkoutEntry] {
        // Debug mode: show all data
        if debugSettings.showAllData {
            return allEntries
        }
        
        // Only filter if explicitly in mock mode
        if debugSettings.useMockData {
            return allEntries.filter { $0.isMockData == true }
        } else {
            // Show only real data (or all data if isMockData is not set/false)
            return allEntries.filter { $0.isMockData == false }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    ContentUnavailableView {
                        Label("No Workouts Yet", systemImage: "figure.strengthtraining.traditional")
                    } description: {
                        Text("Tap the + button to log your first workout")
                    }
                } else {
                    List {
                        ForEach(groupedEntries.keys.sorted(by: >), id: \.self) { date in
                            Section {
                                ForEach(groupedEntries[date] ?? []) { entry in
                                    WorkoutCard(entry: entry)
                                        .listRowInsets(EdgeInsets(top: 6, leading: Theme.pad, bottom: 6, trailing: Theme.pad))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingEntry = entry
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                withAnimation {
                                                    deleteEntry(entry)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                editingEntry = entry
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(Theme.primaryCTA)
                                        }
                                        .contextMenu {
                                            Button {
                                                editingEntry = entry
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                selectedEntry = entry
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            } header: {
                                Text(date, style: .date)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.heroGradient.opacity(0.2))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddWorkout = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                AddWorkoutView()
            }
            .sheet(item: $editingEntry) { entry in
                AddWorkoutView(entryToEdit: entry)
            }
            .alert("Delete Workout", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let entry = selectedEntry {
                        deleteEntry(entry)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this workout entry?")
            }
        }
    }
    
    private var groupedEntries: [Date: [WorkoutEntry]] {
        Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
    }
    
    private func deleteEntry(_ entry: WorkoutEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

struct WorkoutCard: View {
    let entry: WorkoutEntry
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Theme.primaryCTA.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundStyle(Theme.primaryCTA)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(timeFormatter.string(from: entry.date))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            Label {
                                Text("\(entry.workoutMinutes) min")
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                            } icon: {
                                Image(systemName: "timer")
                                    .foregroundStyle(Theme.primaryCTA)
                            }
                            
                            Label {
                                Text("\(entry.weightKg, specifier: "%.1f") kg")
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                            } icon: {
                                Image(systemName: "figure.stand")
                                    .foregroundStyle(Theme.accent2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Achievement Badge (if workout > 60 min)
                    if entry.workoutMinutes >= 60 {
                        Image(systemName: "star.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.warning)
                    }
                }
                
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
        }
        .padding(Theme.pad)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .strokeBorder(Theme.hairline.opacity(0.4), lineWidth: 0.5)
        )
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}

