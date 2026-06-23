//
//  ActivityFormView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//


import SwiftUI
import SwiftData

struct ActivityFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]

    // What date + slot was tapped
    let selectedDate: Date
    let initialSlot: Int

    // If editing an existing activity, pass it in
    var existingActivity: Activity? = nil

    // Form state
    @State private var selectedCategory: Category? = nil
    @State private var selectedSubCategory: SubCategory? = nil
    @State private var detail: String = ""
    @State private var startSlot: Int = 0
    @State private var durationSlots: Int = 1

    @State private var showDeleteConfirm = false
    @State private var showOverlapWarning = false
    
    @State private var showCategoryPicker = false
    @State private var showSubCategoryPicker = false

    @Query private var allActivities: [Activity]

    var body: some View {
        NavigationStack {
            Form {
                // Time
                Section("Time") {
                    HStack {
                        Text("Start")
                        Spacer()
                        Text(slotToTimeString(startSlot))
                            .foregroundStyle(.secondary)
                    }

                    Stepper(
                        "Duration: \(durationSlots * 30) min",
                        value: $durationSlots,
                        in: 1...16
                    )
                }

                // Category
                Section("Category") {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            if let cat = selectedCategory {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(cat.color)
                                        .frame(width: 26, height: 26)
                                    Image(systemName: cat.iconName)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                Text(cat.name)
                                    .foregroundStyle(.primary)
                            } else {
                                Text("Select category…")
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .sheet(isPresented: $showCategoryPicker) {
                        CategoryPickerSheet(
                            categories: categories,
                            selected: $selectedCategory,
                            onSelect: {
                                // Clear subcategory if category changed
                                selectedSubCategory = nil
                                showCategoryPicker = false
                            }
                        )
                    }

                    if let cat = selectedCategory, !cat.subCategories.isEmpty {
                        Button {
                            showSubCategoryPicker = true
                        } label: {
                            HStack {
                                Text(selectedSubCategory?.name ?? "None")
                                    .foregroundStyle(selectedSubCategory == nil ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .sheet(isPresented: $showSubCategoryPicker) {
                            SubCategoryPickerSheet(
                                subCategories: cat.subCategories,
                                selected: $selectedSubCategory,
                                onSelect: { showSubCategoryPicker = false }
                            )
                        }
                    }
                }

                // Detail
                Section("Activity Detail") {
                    TextField("What did you do?", text: $detail)
                }

                // Delete button (edit mode only)
                if existingActivity != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Activity")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(existingActivity == nil ? "Add Activity" : "Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { attemptSave() }
                        .disabled(detail.trimmingCharacters(in: .whitespaces).isEmpty || selectedCategory == nil)
                }
            }
            .alert("Overlap Detected", isPresented: $showOverlapWarning) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Another activity already occupies one of those slots. Please adjust the start time or duration.")
            }
            .confirmationDialog("Delete this activity?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) { deleteActivity() }
                Button("Cancel", role: .cancel) {}
            }
        }
        .onAppear { prefillForm() }
    }

    // MARK: - Logic

    private func prefillForm() {
        if let activity = existingActivity {
            // Editing — fill from existing
            startSlot = activity.startSlot
            durationSlots = activity.durationSlots
            detail = activity.detail
            selectedCategory = activity.category
            selectedSubCategory = activity.subCategory
        } else {
            // New — use tapped slot
            startSlot = initialSlot
        }
    }

    private func attemptSave() {
        guard let category = selectedCategory else { return }

        // Check for overlaps (exclude self if editing)
        let slotsToOccupy = startSlot..<(startSlot + durationSlots)
        let conflict = allActivities.first { other in
            guard Calendar.current.isDate(other.date, inSameDayAs: selectedDate) else { return false }
            if let existing = existingActivity, other.id == existing.id { return false }
            let otherSlots = other.startSlot..<(other.startSlot + other.durationSlots)
            return slotsToOccupy.overlaps(otherSlots)
        }

        if conflict != nil {
            showOverlapWarning = true
            return
        }

        if let activity = existingActivity {
            // Update existing
            activity.startSlot = startSlot
            activity.durationSlots = durationSlots
            activity.detail = detail
            activity.category = category
            activity.subCategory = selectedSubCategory
            activity.updatedAt = Date()
        } else {
            // Create new
            let activity = Activity(
                date: selectedDate,
                startSlot: startSlot,
                durationSlots: durationSlots,
                detail: detail,
                category: category,
                subCategory: selectedSubCategory
            )
            modelContext.insert(activity)
        }

        dismiss()
    }

    private func deleteActivity() {
        if let activity = existingActivity {
            modelContext.delete(activity)
        }
        dismiss()
    }

    private func slotToTimeString(_ slot: Int) -> String {
        let hour = slot / 2
        let minute = slot % 2 == 0 ? "00" : "30"
        return String(format: "%02d:%@", hour, minute)
    }
}

// MARK: - Category picker sheet

private struct CategoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [Category]
    @Binding var selected: Category?
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List(categories) { cat in
                Button {
                    selected = cat
                    onSelect()
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(cat.color)
                                .frame(width: 32, height: 32)
                            Image(systemName: cat.iconName)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        Text(cat.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selected?.id == cat.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint) // 🛠️ FIXED: Swapped to .tint
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Subcategory picker sheet

private struct SubCategoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let subCategories: [SubCategory]
    @Binding var selected: SubCategory?
    let onSelect: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Button {
                    selected = nil
                    onSelect()
                } label: {
                    HStack {
                        Text("None")
                            .foregroundStyle(.secondary)
                        Spacer()
                        if selected == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint) // 🛠️ FIXED: Swapped to .tint
                                .fontWeight(.semibold)
                        }
                    }
                }
                .buttonStyle(.plain)

                ForEach(subCategories) { sub in
                    Button {
                        selected = sub
                        onSelect()
                    } label: {
                        HStack {
                            Text(sub.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selected?.id == sub.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint) // 🛠️ FIXED: Swapped to .tint
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Sub-category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
