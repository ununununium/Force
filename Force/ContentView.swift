//
//  ContentView.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingAddWorkout = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showingAddWorkout: $showingAddWorkout)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            ChartsView()
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
                .tag(2)
        }
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView()
        }
    }
}

struct HomeView: View {
    @Query(sort: \WorkoutEntry.date, order: .reverse) private var entries: [WorkoutEntry]
    @Binding var showingAddWorkout: Bool
    
    private var todayEntry: WorkoutEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }
    
    private var weekEntries: [WorkoutEntry] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date >= weekAgo }
    }
    
    private var thisWeekTotal: Int {
        weekEntries.reduce(0) { $0 + $1.workoutMinutes }
    }
    
    private var streak: Int {
        var count = 0
        var currentDate = Date()
        
        for _ in 0..<30 {
            let hasWorkout = entries.contains { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
            if hasWorkout {
                count += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome Back!")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                
                                Text("Stay Strong 💪")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                            }
                            Spacer()
                        }
                        .padding(.horizontal, Theme.pad)
                        .padding(.top, 8)
                        
                        // Quick Stats
                        HStack(spacing: 12) {
                            QuickStatCard(
                                value: "\(streak)",
                                label: "Day Streak",
                                icon: "flame.fill",
                                color: Theme.warning
                            )
                            
                            QuickStatCard(
                                value: "\(weekEntries.count)",
                                label: "This Week",
                                icon: "calendar",
                                color: Theme.primaryCTA
                            )
                            
                            QuickStatCard(
                                value: "\(thisWeekTotal / 60)h",
                                label: "Total Time",
                                icon: "clock.fill",
                                color: Theme.accent2
                            )
                        }
                        .padding(.horizontal, Theme.pad)
                    }
                    
                    // Today's Status
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("Today's Progress", systemImage: "calendar.circle.fill")
                                .font(.headline)
                                .foregroundStyle(Theme.primaryCTA)
                            Spacer()
                            if todayEntry != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                            }
                        }
                        
                        if let entry = todayEntry {
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("\(entry.workoutMinutes)")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.primaryCTA)
                                    Text("minutes")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                VStack(alignment: .leading) {
                                    Text("\(entry.weightKg, specifier: "%.1f")")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.accent2)
                                    Text("kg")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            
                            if !entry.notes.isEmpty {
                                Text(entry.notes)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerSmall, style: .continuous))
                            }
                        } else {
                            VStack(spacing: 12) {
                                Text("No workout logged yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Button(action: { showingAddWorkout = true }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Log Today's Workout")
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.primaryCTA)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerSmall, style: .continuous))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                    .modifier(CardModifier())
                    .padding(.horizontal, Theme.pad)
                    
                    // Recent Activity
                    if !entries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Recent Activity", systemImage: "clock.arrow.circlepath")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            
                            ForEach(Array(entries.prefix(3))) { entry in
                                RecentActivityRow(entry: entry)
                            }
                        }
                        .modifier(CardModifier())
                        .padding(.horizontal, Theme.pad)
                    }
                    
                    // Motivational Card
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(getMotivationalMessage())
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        Text(getMotivationalSubtext())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.horizontal, Theme.pad)
                    .background(
                        LinearGradient(
                            colors: [
                                Theme.primaryCTA.opacity(0.1),
                                Theme.accent2.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                            .strokeBorder(Theme.hairline.opacity(0.4), lineWidth: 0.5)
                    )
                    .padding(.horizontal, Theme.pad)
                }
                .padding(.vertical, Theme.pad)
            }
            .background(Theme.heroGradient.opacity(0.2))
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
    
    private func getMotivationalMessage() -> String {
        if streak >= 7 {
            return "🔥 Incredible Streak!"
        } else if streak >= 3 {
            return "💪 Keep It Up!"
        } else if weekEntries.count >= 5 {
            return "🌟 Amazing Week!"
        } else if todayEntry != nil {
            return "✨ Great Work Today!"
        } else {
            return "🚀 Ready to Start?"
        }
    }
    
    private func getMotivationalSubtext() -> String {
        if streak >= 7 {
            return "You've been consistent for \(streak) days straight!"
        } else if weekEntries.count >= 5 {
            return "You've worked out \(weekEntries.count) times this week!"
        } else if todayEntry != nil {
            return "You've completed your workout for today"
        } else {
            return "Every journey begins with a single step"
        }
    }
}

struct QuickStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .strokeBorder(Theme.hairline.opacity(0.4), lineWidth: 0.5)
        )
    }
}

struct RecentActivityRow: View {
    let entry: WorkoutEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.primaryCTA.opacity(0.2))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(dateFormatter.string(from: entry.date))
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Text("\(entry.workoutMinutes) min • \(entry.weightKg, specifier: "%.1f") kg")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if entry.workoutMinutes >= 60 {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(Theme.warning)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}

