//
//  WeekPixelView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct WeekPixelView: View {
    let dates: [Date]
    let activities: [Activity]
    let categories: [Category]

    private let cellSize: CGFloat = 44
    private let cellSpacing: CGFloat = 8

    private var dominantColorByDay: [String: Color] {
        buildDominantColors(from: activities, categories: categories)
    }

    private let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    var body: some View {
        HStack(spacing: cellSpacing) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                let key = dayKey(date)
                let isFuture = date > Calendar.current.startOfDay(for: Date())
                let color = dominantColorByDay[key]
                let isToday = Calendar.current.isDateInToday(date)

                VStack(spacing: 6) {
                    Text(dayLabels[safe: index] ?? "")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isToday ? .primary : .secondary)

                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isFuture
                                ? Color(.systemGray5).opacity(0.4)
                                : (color ?? Color(.systemGray5))
                        )
                        .frame(width: cellSize, height: cellSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(isToday ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func dayKey(_ date: Date) -> String {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        return "\(d.year!)-\(d.month!)-\(d.day!)"
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
