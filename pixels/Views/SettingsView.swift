//
//  SettingsView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [Category]
    @AppStorage("iCloudEnabled") private var iCloudEnabled = false
    @AppStorage("categoryOrder") private var categoryOrderData: Data = Data()

    @State private var displayedCategories: [Category] = []
    @State private var showAddCategory = false
    @State private var categoryToDelete: Category? = nil
    @State private var showDeleteCategoryAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {
                categoriesSection
                iCloudSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.pixels.background)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.pixels.body)
                        .foregroundStyle(Color.pixels.textSecondary)
                }
            }
        }
        .sheet(isPresented: $showAddCategory, onDismiss: refreshOrder) {
            CategoryEditView(category: nil)
        }
        .onAppear { refreshOrder() }
        .onChange(of: allCategories) { _, _ in refreshOrder() }
        .alert(
            "Delete \"\(categoryToDelete?.name ?? "")\"?",
            isPresented: $showDeleteCategoryAlert
        ) {
            Button("Delete", role: .destructive) {
                if let cat = categoryToDelete { deleteCategory(cat) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All activities in this category will be uncategorised.")
        }
    }

    // MARK: - Sections

    private var categoriesSection: some View {
        Section {
            ForEach(displayedCategories) { cat in
                NavigationLink(destination: CategoryDetailView(category: cat)) {
                    categoryRow(cat)
                }
                .listRowBackground(Color.pixels.surface)
                .listRowSeparatorTint(Color.pixels.borderDefault)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        categoryToDelete = cat
                        showDeleteCategoryAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(Color.pixels.accentDark)
                }
            }
            .onMove { source, destination in
                displayedCategories.move(fromOffsets: source, toOffset: destination)
                persistOrder()
            }

            Button { showAddCategory = true } label: {
                addCategoryRow
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        } header: {
            Text("Categories").pixelsEyebrow().textCase(nil)
        }
    }

    private var iCloudSection: some View {
        Section {
            HStack(spacing: 12) {
                iconTile(systemName: "icloud", background: Color.pixels.surface, foreground: Color.pixels.textSecondary, border: Color.pixels.borderSurface)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sync across devices")
                        .font(.pixels.body)
                        .foregroundStyle(Color.pixels.textPrimary)
                    Text("Uses your Apple ID")
                        .font(.pixels.caption)
                        .foregroundStyle(Color.pixels.textTertiary)
                }

                Spacer()

                Toggle("", isOn: $iCloudEnabled)
                    .tint(Color.pixels.accent)
                    .labelsHidden()
            }
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        } header: {
            Text("iCloud").pixelsEyebrow().textCase(nil)
        }
    }

    private var aboutSection: some View {
        Section {
            HStack(spacing: 12) {
                iconTile(systemName: "square.grid.2x2", background: Color.pixels.accent, foreground: Color.pixels.textPrimary, border: Color.clear)

                Text("Pixels")
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)

                Spacer()

                Text(appVersion)
                    .font(.pixels.caption)
                    .foregroundStyle(Color.pixels.textTertiary)
            }
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        } header: {
            Text("About").pixelsEyebrow().textCase(nil)
        }
    }

    // MARK: - Row helpers

    private func categoryRow(_ cat: Category) -> some View {
        HStack(spacing: 12) {
            let appearance = Color.pixels.appearance(for: cat.name)
            ZStack {
                RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                    .fill(appearance.border)
                    .overlay(
                        RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                            .strokeBorder(appearance.border, lineWidth: PixelsLayout.BorderWidth.default)
                    )
                Image(systemName: cat.iconName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.pixels.background)
            }
            .frame(width: 28, height: 28)

            Text(cat.name)
                .font(.pixels.body)
                .foregroundStyle(Color.pixels.textPrimary)

            Spacer()

            let count = cat.subCategories.count
            Text(count > 0 ? "\(count) sub" : "—")
                .font(.pixels.caption)
                .foregroundStyle(Color.pixels.textTertiary)
        }
    }

    private var addCategoryRow: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                    .strokeBorder(
                        Color.pixels.borderEmpty,
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.pixels.textTertiary)
            }
            .frame(width: 28, height: 28)

            Text("New category")
                .font(.pixels.body)
                .foregroundStyle(Color.pixels.textTertiary)

            Spacer()
        }
    }

    private func iconTile(systemName: String, background: Color, foreground: Color, border: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                .fill(background)
                .overlay(
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                        .strokeBorder(border, lineWidth: PixelsLayout.BorderWidth.default)
                )
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(foreground)
        }
        .frame(width: 28, height: 28)
    }

    // MARK: - Delete

    private func deleteCategory(_ cat: Category) {
        modelContext.delete(cat)
        try? modelContext.save()
        displayedCategories.removeAll { $0.id == cat.id }
        persistOrder()
    }

    // MARK: - Order persistence

    private func refreshOrder() {
        let savedIDs: [UUID]
        if let decoded = try? JSONDecoder().decode([UUID].self, from: categoryOrderData) {
            savedIDs = decoded
        } else {
            savedIDs = []
        }

        let idMap = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })

        if savedIDs.isEmpty {
            displayedCategories = allCategories.sorted { $0.createdAt < $1.createdAt }
        } else {
            var ordered = savedIDs.compactMap { idMap[$0] }
            let newOnes = allCategories
                .filter { !savedIDs.contains($0.id) }
                .sorted { $0.createdAt < $1.createdAt }
            ordered.append(contentsOf: newOnes)
            displayedCategories = ordered
        }
    }

    private func persistOrder() {
        if let encoded = try? JSONEncoder().encode(displayedCategories.map { $0.id }) {
            categoryOrderData = encoded
        }
    }
}
