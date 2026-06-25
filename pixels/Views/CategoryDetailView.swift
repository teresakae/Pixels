//
//  CategoryDetailView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let category: Category

    @State private var editingSubID: UUID? = nil
    @State private var editingName: String = ""
    @State private var showingAddRow = false
    @State private var newSubName = ""
    @State private var subcategoryToDelete: SubCategory? = nil
    @State private var showDeleteSubAlert = false
    @State private var showDeleteCategoryAlert = false

    @FocusState private var editFocused: Bool
    @FocusState private var addFocused: Bool

    private var sortedSubcategories: [SubCategory] {
        category.subCategories.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            List {
                editCategorySection
                subcategoriesSection
                deleteCategorySection
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.pixels.background)
        }
        .background(Color.pixels.background)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "Delete \"\(subcategoryToDelete?.name ?? "")\"?",
            isPresented: $showDeleteSubAlert
        ) {
            Button("Delete", role: .destructive) {
                if let sub = subcategoryToDelete { deleteSubcategory(sub) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Activities using this subcategory will have it cleared.")
        }
        .alert(
            "Delete \"\(category.name)\"?",
            isPresented: $showDeleteCategoryAlert
        ) {
            Button("Delete", role: .destructive) { deleteCategory() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All activities in this category will be uncategorised.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .regular))
                    Text("Settings")
                        .pixelsEyebrow()
                }
                .foregroundStyle(Color.pixels.textTertiary)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, PixelsLayout.Spacing.margin)
            .padding(.top, 16)
            .padding(.bottom, 12)

            PixelsDivider()

            HStack(spacing: 12) {
                let appearance = Color.pixels.appearance(for: category.name)
                ZStack {
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                        .fill(appearance.fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                                .strokeBorder(appearance.border, lineWidth: PixelsLayout.BorderWidth.default)
                        )
                    Image(systemName: category.iconName)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(appearance.border)
                }
                .frame(width: 36, height: 36)

                Text(category.name)
                    .font(.pixels.title)
                    .foregroundStyle(Color.pixels.textPrimary)
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
            .padding(.vertical, 16)

            PixelsDivider()
        }
    }

    // MARK: - Edit category section

    private var editCategorySection: some View {
        Section {
            NavigationLink(destination: CategoryEditView(category: category)) {
                HStack(spacing: 10) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.pixels.textTertiary)
                    Text("Edit name, colour & icon")
                        .font(.pixels.body)
                        .foregroundStyle(Color.pixels.textPrimary)
                }
            }
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Subcategories section

    private var subcategoriesSection: some View {
        Section {
            ForEach(sortedSubcategories) { sub in
                subcategoryRow(sub)
                    .listRowBackground(Color.pixels.surface)
                    .listRowSeparatorTint(Color.pixels.borderDefault)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            subcategoryToDelete = sub
                            showDeleteSubAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(Color.pixels.accentDark)
                    }
            }

            addSubcategoryRow
        } header: {
            Text("Subcategories").pixelsEyebrow().textCase(nil)
        }
    }

    @ViewBuilder
    private func subcategoryRow(_ sub: SubCategory) -> some View {
        if editingSubID == sub.id {
            HStack(spacing: 10) {
                TextField("Name", text: $editingName)
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)
                    .tint(Color.pixels.accent)
                    .focused($editFocused)
                    .onAppear { editFocused = true }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scrollerSelected)
                            .strokeBorder(Color.pixels.accent, lineWidth: 1.5)
                    )

                Button { commitEdit(sub) } label: {
                    Text("Done")
                        .font(.pixels.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pixels.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.pixels.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        } else {
            HStack {
                Text(sub.name)
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)
                Spacer()
                Image(systemName: "pencil")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.pixels.textTertiary.opacity(0.4))
            }
            .contentShape(Rectangle())
            .onTapGesture { startEditing(sub) }
        }
    }

    @ViewBuilder
    private var addSubcategoryRow: some View {
        if showingAddRow {
            HStack(spacing: 10) {
                TextField("Subcategory name", text: $newSubName)
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)
                    .tint(Color.pixels.accent)
                    .focused($addFocused)
                    .onAppear { addFocused = true }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scrollerSelected)
                            .strokeBorder(Color.pixels.accent, lineWidth: 1.5)
                    )

                Button { commitAddSub() } label: {
                    Text("Done")
                        .font(.pixels.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.pixels.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.pixels.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        } else {
            Button {
                editingSubID = nil
                showingAddRow = true
                newSubName = ""
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.pixels.textTertiary)
                    Text("Add subcategory")
                        .font(.pixels.body)
                        .foregroundStyle(Color.pixels.textTertiary)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Delete category section

    private var deleteCategorySection: some View {
        Section {
            Button {
                showDeleteCategoryAlert = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                    Text("Delete category")
                        .font(.pixels.body)
                }
                .foregroundStyle(Color.pixels.accentDark)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.pixels.surface)
            .listRowSeparator(.hidden)
        }
    }

    // MARK: - Logic

    private func startEditing(_ sub: SubCategory) {
        showingAddRow = false
        editingSubID = sub.id
        editingName = sub.name
    }

    private func commitEdit(_ sub: SubCategory) {
        let trimmed = editingName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            sub.name = trimmed
            try? modelContext.save()
        }
        editingSubID = nil
        editingName = ""
    }

    private func commitAddSub() {
        let trimmed = newSubName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            let sub = SubCategory(name: trimmed, category: category)
            modelContext.insert(sub)
            try? modelContext.save()
        }
        showingAddRow = false
        newSubName = ""
    }

    private func deleteSubcategory(_ sub: SubCategory) {
        modelContext.delete(sub)
        try? modelContext.save()
    }

    private func deleteCategory() {
        modelContext.delete(category)
        try? modelContext.save()
        dismiss()
    }
}
