//
//  CategoryDetailView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let category: Category

    @State private var showEditCategory = false
    @State private var showAddSubcategory = false
    @State private var editingSubcategory: SubCategory? = nil
    @State private var subcategoryToDelete: SubCategory? = nil
    @State private var showDeleteAlert = false

    private var sortedSubcategories: [SubCategory] {
        category.subCategories.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            // Category preview
            Section {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(category.color)
                            .frame(width: 40, height: 40)
                            .shadow(color: category.color.opacity(0.3), radius: 4, y: 2)
                        Image(systemName: category.iconName)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.name)
                            .font(.body.weight(.semibold))
                        Text(category.isDefault ? "Default category" : "Custom category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Edit") {
                        showEditCategory = true
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }

            // Subcategories
            Section {
                if sortedSubcategories.isEmpty {
                    Text("No subcategories yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(sortedSubcategories) { sub in
                        HStack {
                            Text(sub.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingSubcategory = sub
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                subcategoryToDelete = sub
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text("Subcategories")
            } footer: {
                if !sortedSubcategories.isEmpty {
                    Text("Activities using a deleted subcategory will have it cleared.")
                        .font(.caption)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSubcategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showEditCategory) {
            CategoryEditView(category: category)
        }
        .sheet(isPresented: $showAddSubcategory) {
            SubcategoryEditView(category: category, subcategory: nil)
        }
        .sheet(item: $editingSubcategory) { sub in
            SubcategoryEditView(category: category, subcategory: sub)
        }
        .alert(
            "Delete \"\(subcategoryToDelete?.name ?? "")\"?",
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                if let sub = subcategoryToDelete {
                    deleteSubcategory(sub)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Activities using this subcategory will have it cleared.")
        }
    }

    private func deleteSubcategory(_ sub: SubCategory) {
        modelContext.delete(sub)
        try? modelContext.save()
    }
}
