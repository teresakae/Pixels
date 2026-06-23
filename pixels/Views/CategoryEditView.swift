//
//  CategoryEditView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct CategoryEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allCategories: [Category]

    // nil = new category
    let category: Category?

    @State private var name: String = ""
    @State private var selectedColor: Color = .blue
    @State private var showDuplicateAlert = false
    @State private var selectedIconName: String = "square.grid.2x2"
    @State private var showSymbolPicker = false

    private var isEditing: Bool { category != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedColor)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: selectedColor.opacity(0.4), radius: 8, y: 4)
                                Image(systemName: selectedIconName)
                                    .font(.title2)
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            
                            Text(name.isEmpty ? "Category Name" : name)
                                .font(.subheadline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }

                Section("Details") {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()

                    ColorPicker("Colour", selection: $selectedColor, supportsOpacity: false)
                    
                    // INTEGRATED: The Icon picker button
                    Button {
                        showSymbolPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: selectedIconName)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .sheet(isPresented: $showSymbolPicker) {
                        SymbolPickerView(selected: $selectedIconName)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
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
                Text("A category named \"\(name)\" already exists. Choose a different name.")
            }
            .onAppear { populate() }
        }
    }

    // MARK: - Helpers

    // INTEGRATED: Updated populate method
    private func populate() {
        if let cat = category {
            name = cat.name
            selectedColor = Color(hex: cat.colorHex) ?? .blue
            selectedIconName = cat.iconName
        }
    }

    private func save() {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return }

            let duplicate = allCategories.contains {
                $0.name.lowercased() == trimmed.lowercased() && $0.id != category?.id
            }
            if duplicate {
                showDuplicateAlert = true
                return
            }

            let hex = selectedColor.toHex() ?? "#888888"

            if let cat = category {
                cat.name = trimmed
                cat.colorHex = hex
                cat.iconName = selectedIconName
            } else {
                let newCat = Category(name: trimmed, colorHex: hex, iconName: selectedIconName, isDefault: false)
                modelContext.insert(newCat)
            }

            try? modelContext.save()
            dismiss()
        }
}
