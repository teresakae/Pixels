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

    private var dominantNameByDay: [String: String] {
        buildDominantNames(from: activities)
    }

    private let monthLetters = ["J","F","M","A","M","J","J","A","S","O","N","D"]
    private let today = Calendar.current.startOfDay(for: Date())
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let dayLabelWidth: CGFloat = 20
    private let gap = PixelsLayout.Spacing.yearCellGap

    @State private var containerWidth: CGFloat = 390

    var body: some View {
        let cellSize = (containerWidth - 32 - dayLabelWidth - (11 * gap)) / 12

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: gap) {
                monthHeaderRow(cellSize: cellSize)
                ForEach(1...31, id: \.self) { day in
                    dayRow(day: day, cellSize: cellSize)
                }
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { containerWidth = geo.size.width }
            }
        )
    }

    private func monthHeaderRow(cellSize: CGFloat) -> some View {
        HStack(spacing: gap) {
            Color.clear.frame(width: dayLabelWidth)
            ForEach(0..<12, id: \.self) { m in
                Text(monthLetters[m])
                    .font(.pixels.caption)
                    .foregroundStyle(Color.pixels.textTertiary)
                    .frame(width: cellSize, alignment: .center)
            }
        }
    }

    private func dayRow(day: Int, cellSize: CGFloat) -> some View {
        HStack(spacing: gap) {
            Text("\(day)")
                .font(.pixels.caption)
                .foregroundStyle(Color.pixels.textTertiary)
                .frame(width: dayLabelWidth, alignment: .trailing)
            ForEach(0..<12, id: \.self) { m in
                if let date = dateFor(month: m + 1, day: day) {
                    dayCell(for: date, cellSize: cellSize)
                } else {
                    Color.clear
                        .frame(width: cellSize, height: cellSize)
                }
            }
        }
    }

    private func dayCell(for date: Date, cellSize: CGFloat) -> some View {
        let key = dayKey(date)
        let isFuture = date > today
        let catName = dominantNameByDay[key]
        let fillColor: Color = {
            if let name = catName, !isFuture { return Color.pixels.appearance(for: name).fill }
            return Color(hex: "#E0D5CC").opacity(0.28)
        }()

        return RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.yearCell)
            .fill(fillColor)
            .frame(width: cellSize, height: cellSize)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isFuture else { return }
                onDayTap(date)
            }
    }

    private func dateFor(month: Int, day: Int) -> Date? {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = currentYear
        comps.month = month
        comps.day = day
        guard let date = cal.date(from: comps),
              cal.component(.month, from: date) == month,
              cal.component(.day, from: date) == day else { return nil }
        return cal.startOfDay(for: date)
    }
}
