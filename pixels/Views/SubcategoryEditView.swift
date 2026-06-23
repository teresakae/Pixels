//
//  SubcategoryEditView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct SubcategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let category: Category
    let subcategory: SubCategory?

    @State private var name: String = ""
    @State private var showDuplicateAlert = false

    private var isEditing: Bool { subcategory != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Subcategory name", text: $name)
                        .autocorrectionDisabled()
                }
            }
            .navigationTitle(isEditing ? "Edit Subcategory" : "New Subcategory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .alert("Name already used", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A subcategory named \"\(name)\" already exists in this category.")
            }
            .onAppear {
                if let sub = subcategory {
                    name = sub.name
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let duplicate = category.subCategories.contains {
            $0.name.lowercased() == trimmed.lowercased() && $0.id != subcategory?.id
        }
        if duplicate {
            showDuplicateAlert = true
            return
        }

        if let sub = subcategory {
            sub.name = trimmed
        } else {
            let newSub = SubCategory(name: trimmed, category: category)
            modelContext.insert(newSub)
        }

        try? modelContext.save()
        dismiss()
    }
}
