//
//  ActivityFormView.swift
//  pixels
//

import SwiftUI
import SwiftData

struct ActivityFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var categories: [Category]
    @Query private var allActivities: [Activity]

    let selectedDate: Date
    let initialSlot: Int
    var existingActivity: Activity? = nil

    @State private var selectedCategory: Category? = nil
    @State private var selectedSubCategory: SubCategory? = nil
    @State private var activityName: String = ""
    @State private var activityNotes: String = ""
    @State private var startSlot: Int = 0
    @State private var durationSlots: Int = 2

    @State private var showSubcategories = false
    @State private var showOverlapWarning = false
    @State private var showDeleteConfirm = false
    @FocusState private var nameFocused: Bool

    private let durationOptions: [(label: String, slots: Int)] = [
        ("30m", 1), ("1h", 2), ("1h 30m", 3), ("2h", 4),
        ("2h 30m", 5), ("3h", 6), ("3h 30m", 7), ("4h", 8),
        ("4h 30m", 9), ("5h", 10), ("5h 30m", 11), ("6h", 12),
        ("6h 30m", 13), ("7h", 14), ("7h 30m", 15), ("8h", 16),
    ]

    private let categoryOrder = ["Health", "Learning", "Food", "Work", "Social", "Rest", "Personal", "Other"]

    private var orderedCategories: [Category] {
        categoryOrder.compactMap { name in categories.first { $0.name == name } }
    }

    private var headerTitle: String {
        let trimmed = activityName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { return trimmed }
        return existingActivity == nil ? "Add Activity" : "Edit Activity"
    }

    private var canSave: Bool {
        selectedCategory != nil && !activityName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerBar
                PixelsDivider()
                timeSection
                PixelsDivider()
                durationSection
                PixelsDivider()
                categorySection
                PixelsDivider()
                subcategorySection
                PixelsDivider()
                detailSection

                if existingActivity != nil {
                    deleteButton
                }
            }
        }
        .background(Color.pixels.background)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.pixels.background)
        .alert("Overlap Detected", isPresented: $showOverlapWarning) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Another activity already occupies those slots. Adjust the duration.")
        }
        .confirmationDialog("Delete this activity?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteActivity() }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            prefillForm()
            if existingActivity == nil { nameFocused = true }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            Text(headerTitle)
                .font(.pixels.blockTitle)
                .foregroundStyle(Color.pixels.textPrimary)
                .lineLimit(1)
                .padding(.horizontal, 100)

            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .regular))
                        Text("Back")
                            .font(.pixels.body)
                    }
                    .foregroundStyle(Color.pixels.textSecondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button { attemptSave() } label: {
                    Text("Save")
                        .font(.pixels.blockTitle)
                        .foregroundStyle(Color.pixels.textPrimary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(Color.pixels.accent))
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.45)
            }
        }
        .padding(.horizontal, PixelsLayout.Spacing.margin)
        .padding(.vertical, 16)
    }

    // MARK: - Time section
    // START is a wheel picker; END and DURATION are derived read-only.

    private var timeSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("START").pixelsEyebrow()
                Picker("", selection: $startSlot) {
                    ForEach(0..<48, id: \.self) { slot in
                        Text(slotToTimeString(slot))
                            .font(.pixels.timeDisplay)
                            .tag(slot)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 110)
                .clipped()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color.pixels.borderDefault)
                .frame(width: PixelsLayout.BorderWidth.default, height: 80)

            timeColumn(label: "END",      value: slotToTimeString(startSlot + durationSlots))
            Rectangle()
                .fill(Color.pixels.borderDefault)
                .frame(width: PixelsLayout.BorderWidth.default, height: 80)
            timeColumn(label: "DURATION", value: durationLabel(durationSlots))
        }
        .padding(.horizontal, PixelsLayout.Spacing.margin)
        .padding(.vertical, 12)
    }

    private func timeColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).pixelsEyebrow()
            Text(value)
                .font(.pixels.timeDisplay)
                .foregroundStyle(Color.pixels.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
    }

    // MARK: - Duration drum roll
    // Fixed center highlight stays still; options scroll behind it.
    // Tapping any item scrolls it to center and selects it.

    private var durationSection: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let itemWidth: CGFloat = 76
                let sidePad = (geo.size.width - itemWidth) / 2

                ZStack {
                    // Fixed selection indicator — does not move
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scrollerSelected)
                        .fill(Color.pixels.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scrollerSelected)
                                .strokeBorder(Color.pixels.borderStrong, lineWidth: PixelsLayout.BorderWidth.default)
                        )
                        .frame(width: itemWidth, height: 44)
                        .shadow(color: Color.pixels.textPrimary.opacity(0.06), radius: 4, x: 0, y: 2)

                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                Color.clear.frame(width: sidePad, height: 44)
                                ForEach(durationOptions, id: \.slots) { option in
                                    let isSelected = durationSlots == option.slots
                                    let distance   = abs(durationSlots - option.slots)
                                    Text(option.label)
                                        .font(isSelected ? .pixels.blockTitle : .pixels.body)
                                        .foregroundStyle(
                                            isSelected    ? Color.pixels.textPrimary   :
                                            distance == 1 ? Color.pixels.textSecondary :
                                                            Color.pixels.textTertiary
                                        )
                                        .frame(width: itemWidth, height: 44)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                durationSlots = option.slots
                                            }
                                        }
                                        .id(option.slots)
                                }
                                Color.clear.frame(width: sidePad, height: 44)
                            }
                        }
                        .onChange(of: durationSlots) { _, slots in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                proxy.scrollTo(slots, anchor: .center)
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(durationSlots, anchor: .center)
                        }
                    }
                }
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scroller)
                        .fill(Color.pixels.surface)
                )
                .clipShape(RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.scroller))
            }
            .frame(height: 60)
            .padding(.horizontal, PixelsLayout.Spacing.margin)
            .padding(.top, 16)

            RoundedRectangle(cornerRadius: 2)
                .fill(Color.pixels.borderSurface)
                .frame(width: 36, height: 4)
                .padding(.top, 10)

            Spacer().frame(height: 16)
        }
    }

    // MARK: - Category grid
    // Unselected: 45% opacity, tertiary label.
    // Selected: full opacity, 2pt border, scale 1.04, primary bold label.

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .pixelsEyebrow()
                .padding(.horizontal, PixelsLayout.Spacing.margin)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 16
            ) {
                ForEach(orderedCategories) { cat in
                    categoryCell(cat)
                }
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
        }
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    private func categoryCell(_ cat: Category) -> some View {
        let appearance = Color.pixels.appearance(for: cat.name)
        let isSelected = selectedCategory?.id == cat.id

        return Button {
            selectedCategory = cat
            selectedSubCategory = nil
            showSubcategories = false
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                        .fill(appearance.fill)
                        .overlay(
                            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                                .strokeBorder(
                                    appearance.border,
                                    lineWidth: isSelected
                                        ? PixelsLayout.BorderWidth.selectedCategory
                                        : PixelsLayout.BorderWidth.default
                                )
                        )

                    Image(systemName: cat.iconName)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(appearance.border)
                }
                .frame(width: PixelsLayout.Size.categoryIcon.width, height: PixelsLayout.Size.categoryIcon.height)
                .opacity(isSelected ? 1.0 : 0.45)
                .scaleEffect(isSelected ? 1.04 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isSelected)

                Text(cat.name)
                    .font(.pixels.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Color.pixels.textPrimary : Color.pixels.textTertiary)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subcategory

    @ViewBuilder
    private var subcategorySection: some View {
        if let cat = selectedCategory, !cat.subCategories.isEmpty {
            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showSubcategories.toggle() }
                } label: {
                    HStack {
                        Text("Subcategory").pixelsEyebrow()
                        Spacer()
                        Text(selectedSubCategory?.name ?? "None")
                            .font(.pixels.body)
                            .foregroundStyle(Color.pixels.textTertiary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(Color.pixels.textTertiary)
                            .rotationEffect(.degrees(showSubcategories ? 90 : 0))
                            .animation(.easeInOut(duration: 0.2), value: showSubcategories)
                    }
                    .padding(.horizontal, PixelsLayout.Spacing.margin)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                if showSubcategories {
                    let appearance = Color.pixels.appearance(for: cat.name)
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(cat.subCategories) { sub in
                            subcategoryPill(sub, appearance: appearance)
                        }
                    }
                    .padding(.horizontal, PixelsLayout.Spacing.margin)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func subcategoryPill(_ sub: SubCategory, appearance: CategoryAppearance) -> some View {
        let isSelected = selectedSubCategory?.id == sub.id
        return Button {
            selectedSubCategory = isSelected ? nil : sub
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(appearance.fill)
                    .frame(width: 8, height: 8)
                Text(sub.name)
                    .font(.pixels.caption)
                    .foregroundStyle(Color.pixels.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.subcategoryPill)
                    .fill(isSelected ? Color.pixels.accent : Color.pixels.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.subcategoryPill)
                            .strokeBorder(
                                isSelected ? Color.pixels.accentDark : Color.pixels.borderSurface,
                                lineWidth: PixelsLayout.BorderWidth.default
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.12), value: isSelected)
    }

    // MARK: - Detail fields

    private var detailSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                Text("What did you do?").pixelsEyebrow()
                TextField("write here...", text: $activityName)
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)
                    .tint(Color.pixels.accent)
                    .focused($nameFocused)
                    .submitLabel(.next)
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
            .padding(.vertical, 16)

            PixelsDivider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Add details").pixelsEyebrow()
                TextField("write here...", text: $activityNotes, axis: .vertical)
                    .font(.pixels.body)
                    .foregroundStyle(Color.pixels.textPrimary)
                    .tint(Color.pixels.accent)
                    .lineLimit(3...)
            }
            .padding(.horizontal, PixelsLayout.Spacing.margin)
            .padding(.vertical, 16)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Delete (edit mode)

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Text("Delete activity")
                .font(.pixels.body)
                .foregroundStyle(Color.pixels.healthBorder)
        }
        .padding(.bottom, 40)
    }

    // MARK: - Logic

    private func prefillForm() {
        if let activity = existingActivity {
            startSlot     = activity.startSlot
            durationSlots = activity.durationSlots
            selectedCategory    = activity.category
            selectedSubCategory = activity.subCategory

            let parts = activity.detail.components(separatedBy: "\n\n")
            activityName  = parts[0]
            activityNotes = parts.count > 1 ? parts.dropFirst().joined(separator: "\n\n") : ""
        } else {
            startSlot     = initialSlot
            durationSlots = 2
        }
    }

    private func combinedDetail() -> String {
        let notes = activityNotes.trimmingCharacters(in: .whitespaces)
        return notes.isEmpty ? activityName : activityName + "\n\n" + notes
    }

    private func attemptSave() {
        guard let category = selectedCategory else { return }

        let slotsToOccupy = startSlot..<(startSlot + durationSlots)
        let conflict = allActivities.first { other in
            guard Calendar.current.isDate(other.date, inSameDayAs: selectedDate) else { return false }
            if let existing = existingActivity, other.id == existing.id { return false }
            let otherSlots = other.startSlot..<(other.startSlot + other.durationSlots)
            return slotsToOccupy.overlaps(otherSlots)
        }
        if conflict != nil { showOverlapWarning = true; return }

        let detail = combinedDetail()

        if let activity = existingActivity {
            activity.startSlot     = startSlot
            activity.durationSlots = durationSlots
            activity.detail        = detail
            activity.category      = category
            activity.subCategory   = selectedSubCategory
            activity.updatedAt     = Date()
        } else {
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
        if let activity = existingActivity { modelContext.delete(activity) }
        dismiss()
    }

    private func slotToTimeString(_ slot: Int) -> String {
        let clamped = max(0, min(slot, 48))
        let hour   = clamped / 2
        let minute = clamped % 2 == 0 ? "00" : "30"
        return String(format: "%02d:%@", hour, minute)
    }

    private func durationLabel(_ slots: Int) -> String {
        let hours = slots / 2
        let half  = slots % 2 != 0
        if hours == 0 { return "30m" }
        if !half      { return "\(hours)h" }
        return "\(hours)h 30m"
    }
}
