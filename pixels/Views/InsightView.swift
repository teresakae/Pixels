//
//  InsightView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI
import SwiftData

struct InsightView: View {
    @Query private var allActivities: [Activity]
    @Query private var allCategories: [Category]

    @State private var selectedPeriod: Period = .year

    enum Period: String, CaseIterable {
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
    }

    // MARK: - Filtered activities by period
    private var filteredActivities: [Activity] {
        let cal = Calendar.current
        let now = Date()
        return allActivities.filter { activity in
            switch selectedPeriod {
            case .week:
                let weekInterval = cal.dateInterval(of: .weekOfYear, for: now)
                return weekInterval?.contains(activity.date) ?? false
            case .month:
                return cal.isDate(activity.date, equalTo: now, toGranularity: .month)
            case .year:
                return cal.isDate(activity.date, equalTo: now, toGranularity: .year)
            }
        }
    }

    // MARK: - Date range for pixel grid
    private var gridDates: [Date] {
        let cal = Calendar.current
        let now = Date()
        switch selectedPeriod {
        case .week:
            guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: now) else { return [] }
            var dates: [Date] = []
            var current = cal.startOfDay(for: weekInterval.start)
            while current < weekInterval.end {
                dates.append(current)
                current = cal.date(byAdding: .day, value: 1, to: current)!
            }
            return dates
        case .month:
            guard let range = cal.range(of: .day, in: .month, for: now),
                  let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now))
            else { return [] }
            return range.compactMap { cal.date(byAdding: .day, value: $0 - 1, to: monthStart) }
        case .year:
            return [] // PixelGridView handles year internally
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                headerView
                periodPicker

                // Pixel grid
                switch selectedPeriod {
                case .year:
                    PixelGridView(activities: filteredActivities, categories: allCategories)

                case .month:
                    MonthPixelView(
                        dates: gridDates,
                        activities: filteredActivities,
                        categories: allCategories
                    )

                case .week:
                    WeekPixelView(
                        dates: gridDates,
                        activities: filteredActivities,
                        categories: allCategories
                    )
                }

                CategoryLegendView(categories: allCategories, activities: filteredActivities)
                StatsView(categories: allCategories, activities: filteredActivities)
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("A glimpse of")
                .font(.system(size: 16, weight: .regular))
            Text("INSIGHT")
                .font(.system(size: 28, weight: .black))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Period Picker
    private var periodPicker: some View {
        Picker("Period", selection: $selectedPeriod) {
            ForEach(Period.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }
}
