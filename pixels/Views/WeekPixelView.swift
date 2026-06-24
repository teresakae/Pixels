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
    let onDayTap: (Date) -> Void

    private var dominantNameByDay: [String: String] {
        buildDominantNames(from: activities)
    }

    private let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    var body: some View {
        HStack(spacing: PixelsLayout.Spacing.weekCellGap) {
            ForEach(Array(dates.enumerated()), id: \.offset) { index, date in
                let key = dayKey(date)
                let isFuture = date > Calendar.current.startOfDay(for: Date())
                let catName = dominantNameByDay[key]
                let appearance = catName.map { Color.pixels.appearance(for: $0) }
                let isToday = Calendar.current.isDateInToday(date)

                VStack(spacing: 6) {
                    Text(dayLabels[safe: index] ?? "")
                        .font(.pixels.caption)
                        .foregroundStyle(isToday ? Color.pixels.textPrimary : Color.pixels.textTertiary)

                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.weekCell)
                        .fill(
                            isFuture
                                ? Color.pixels.surface
                                : (appearance?.fill ?? Color.pixels.surface)
                        )
                        .frame(
                            width: PixelsLayout.Size.weekCell.width,
                            height: PixelsLayout.Size.weekCell.height
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.weekCell)
                                .strokeBorder(
                                    isToday
                                        ? (appearance?.border ?? Color.pixels.accent)
                                        : Color.pixels.borderSurface,
                                    lineWidth: isToday
                                        ? PixelsLayout.BorderWidth.strong
                                        : PixelsLayout.BorderWidth.default
                                )
                        )
                        .onTapGesture {
                            guard !isFuture else { return }
                            onDayTap(date)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
