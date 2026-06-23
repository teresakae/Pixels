//
//  DateStripView.swift
//  pixels
//

import SwiftUI

struct DateStripView: View {
    @Binding var selectedDate: Date

    private var dates: [Date] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<365).compactMap {
            cal.date(byAdding: .day, value: -$0, to: today)
        }.reversed()
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(dates, id: \.self) { date in
                        DayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        )
                        .onTapGesture { selectedDate = date }
                        .id(date)
                    }
                }
                .padding(.horizontal, PixelsLayout.Spacing.margin)
            }
            .onAppear {
                proxy.scrollTo(Calendar.current.startOfDay(for: Date()), anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                withAnimation { proxy.scrollTo(newDate, anchor: .center) }
            }
        }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool

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
                .foregroundStyle(Color.pixels.textPrimary)
        }
        .frame(width: 44, height: 60)
        .background(
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.dateCell)
                .fill(isSelected ? Color.pixels.accent : Color.clear)
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
