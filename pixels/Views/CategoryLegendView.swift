//
//  CategoryLegendView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct CategoryLegendView: View {
    let categories: [Category]
    let activities: [Activity]

    private var activeCategories: [Category] {
        categories.filter { cat in
            activities.contains { $0.category?.id == cat.id }
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(activeCategories) { cat in
                    let appearance = Color.pixels.appearance(for: cat.name)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(appearance.border)
                            .frame(width: 8, height: 8)
                        Text(cat.name)
                            .font(.pixels.caption)
                            .foregroundStyle(Color.pixels.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(Color.pixels.surface)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.pixels.borderSurface, lineWidth: PixelsLayout.BorderWidth.default)
                            )
                    )
                }
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
        }
    }
}
