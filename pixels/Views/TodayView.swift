//
//  TodayView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @State private var showingCalendar = false
    @State private var showingSettings = false
    @State private var showingForm = false

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
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
            VStack(spacing: 0) {
                headerView

                DateStripView(selectedDate: $selectedDate)
                    .padding(.vertical, 8)

                Divider()

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
                .navigationBarTitleDisplayMode(.inline)
            }
            // All three sheets live here, at the same level
            .sheet(isPresented: $showingCalendar) {
                CalendarPickerView(selectedDate: $selectedDate, isPresented: $showingCalendar)
            }
            .sheet(isPresented: $showingForm) {
                ActivityFormView(
                    selectedDate: selectedDate,
                    initialSlot: tappedSlot,
                    existingActivity: tappedActivity
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("So, what did you do in")
                    .font(.system(size: 16, weight: .regular))
                Text(monthName(from: selectedDate).uppercased() + "?")
                    .font(.system(size: 28, weight: .black))
            }
            Spacer()
            HStack(spacing: 16) {
                Button {
                    showingCalendar = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                }
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}
