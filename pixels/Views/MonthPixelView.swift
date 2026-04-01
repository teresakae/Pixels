//
//  MonthPixelView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct MonthPixelView: View {
    let dates: [Date]
    let activities: [Activity]
    let categories: [Category]

    private let cellSize: CGFloat = 32
    private let cellSpacing: CGFloat = 6
    private let columns = 7

    private var dominantColorByDay: [String: Color] {
        buildDominantColors(from: activities, categories: categories)
    }

    var body: some View {
        let firstWeekdayOffset = weekdayOffset(for: dates.first ?? Date())
        let paddedDates: [Date?] = Array(repeating: nil, count: firstWeekdayOffset) + dates.map { Optional($0) }
        let rows = stride(from: 0, to: paddedDates.count, by: columns).map { start -> [Date?] in
            let slice = Array(paddedDates[start..<min(start + columns, paddedDates.count)])
            // Pad the last row to always be 7 cells
            return slice + Array(repeating: nil, count: columns - slice.count)
        }

        VStack(alignment: .center, spacing: cellSpacing) {
            // Day headers
            HStack(spacing: cellSpacing) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { d in
                    Text(d)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: cellSize, alignment: .center)
                }
            }

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: cellSpacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            let key = dayKey(date)
                            let isFuture = date > Calendar.current.startOfDay(for: Date())
                            let color = dominantColorByDay[key]

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isFuture
                                        ? Color(.systemGray5).opacity(0.4)
                                        : (color ?? Color(.systemGray5))
                                )
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            // Empty spacer cell
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
    
    // Returns how many empty cells to pad before the 1st
    private func weekdayOffset(for date: Date) -> Int {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // 1 = Sunday
        // Convert to Monday-first (Mon=0, Tue=1 … Sun=6)
        return (weekday + 5) % 7
    }
    
    private func dayKey(_ date: Date) -> String {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        return "\(d.year!)-\(d.month!)-\(d.day!)"
    }
}
