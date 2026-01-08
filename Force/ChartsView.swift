//
//  ChartsView.swift
//  Force
//
//  Created by Yuting Zhong on 1/7/26.
//

import SwiftUI
import SwiftData
import Charts

struct ChartsView: View {
    @Query(sort: \WorkoutEntry.date, order: .forward) private var allEntries: [WorkoutEntry]
    @Environment(DebugSettings.self) private var debugSettings
    @State private var selectedTimeRange: TimeRange = .month
    
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
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            }
        }
    }
    
    private var filteredEntries: [WorkoutEntry] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()
        return entries.filter { $0.date >= cutoffDate }
    }
    
    private var totalMinutes: Int {
        filteredEntries.reduce(0) { $0 + $1.workoutMinutes }
    }
    
    private var averageWeight: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        return filteredEntries.reduce(0.0) { $0 + $1.weightKg } / Double(filteredEntries.count)
    }
    
    private var workoutCount: Int {
        filteredEntries.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.pad)
                    
                    if filteredEntries.isEmpty {
                        EmptyStateView()
                    } else {
                        // Stats Cards
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Workouts",
                                value: "\(workoutCount)",
                                icon: "figure.run",
                                color: Theme.primaryCTA
                            )
                            
                            StatCard(
                                title: "Total Time",
                                value: "\(totalMinutes / 60)h \(totalMinutes % 60)m",
                                icon: "clock.fill",
                                color: Theme.accent2
                            )
                        }
                        .padding(.horizontal, Theme.pad)
                        
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Avg Weight",
                                value: String(format: "%.1f kg", averageWeight),
                                icon: "figure.stand",
                                color: Theme.warning
                            )
                            
                            StatCard(
                                title: "Avg Duration",
                                value: "\(totalMinutes / workoutCount) min",
                                icon: "timer",
                                color: .orange
                            )
                        }
                        .padding(.horizontal, Theme.pad)
                        
                        // Workout Duration Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Workout Duration", systemImage: "chart.bar.fill")
                                .font(.headline)
                                .foregroundStyle(Theme.primaryCTA)
                            
                            Chart(filteredEntries) { entry in
                                BarMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Minutes", entry.workoutMinutes)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.primaryCTA, Theme.primaryCTA.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .cornerRadius(6)
                            }
                            .frame(height: 220)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: selectedTimeRange == .week ? 1 : 7)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let minutes = value.as(Int.self) {
                                            Text("\(minutes)m")
                                        }
                                    }
                                }
                            }
                        }
                        .modifier(CardModifier())
                        .padding(.horizontal, Theme.pad)
                        
                        // Weight Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Body Weight Trend", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.headline)
                                .foregroundStyle(Theme.accent2)
                            
                            Chart(filteredEntries) { entry in
                                LineMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Weight", entry.weightKg)
                                )
                                .foregroundStyle(Theme.accent2)
                                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Weight", entry.weightKg)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Theme.accent2.opacity(0.3), Theme.accent2.opacity(0.05)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Date", entry.date, unit: .day),
                                    y: .value("Weight", entry.weightKg)
                                )
                                .foregroundStyle(Theme.accent2)
                                .symbolSize(60)
                            }
                            .frame(height: 220)
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day, count: selectedTimeRange == .week ? 1 : 7)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let weight = value.as(Double.self) {
                                            Text("\(weight, specifier: "%.1f") kg")
                                        }
                                    }
                                }
                            }
                        }
                        .modifier(CardModifier())
                        .padding(.horizontal, Theme.pad)
                        
                        // Combined Overview Chart
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Weekly Overview", systemImage: "chart.bar.xaxis")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Chart {
                                ForEach(getWeeklyData(), id: \.weekStart) { data in
                                    BarMark(
                                        x: .value("Week", data.weekStart, unit: .weekOfYear),
                                        y: .value("Minutes", data.totalMinutes)
                                    )
                                    .foregroundStyle(by: .value("Type", "Workout Time"))
                                    .position(by: .value("Type", "Workout Time"))
                                }
                            }
                            .frame(height: 180)
                            .chartForegroundStyleScale([
                                "Workout Time": Theme.primaryCTA
                            ])
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .weekOfYear)) { _ in
                                    AxisGridLine()
                                    AxisValueLabel(format: .dateTime.month().day())
                                }
                            }
                        }
                        .modifier(CardModifier())
                        .padding(.horizontal, Theme.pad)
                    }
                }
                .padding(.vertical, Theme.pad)
            }
            .background(Theme.heroGradient.opacity(0.2))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func getWeeklyData() -> [WeeklyData] {
        let calendar = Calendar.current
        var weeklyDict: [Date: Int] = [:]
        
        for entry in filteredEntries {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
            weeklyDict[weekStart, default: 0] += entry.workoutMinutes
        }
        
        return weeklyDict.map { WeeklyData(weekStart: $0.key, totalMinutes: $0.value) }
            .sorted { $0.weekStart < $1.weekStart }
    }
    
    struct WeeklyData {
        let weekStart: Date
        let totalMinutes: Int
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                .strokeBorder(Theme.hairline.opacity(0.4), lineWidth: 0.5)
        )
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Data Yet")
                .font(.title2.bold())
            
            Text("Start logging your workouts to see your progress here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

#Preview {
    ChartsView()
        .modelContainer(for: WorkoutEntry.self, inMemory: true)
}

