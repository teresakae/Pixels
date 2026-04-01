//
//  DateStripView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    // Generates last year-today
    private var dates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<365).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }.reversed()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dates, id: \.self) { date in
                        DayCell(date: date, isSelected: isSameDay(date, selectedDate))
                            .onTapGesture {
                                selectedDate = date
                            }
                            .id(date)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                // Launches on Today
                let today = Calendar.current.startOfDay(for: Date())
                proxy.scrollTo(today, anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                withAnimation {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }

    private func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool

    private var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }

    private var dayName: String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(dayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? .white : .secondary)

            Text(dayNumber)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .frame(width: 44, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue : Color.clear)
        )
    }
}
