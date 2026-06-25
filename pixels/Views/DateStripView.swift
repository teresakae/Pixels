//
//  DateStripView.swift
//  pixels
//

import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    @State private var currentPage: Int
    private let weeks: [[Date]]
    private let today: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        self.today = today
        let w = Self.buildWeeks(cal: cal, today: today)
        self.weeks = w
        self._currentPage = State(initialValue: max(0, w.count - 1))
    }

    // Builds 52 weeks, oldest first. Each week = 7 Date values (Mon–Sun or Sun–Sat per locale).
    private static func buildWeeks(cal: Calendar, today: Date) -> [[Date]] {
        guard
            let currentWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
            let oldestWeekStart = cal.date(byAdding: .weekOfYear, value: -51, to: currentWeekStart)
        else { return [] }

        var result: [[Date]] = []
        var weekStart = cal.startOfDay(for: oldestWeekStart)
        let weekStartOfCurrent = cal.startOfDay(for: currentWeekStart)

        while weekStart <= weekStartOfCurrent {
            let week = (0..<7).compactMap { d in
                cal.date(byAdding: .day, value: d, to: weekStart)
            }
            result.append(week)
            guard let next = cal.date(byAdding: .day, value: 7, to: weekStart) else { break }
            weekStart = next
        }
        return result
    }

    private func pageIndex(for date: Date) -> Int? {
        let cal = Calendar.current
        return weeks.firstIndex { week in
            week.contains { cal.isDate($0, inSameDayAs: date) }
        }
    }

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(weeks.indices, id: \.self) { i in
                weekPage(weeks[i])
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 60)
        .onChange(of: selectedDate) { _, newDate in
            if let idx = pageIndex(for: newDate), idx != currentPage {
                withAnimation { currentPage = idx }
            }
        }
    }

    private func weekPage(_ dates: [Date]) -> some View {
        HStack(spacing: 6) {
            ForEach(dates, id: \.self) { date in
                let isFuture = date > today
                DayCell(
                    date: date,
                    isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                    isFuture: isFuture
                )
                .onTapGesture {
                    guard !isFuture else { return }
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal, PixelsLayout.Spacing.margin)
        .frame(maxWidth: .infinity)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    var isFuture: Bool = false

    private var dayNumber: String {
        let f = DateFormatter(); f.dateFormat = "d"
        return f.string(from: date)
    }

    private var dayName: String {
        let f = DateFormatter(); f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.pixels.dateLabel)
                .foregroundStyle(isSelected ? Color.pixels.textPrimary : Color.pixels.textTertiary)

            Text(dayNumber)
                .font(.pixels.dateNumber)
                .foregroundStyle(isFuture ? Color.pixels.textTertiary : Color.pixels.textPrimary)
        }
        .frame(width: 44, height: 60)
        .background(
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.dateCell)
                .fill(isSelected ? Color.pixels.accent : Color.clear)
        )
        .opacity(isFuture ? 0.4 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
