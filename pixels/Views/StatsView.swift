//
//  StatsView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct StatsView: View {
    let categories: [Category]
    let activities: [Activity]

    // Total slots per category
    private var slotsByCategory: [(Category, Int)] {
        categories.compactMap { cat in
            let total = activities
                .filter { $0.category?.id == cat.id }
                .reduce(0) { $0 + $1.durationSlots }
            return total > 0 ? (cat, total) : nil
        }
        .sorted { $0.1 > $1.1 }
    }

    // Number of activities per category
    private var countByCategory: [(Category, Int)] {
        categories.compactMap { cat in
            let count = activities.filter { $0.category?.id == cat.id }.count
            return count > 0 ? (cat, count) : nil
        }
        .sorted { $0.1 > $1.1 }
    }

    private var totalSlots: Int { slotsByCategory.reduce(0) { $0 + $1.1 } }
    private var totalCount: Int { countByCategory.reduce(0) { $0 + $1.1 } }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Time breakdown
            statBlock(
                title: "Time",
                items: slotsByCategory.map { (cat, slots) in
                    (cat, slots, "\(slots / 2)h \(slots % 2 == 0 ? "" : "30m")")
                },
                total: totalSlots
            )

            Divider()

            // Frequency breakdown
            statBlock(
                title: "Frequency",
                items: countByCategory.map { (cat, count) in
                    (cat, count, "\(count)×")
                },
                total: totalCount
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Reusable stat block
    private func statBlock(
        title: String,
        items: [(Category, Int, String)],
        total: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .kerning(0.5)

            // Stacked bar
            if total > 0 {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(items, id: \.0.id) { cat, value, _ in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(cat.color)
                                .frame(width: geo.size.width * CGFloat(value) / CGFloat(total))
                        }
                    }
                }
                .frame(height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }

            // Labels
            VStack(alignment: .leading, spacing: 4) {
                ForEach(items, id: \.0.id) { cat, _, label in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(cat.color)
                            .frame(width: 8, height: 8)
                        Text(cat.name)
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                        Text(label)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
