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

    private var slotsByCategory: [(Category, Int)] {
        categories.compactMap { cat in
            let total = activities
                .filter { $0.category?.id == cat.id }
                .reduce(0) { $0 + $1.durationSlots }
            return total > 0 ? (cat, total) : nil
        }
        .sorted { $0.1 > $1.1 }
    }

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
            statBlock(
                title: "Time",
                items: slotsByCategory.map { cat, slots in
                    let h = slots / 2
                    let label = slots % 2 == 0 ? "\(h)h" : "\(h)h 30m"
                    return (cat, slots, label)
                },
                total: totalSlots
            )

            PixelsDivider()

            statBlock(
                title: "Frequency",
                items: countByCategory.map { cat, count in
                    (cat, count, "\(count)×")
                },
                total: totalCount
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
                .fill(Color.pixels.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
                        .strokeBorder(Color.pixels.borderSurface, lineWidth: PixelsLayout.BorderWidth.default)
                )
        )
        .padding(.horizontal, PixelsLayout.Spacing.margin)
    }

    private func statBlock(
        title: String,
        items: [(Category, Int, String)],
        total: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .pixelsEyebrow()

            if total > 0 {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(items, id: \.0.id) { cat, value, _ in
                            let appearance = Color.pixels.appearance(for: cat.name)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(appearance.fill)
                                .frame(width: geo.size.width * CGFloat(value) / CGFloat(total))
                        }
                    }
                }
                .frame(height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.0.id) { cat, _, label in
                    let appearance = Color.pixels.appearance(for: cat.name)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(appearance.border)
                            .frame(width: 8, height: 8)
                        Text(cat.name)
                            .font(.pixels.caption)
                            .foregroundStyle(Color.pixels.textSecondary)
                        Spacer()
                        Text(label)
                            .font(.pixels.caption)
                            .foregroundStyle(Color.pixels.textTertiary)
                    }
                }
            }
        }
    }
}
