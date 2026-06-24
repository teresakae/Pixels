//
//  TodayView.swift
//  pixels
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Binding var selectedDate: Date
    @State private var showingForm = false
    @State private var tappedSlot: Int = 0
    @State private var tappedActivity: Activity? = nil

    @Query private var allActivities: [Activity]

    private var activitiesForSelectedDate: [Activity] {
        allActivities.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pixels.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    PixelsDivider()

                    DateStripView(selectedDate: $selectedDate)
                        .padding(.vertical, 8)

                    Rectangle()
                        .fill(Color.pixels.borderStrong)
                        .frame(height: PixelsLayout.BorderWidth.strong)

                    TimeGridView(
                        selectedDate: selectedDate,
                        activities: activitiesForSelectedDate,
                        onSlotTap: { slot in
                            tappedSlot = slot
                            tappedActivity = nil
                            showingForm = true
                        },
                        onActivityTap: { activity in
                            tappedActivity = activity
                            tappedSlot = activity.startSlot
                            showingForm = true
                        }
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingForm) {
                ActivityFormView(
                    selectedDate: selectedDate,
                    initialSlot: tappedSlot,
                    existingActivity: tappedActivity
                )
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrowText)
                .pixelsEyebrow()

            HStack(alignment: .center, spacing: 0) {
                Text("Your day, in colour.")
                    .font(.pixels.header)
                    .foregroundStyle(Color.pixels.textPrimary)

                Spacer()

                if !activitiesForSelectedDate.isEmpty {
                    colorDots
                }
            }
        }
        .padding(.horizontal, PixelsLayout.Spacing.margin)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var colorDots: some View {
        let names = uniqueCategoryNames(from: activitiesForSelectedDate)
        return HStack(spacing: -5) {
            ForEach(names, id: \.self) { name in
                Circle()
                    .fill(Color.pixels.appearance(for: name).border)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle().strokeBorder(Color.pixels.background, lineWidth: 1.5)
                    )
            }
        }
    }

    // MARK: - Helpers

    private var eyebrowText: String {
        let cal = Calendar.current
        let today     = cal.startOfDay(for: Date())
        let yesterday = cal.date(byAdding: .day, value: -1, to: today)!

        let monthDay = DateFormatter()
        monthDay.dateFormat = "MMMM d"
        let dateStr = monthDay.string(from: selectedDate)

        if cal.isDate(selectedDate, inSameDayAs: today) {
            return "Today · \(dateStr)"
        } else if cal.isDate(selectedDate, inSameDayAs: yesterday) {
            return "Yesterday · \(dateStr)"
        } else {
            let dayName = DateFormatter()
            dayName.dateFormat = "EEEE"
            return "\(dayName.string(from: selectedDate)) · \(dateStr)"
        }
    }

    private func uniqueCategoryNames(from activities: [Activity]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for activity in activities {
            if let name = activity.category?.name, !seen.contains(name) {
                seen.insert(name)
                result.append(name)
                if result.count == 3 { break }
            }
        }
        return result
    }
}
