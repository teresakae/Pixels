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

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            InsightView()
                .tabItem {
                    Label("Insight", systemImage: "chart.bar")
                }
        }
        .onAppear {
            seedCategoriesIfNeeded()
        }
    }

    private func seedCategoriesIfNeeded() {
        // Only seed if no categories exist yet
        guard categories.isEmpty else { return }

        let defaults: [(String, String)] = [
            ("Work",     "#5CC2C6"),
            ("Personal", "#FFACAB"),
            ("Health",   "#A1E0DD"),
            ("Social",   "#FA85B9"),
            ("Learning", "#88AED2"),
            ("Rest",     "#FFDBBA"),
            ("Food",     "#FF8894"),
            ("Other",    "#D2D8D9")
        ]

        for (name, hex) in defaults {
            let cat = Category(name: name, colorHex: hex, isDefault: true)
            modelContext.insert(cat)
        }
    }
}
