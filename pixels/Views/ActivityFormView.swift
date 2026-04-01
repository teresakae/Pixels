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
                    Picker("Main Category", selection: $selectedCategory) {
                        Text("Select…").tag(Optional<Category>(nil))
                        ForEach(categories) { cat in
                            HStack {
                                Circle()
                                    .fill(cat.color)
                                    .frame(width: 12, height: 12)
                                Text(cat.name)
                            }
                            .tag(Optional(cat))
                        }
                    }

                    if let cat = selectedCategory, !cat.subCategories.isEmpty {
                        Picker("Sub Category", selection: $selectedSubCategory) {
                            Text("None").tag(Optional<SubCategory>(nil))
                            ForEach(cat.subCategories) { sub in
                                Text(sub.name).tag(Optional(sub))
                            }
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
