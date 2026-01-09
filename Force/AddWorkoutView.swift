//
//  AddWorkoutView.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let entryToEdit: WorkoutEntry?
    
    @State private var selectedDate = Date()
    @State private var workoutMinutes: Int = 30
    @State private var weightKg: String = ""
    @State private var notes: String = ""
    @State private var showingSuccess = false
    @FocusState private var isWeightFieldFocused: Bool
    
    private var isEditMode: Bool {
        entryToEdit != nil
    }
    
    init(entryToEdit: WorkoutEntry? = nil) {
        self.entryToEdit = entryToEdit
        
        // Initialize state values from entry if editing
        if let entry = entryToEdit {
            _selectedDate = State(initialValue: entry.date)
            _workoutMinutes = State(initialValue: entry.workoutMinutes)
            _weightKg = State(initialValue: String(format: "%.1f", entry.weightKg))
            _notes = State(initialValue: entry.notes)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    VStack(spacing: 12) {
                        Image(systemName: isEditMode ? "pencil.circle.fill" : "figure.strengthtraining.traditional")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.primaryCTA)
                            .symbolEffect(.bounce, value: showingSuccess)
                        
                        Text(isEditMode ? "Edit Workout" : "Log Your Workout")
                            .font(.title2.bold())
                        
                        Text(isEditMode ? "Update your workout details" : "Track your progress, one day at a time")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    // Date Picker Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Date", systemImage: "calendar")
                            .font(.headline)
                            .foregroundStyle(Theme.primaryCTA)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .tint(Theme.primaryCTA)
                    }
                    .modifier(CardModifier())
                    
                    // Workout Duration Card
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Workout Duration", systemImage: "timer")
                            .font(.headline)
                            .foregroundStyle(Theme.primaryCTA)
                        
                        VStack(spacing: 8) {
                            Text("\(workoutMinutes) minutes")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primaryCTA)
                            
                            Slider(value: Binding(
                                get: { Double(workoutMinutes) },
                                set: { workoutMinutes = Int($0) }
                            ), in: 5...180, step: 5)
                            .tint(Theme.primaryCTA)
                            
                            HStack {
                                Text("5 min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("180 min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .modifier(CardModifier())
                    
                    // Weight Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Body Weight (kg)", systemImage: "figure.stand")
                            .font(.headline)
                            .foregroundStyle(Theme.accent2)
                        
                        TextField("Enter weight", text: $weightKg)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerSmall, style: .continuous))
                            .focused($isWeightFieldFocused)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button(action: {
                                        isWeightFieldFocused = false
                                        saveWorkout()
                                    }) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text(isEditMode ? "Update Workout" : "Save Workout")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(Theme.primaryCTA)
                                        .foregroundStyle(.white)
                                        .padding(.vertical)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
                                    .shadow(color: Theme.primaryCTA.opacity(0.3), radius: 12, y: 6)
                                }
                            }
                    }
                    .modifier(CardModifier())
                    
                    // Notes Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Notes (Optional)", systemImage: "note.text")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        TextField("How did you feel?", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerSmall, style: .continuous))
                    }
                    .modifier(CardModifier())
                    
                    // Save Button
                    Button(action: saveWorkout) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(isEditMode ? "Update Workout" : "Save Workout")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryCTA)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
                        .shadow(color: Theme.primaryCTA.opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.horizontal, Theme.pad)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, Theme.pad)
            }
            .background(Theme.heroGradient.opacity(0.3))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveWorkout() {
        guard let weight = Double(weightKg), weight > 0 else { return }
        
        if let existingEntry = entryToEdit {
            // Update existing entry
            existingEntry.date = selectedDate
            existingEntry.workoutMinutes = workoutMinutes
            existingEntry.weightKg = weight
            existingEntry.notes = notes
        } else {
            // Create new entry
            let entry = WorkoutEntry(
                date: selectedDate,
                workoutMinutes: workoutMinutes,
                weightKg: weight,
                notes: notes,
                isMockData: false  // Always save manually added entries as real data
            )
            modelContext.insert(entry)
        }
        
        // Explicitly save the context
        do {
            try modelContext.save()
        } catch {
            print("Error saving workout: \(error)")
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.pad)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .strokeBorder(Theme.hairline.opacity(0.4), lineWidth: 0.5)
            )
    }
}

#Preview {
    AddWorkoutView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}

