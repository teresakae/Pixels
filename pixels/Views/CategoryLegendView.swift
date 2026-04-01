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

    // Only show categories that have at least 1 activity
    private var activeCategories: [Category] {
        categories.filter { cat in
            activities.contains { $0.category?.id == cat.id }
        }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(activeCategories) { cat in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(cat.color)
                            .frame(width: 10, height: 10)
                        Text(cat.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(cat.color.opacity(0.15))
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
