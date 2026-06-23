//
//  PixelGridView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI
import SwiftData

struct PixelGridView: View {
    let activities: [Activity]
    let categories: [Category]
    let onDayTap: (Date) -> Void

    private var dominantColorByDay: [String: Color] {
        var slotsByDay: [String: [String: Int]] = [:]

        for activity in activities {
            let key = dayKey(activity.date)
            let catName = activity.category?.name ?? "Other"
            slotsByDay[key, default: [:]][catName, default: 0] += activity.durationSlots
        }

        var result: [String: Color] = [:]
        for (dateKey, catSlots) in slotsByDay {
            let dominant = catSlots.sorted {
                $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key
            }.first?.key

            if let name = dominant,
               let cat = categories.first(where: { $0.name == name }) {
                result[dateKey] = cat.color
            }
        }
        return result
    }

    private var months: [Date] {
        let cal = Calendar.current
        let year = cal.component(.year, from: Date())
        return (1...12).compactMap {
            DateComponents(calendar: cal, year: year, month: $0, day: 1).date
        }
    }

    private let cellSize: CGFloat = 9
    private let cellSpacing: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(months, id: \.self) { monthStart in
                monthRow(for: monthStart)
            }
        }
        .padding(.horizontal, 16)
    }

    private func monthRow(for monthStart: Date) -> some View {
        let days = daysInMonth(monthStart)
        let monthLabel = monthAbbrev(monthStart)

        return HStack(alignment: .center, spacing: 0) {
            Text(monthLabel)
                .font(.system(size: 11, weight: .medium).monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)

            HStack(spacing: cellSpacing) {
                ForEach(days, id: \.self) { date in
                    let key = dayKey(date)
                    let isFuture = date > Calendar.current.startOfDay(for: Date())
                    let color = dominantColorByDay[key]

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            isFuture
                                ? Color(.systemGray5).opacity(0.4)
                                : (color ?? Color(.systemGray5))
                        )
                        .frame(width: cellSize, height: cellSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(Color(.separator).opacity(0.2), lineWidth: 0.5)
                        )
                        .onTapGesture {
                            guard !isFuture else { return }
                            onDayTap(date)
                        }
                }
            }
        }
    }

    private func daysInMonth(_ monthStart: Date) -> [Date] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        return range.compactMap {
            cal.date(bySetting: .day, value: $0, of: monthStart)
        }
    }

    private func dayKey(_ date: Date) -> String {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        return "\(d.year!)-\(d.month!)-\(d.day!)"
    }

    private func monthAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date).uppercased()
    }
}
