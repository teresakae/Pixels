//
//  CategoriesView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.createdAt) private var categories: [Category]

    @State private var showAddSheet = false
    @State private var categoryToDelete: Category? = nil
    @State private var showDeleteAlert = false
    @State private var orderedIDs: [UUID] = []

    private var ordered: [Category] {
        let idOrder = orderedIDs
        if idOrder.isEmpty { return categories }
        let map = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        var result = idOrder.compactMap { map[$0] }
        let known = Set(idOrder)
        result += categories.filter { !known.contains($0.id) }
        return result
    }

    var body: some View {
        List {
            ForEach(ordered) { category in
                NavigationLink(destination: CategoryDetailView(category: category)) {
                    CategoryRow(category: category)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        categoryToDelete = category
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onMove(perform: move)
        }
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .onAppear { loadOrder() }
        .sheet(isPresented: $showAddSheet) {
            CategoryEditView(category: nil)
        }
        .alert(
            "Delete \"\(categoryToDelete?.name ?? "")\"?",
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                if let cat = categoryToDelete {
                    deleteCategory(cat)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Activities using this category will have their category cleared.")
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        var ids = ordered.map(\.id)
        ids.move(fromOffsets: source, toOffset: destination)
        orderedIDs = ids
        saveOrder(ids)
    }

    private func saveOrder(_ ids: [UUID]) {
        let strings = ids.map(\.uuidString)
        UserDefaults.standard.set(strings, forKey: "categoryOrder")
    }

    private func loadOrder() {
        let strings = UserDefaults.standard.stringArray(forKey: "categoryOrder") ?? []
        orderedIDs = strings.compactMap { UUID(uuidString: $0) }
    }

    private func deleteCategory(_ category: Category) {
        orderedIDs.removeAll { $0 == category.id }
        saveOrder(orderedIDs)
        modelContext.delete(category)
        try? modelContext.save()
    }
}

// MARK: - Row
private struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: category.colorHex) ?? .gray)
                    .frame(width: 32, height: 32)
                Image(systemName: category.iconName)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Text(category.name)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}
