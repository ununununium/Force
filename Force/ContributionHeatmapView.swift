//
//  ContributionHeatmapView.swift
//  Force
//
//  Created by AI Assistant on 1/7/26.
//

import SwiftUI
import SwiftData

struct ContributionHeatmapView: View {
    let entries: [WorkoutEntry]
    let weeksToShow: Int
    
    init(entries: [WorkoutEntry], weeksToShow: Int = 26) {
        self.entries = entries
        self.weeksToShow = weeksToShow
    }
    
    private var dailyData: [Date: Int] {
        var data: [Date: Int] = [:]
        let calendar = Calendar.current
        
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            data[dayStart, default: 0] += entry.workoutMinutes
        }
        
        return data
    }
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate the start date (beginning of the week for weeksToShow weeks ago)
        guard let weeksAgo = calendar.date(byAdding: .weekOfYear, value: -weeksToShow + 1, to: today) else {
            return []
        }
        
        // Find the start of that week (Sunday)
        let weekday = calendar.component(.weekday, from: weeksAgo)
        let daysToSubtract = (weekday - 1) % 7
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: weeksAgo) else {
            return []
        }
        
        // Generate all dates from start to today
        var dates: [Date] = []
        var currentDate = startOfWeek
        
        while currentDate <= today {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        return dates
    }
    
    private var weeks: [[Date]] {
        let calendar = Calendar.current
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []
        
        for date in dateRange {
            currentWeek.append(date)
            
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 7 { // Saturday (end of week in our display)
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        
        // Add any remaining days
        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    private var monthLabels: [(offset: Int, label: String)] {
        let calendar = Calendar.current
        var labels: [(offset: Int, label: String)] = []
        var lastMonth = -1
        
        for (weekIndex, week) in weeks.enumerated() {
            guard let firstDate = week.first else { continue }
            let month = calendar.component(.month, from: firstDate)
            
            if month != lastMonth {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                labels.append((offset: weekIndex, label: formatter.string(from: firstDate)))
                lastMonth = month
            }
        }
        
        return labels
    }
    
    private func colorForMinutes(_ minutes: Int) -> Color {
        if minutes == 0 {
            return Color(.systemGray6)
        } else if minutes < 30 {
            return Theme.primaryCTA.opacity(0.3)
        } else if minutes < 60 {
            return Theme.primaryCTA.opacity(0.5)
        } else if minutes < 90 {
            return Theme.primaryCTA.opacity(0.7)
        } else {
            return Theme.primaryCTA
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Activity Heatmap", systemImage: "square.grid.3x3.fill")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // Heatmap with responsive sizing
            GeometryReader { geometry in
                let dayLabelsWidth: CGFloat = 30
                let spacing: CGFloat = 2
                let horizontalPadding: CGFloat = 8
                let availableWidth = geometry.size.width - dayLabelsWidth - (horizontalPadding * 2)
                let totalSpacing = CGFloat(weeks.count - 1) * spacing
                let cellSize = max(8, min(12, (availableWidth - totalSpacing) / CGFloat(weeks.count)))
                
                VStack(alignment: .leading, spacing: 4) {
                    // Month labels
                    HStack(spacing: 0) {
                        // Spacer for day labels
                        Spacer()
                            .frame(width: dayLabelsWidth)
                        
                        ZStack(alignment: .leading) {
                            ForEach(monthLabels, id: \.offset) { label in
                                Text(label.label)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .offset(x: CGFloat(label.offset) * (cellSize + spacing))
                            }
                        }
                        .frame(height: 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    HStack(alignment: .top, spacing: spacing) {
                        // Day labels (M, W, F)
                        VStack(alignment: .trailing, spacing: spacing) {
                            ForEach(0..<7) { day in
                                Text(dayLabel(for: day))
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)
                                    .opacity(day % 2 == 1 ? 1.0 : 0.0)
                                    .frame(width: dayLabelsWidth - 6, height: cellSize)
                            }
                        }
                        
                        // Heatmap grid
                        HStack(alignment: .top, spacing: spacing) {
                            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                                let week = weeks[weekIndex]
                                VStack(spacing: spacing) {
                                    ForEach(0..<7, id: \.self) { dayIndex in
                                        if dayIndex < week.count {
                                            let date = week[dayIndex]
                                            let minutes = dailyData[date] ?? 0
                                            
                                            RoundedRectangle(cornerRadius: max(1, cellSize * 0.15), style: .continuous)
                                                .fill(colorForMinutes(minutes))
                                                .frame(width: cellSize, height: cellSize)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: max(1, cellSize * 0.15), style: .continuous)
                                                        .strokeBorder(Color(.systemBackground), lineWidth: 0.5)
                                                )
                                        } else {
                                            Rectangle()
                                                .fill(.clear)
                                                .frame(width: cellSize, height: cellSize)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Legend
                    HStack(spacing: 8) {
                        Text("Less")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 3) {
                            ForEach([0, 30, 60, 90, 120], id: \.self) { minutes in
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(colorForMinutes(minutes))
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                                            .strokeBorder(Color(.systemBackground), lineWidth: 0.5)
                                    )
                            }
                        }
                        
                        Text("More")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    .padding(.leading, dayLabelsWidth)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
            .frame(height: 150)
            
            // Stats summary
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalWorkoutDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryCTA)
                    Text("active days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(longestStreak)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent2)
                    Text("day streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(totalMinutes / 60)h")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.warning)
                    Text("total time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .modifier(CardModifier())
    }
    
    private func dayLabel(for index: Int) -> String {
        let labels = ["S", "M", "T", "W", "T", "F", "S"]
        return labels[index]
    }
    
    private var totalWorkoutDays: Int {
        dailyData.values.filter { $0 > 0 }.count
    }
    
    private var longestStreak: Int {
        let calendar = Calendar.current
        var currentStreak = 0
        var maxStreak = 0
        
        let sortedDates = dateRange.sorted()
        
        for date in sortedDates {
            if let minutes = dailyData[date], minutes > 0 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return maxStreak
    }
    
    private var totalMinutes: Int {
        dailyData.values.reduce(0, +)
    }
}

#Preview {
    let container = try! ModelContainer(for: WorkoutEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // Generate sample data
    let calendar = Calendar.current
    for i in 0..<100 {
        let date = calendar.date(byAdding: .day, value: -i, to: Date())!
        let minutes = [0, 0, 30, 45, 60, 90, 120].randomElement()!
        let entry = WorkoutEntry(date: date, workoutMinutes: minutes, weightKg: 70.0, notes: "", isMockData: true)
        container.mainContext.insert(entry)
    }
    
    let entries = try! container.mainContext.fetch(FetchDescriptor<WorkoutEntry>())
    
    return ScrollView {
        ContributionHeatmapView(entries: entries, weeksToShow: 26)
            .padding()
    }
}
