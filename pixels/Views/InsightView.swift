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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView
                periodPicker
                PixelGridView(activities: allActivities, categories: allCategories)
                CategoryLegendView(categories: allCategories, activities: allActivities)
                StatsView(categories: allCategories, activities: allActivities)
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

    // MARK: - Placeholders (we'll replace these one by one)
    private var placeholderPixelGrid: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 200)
            .overlay(Text("Pixel Grid").foregroundStyle(.secondary))
            .padding(.horizontal, 16)
    }

    private var placeholderLegend: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 44)
            .overlay(Text("Legend").foregroundStyle(.secondary))
            .padding(.horizontal, 16)
    }

    private var placeholderStats: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
            .frame(height: 120)
            .overlay(Text("Stats").foregroundStyle(.secondary))
            .padding(.horizontal, 16)
    }
}
