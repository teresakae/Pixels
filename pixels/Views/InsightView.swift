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
            return []
        }
    }

    // MARK: - Dynamic header strings
    private var eyebrowText: String {
        let cal = Calendar.current
        switch selectedPeriod {
        case .week:  return "This week"
        case .month: return "This month"
        case .year:  return "\(cal.component(.year, from: Date()))"
        }
    }

    private var titleText: String {
        switch selectedPeriod {
        case .week:  return "Your week, in colour."
        case .month: return "Your month, in colour."
        case .year:  return "Your year, in colour."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pixels.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerView
                            .padding(.horizontal, PixelsLayout.Spacing.margin)
                            .padding(.top, 12)
                            .padding(.bottom, 16)

                        PixelsDivider()

                        periodSwitcher
                            .padding(.horizontal, PixelsLayout.Spacing.margin)
                            .padding(.vertical, 16)

                        PixelsDivider()

                        Group {
                            switch selectedPeriod {
                            case .year:
                                PixelGridView(
                                    activities: filteredActivities,
                                    categories: allCategories,
                                    onDayTap: { _ in }
                                )
                            case .month:
                                MonthPixelView(
                                    dates: gridDates,
                                    activities: filteredActivities,
                                    categories: allCategories,
                                    onDayTap: { _ in }
                                )
                            case .week:
                                WeekPixelView(
                                    dates: gridDates,
                                    activities: filteredActivities,
                                    categories: allCategories,
                                    onDayTap: { _ in }
                                )
                            }
                        }
                        .padding(.top, 16)

                        CategoryLegendView(categories: allCategories, activities: filteredActivities)
                            .padding(.top, 20)

                        StatsView(categories: allCategories, activities: filteredActivities)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 100)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrowText)
                .pixelsEyebrow()
            Text(titleText)
                .font(.pixels.header)
                .foregroundStyle(Color.pixels.textPrimary)
        }
    }

    // MARK: - Custom period switcher
    private var periodSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(.pixels.eyebrow)
                        .foregroundStyle(
                            selectedPeriod == period
                                ? Color.pixels.textPrimary
                                : Color.pixels.textTertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.pill)
                                .fill(selectedPeriod == period ? Color.pixels.accent : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.pill)
                .fill(Color.pixels.surface)
        )
    }
}
