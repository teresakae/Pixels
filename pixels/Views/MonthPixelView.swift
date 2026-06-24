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
    let onDayTap: (Date) -> Void

    private let columns = 7

    private var dominantNameByDay: [String: String] {
        buildDominantNames(from: activities)
    }

    var body: some View {
        let cellSize = PixelsLayout.Size.monthCell
        let spacing = PixelsLayout.Spacing.monthCellGap
        let firstWeekdayOffset = weekdayOffset(for: dates.first ?? Date())
        let paddedDates: [Date?] = Array(repeating: nil, count: firstWeekdayOffset) + dates.map { Optional($0) }
        let rows = stride(from: 0, to: paddedDates.count, by: columns).map { start -> [Date?] in
            let slice = Array(paddedDates[start..<min(start + columns, paddedDates.count)])
            return slice + Array(repeating: nil, count: columns - slice.count)
        }

        VStack(alignment: .center, spacing: spacing) {
            HStack(spacing: spacing) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { d in
                    Text(d)
                        .font(.pixels.caption)
                        .foregroundStyle(Color.pixels.textTertiary)
                        .frame(width: cellSize.width, alignment: .center)
                }
            }

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, date in
                        if let date = date {
                            let key = dayKey(date)
                            let isFuture = date > Calendar.current.startOfDay(for: Date())
                            let catName = dominantNameByDay[key]
                            let appearance = catName.map { Color.pixels.appearance(for: $0) }

                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.monthCell)
                                .fill(
                                    isFuture
                                        ? Color.pixels.futureDot
                                        : (appearance?.fill ?? Color.pixels.surface)
                                )
                                .frame(width: cellSize.width, height: cellSize.height)
                                .onTapGesture {
                                    guard !isFuture else { return }
                                    onDayTap(date)
                                }
                        } else {
                            Color.clear
                                .frame(width: PixelsLayout.Size.monthCell.width, height: PixelsLayout.Size.monthCell.height)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, PixelsLayout.Spacing.margin)
    }

    private func weekdayOffset(for date: Date) -> Int {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        return (weekday + 5) % 7
    }
}
