//
//  ContentView.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var selectedTab = 0

    init() {
        // Fully suppress the system UITabBar — kills its shadow line too
        UITabBar.appearance().isHidden = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(0)

                InsightView()
                    .tag(1)

                CategoriesView()
                    .tag(2)

                SettingsView()
                    .tag(3)
            }
            .toolbar(.hidden, for: .tabBar)

            FloatingTabBar(selectedTab: $selectedTab)
                .padding(.bottom, 24)
        }
        .onAppear {
            seedCategoriesIfNeeded()
        }
    }

    private func seedCategoriesIfNeeded() {
        guard categories.isEmpty else { return }

        let defaults: [(name: String, hex: String, icon: String)] = [
            ("Work",     "#5CC2C6", "briefcase"),
            ("Personal", "#FFACAB", "person"),
            ("Health",   "#A1E0DD", "heart"),
            ("Social",   "#FA85B9", "bubble.left.and.bubble.right"),
            ("Learning", "#88AED2", "book"),
            ("Rest",     "#FFDBBA", "moon"),
            ("Food",     "#FF8894", "fork.knife"),
            ("Other",    "#D2D8D9", "square.grid.2x2")
        ]

        for item in defaults {
            let category = Category(
                name: item.name,
                colorHex: item.hex,
                iconName: item.icon,
                isDefault: true
            )
            modelContext.insert(category)
        }

        try? modelContext.save()
    }
}

// MARK: - Floating Tab Bar

private struct TabItem {
    let icon: String
    let label: String
    let tag: Int
}

private let tabItems: [TabItem] = [
    TabItem(icon: "square.grid.2x2", label: "Today",      tag: 0),
    TabItem(icon: "chart.bar.xaxis", label: "Insight",    tag: 1),
    TabItem(icon: "folder",          label: "Categories", tag: 2),
    TabItem(icon: "gearshape",       label: "Settings",   tag: 3),
]

struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.tag) { item in
                Button {
                    selectedTab = item.tag
                } label: {
                    let isActive = selectedTab == item.tag
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 18, weight: isActive ? .semibold : .regular))
                            .foregroundStyle(isActive ? Color.pixels.tabBarActive : Color.pixels.tabBarInactive)
                        Text(item.label)
                            .font(.pixels.caption)
                            .foregroundStyle(isActive ? Color.pixels.tabBarActive : Color.pixels.tabBarInactive)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .animation(.easeInOut(duration: 0.15), value: isActive)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .glassEffect(.regular.tint(Color.pixels.tabBarBackground.opacity(0.4)), in: .capsule)
        .padding(.horizontal, PixelsLayout.Spacing.margin)
    }
}
