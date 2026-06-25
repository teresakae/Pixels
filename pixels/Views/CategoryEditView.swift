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

    let category: Category?

    @State private var name: String = ""
    @State private var selectedColor: Color = Color.pixels.healthFill
    @State private var selectedIconName: String = "square.grid.2x2"
    @State private var selectedSwatchIndex: Int? = 0
    @State private var showColorPicker = false
    @State private var duplicateError = false

    @FocusState private var nameFieldFocused: Bool

    private var presetColors: [Color] {
        [
            Color.pixels.healthFill,
            Color.pixels.learningFill,
            Color.pixels.foodFill,
            Color.pixels.workFill,
            Color.pixels.socialFill,
            Color.pixels.restFill,
            Color.pixels.personalFill,
        ]
    }

    private let symbols = SymbolPickerView.symbols

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var hasChanges: Bool {
        guard let cat = category else { return !trimmedName.isEmpty }
        return trimmedName != cat.name
            || selectedColor.toHex() != cat.colorHex
            || selectedIconName != cat.iconName
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && hasChanges && !duplicateError
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.pixels.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                    .padding(.horizontal, PixelsLayout.Spacing.margin)
                    .padding(.vertical, 14)

                PixelsDivider()

                ScrollView {
                    VStack(spacing: 12) {
                        previewCard
                        nameCard
                        colourCard
                        iconCard
                    }
                    .padding(PixelsLayout.Spacing.margin)
                    .padding(.bottom, 32)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showColorPicker) {
            customColorSheet
        }
        .onAppear {
            populate()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Settings")
                        .font(.pixels.body)
                }
                .foregroundStyle(Color.pixels.textSecondary)
            }

            Spacer()

            Text(category == nil ? "New Category" : category!.name)
                .pixelsEyebrow()

            Spacer()

            Button { save() } label: {
                Text("Save")
                    .font(.pixels.body.weight(.semibold))
                    .foregroundStyle(canSave ? Color.pixels.textPrimary : Color.pixels.textPlaceholder)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(canSave ? Color.pixels.accent : Color.pixels.surface)
                    )
            }
            .disabled(!canSave)
        }
    }

    // MARK: - Preview card

    private var previewCard: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.categoryIcon)
                    .fill(selectedColor)
                    .frame(width: 56, height: 56)
                Image(systemName: selectedIconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(selectedColor.isLight ? Color.pixels.textPrimary : .white)
            }
            Text(trimmedName.isEmpty ? "Category Name" : trimmedName)
                .font(.pixels.body)
                .foregroundStyle(trimmedName.isEmpty ? Color.pixels.textPlaceholder : Color.pixels.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(surfaceCard)
    }

    // MARK: - Name card

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Category name", text: $name)
                .font(.pixels.body)
                .foregroundStyle(Color.pixels.textPrimary)
                .tint(Color.pixels.accent)
                .focused($nameFieldFocused)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .onChange(of: name) { _, _ in validateDuplicate() }

            if duplicateError {
                Text("Name already taken")
                    .font(.pixels.caption)
                    .foregroundStyle(Color.pixels.accentDark)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
                .fill(Color.pixels.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
                        .strokeBorder(
                            nameFieldFocused ? Color.pixels.accent : Color.pixels.borderSurface,
                            lineWidth: nameFieldFocused ? PixelsLayout.BorderWidth.strong : PixelsLayout.BorderWidth.default
                        )
                )
        )
    }

    // MARK: - Colour card

    private var colourCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Colour")
                .pixelsEyebrow()
                .padding(.horizontal, 14)
                .padding(.top, 14)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 8),
                spacing: 10
            ) {
                ForEach(0..<presetColors.count, id: \.self) { i in
                    swatchCell(color: presetColors[i], index: i)
                }
                customSwatchCell
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(surfaceCard)
    }

    private func swatchCell(color: Color, index: Int) -> some View {
        let isSelected = selectedSwatchIndex == index
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.pixels.textPrimary, lineWidth: 2)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color.isLight ? Color.pixels.textPrimary : .white)
            }
        }
        .frame(width: 32, height: 32)
        .onTapGesture {
            selectedSwatchIndex = index
            selectedColor = color
        }
    }

    private var customSwatchCell: some View {
        let isCustom = selectedSwatchIndex == nil
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isCustom ? selectedColor : Color.pixels.surface)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
                .foregroundStyle(Color.pixels.borderEmpty)
            Image(systemName: "paintpalette")
                .font(.system(size: 13))
                .foregroundStyle(
                    isCustom
                        ? (selectedColor.isLight ? Color.pixels.textPrimary : .white)
                        : Color.pixels.textTertiary
                )
        }
        .frame(width: 32, height: 32)
        .onTapGesture {
            selectedSwatchIndex = nil
            showColorPicker = true
        }
    }

    // MARK: - Icon card

    private var iconCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Icon")
                .pixelsEyebrow()
                .padding(.horizontal, 14)
                .padding(.top, 14)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
                spacing: 8
            ) {
                ForEach(symbols, id: \.name) { item in
                    iconCell(symbol: item.name)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(surfaceCard)
    }

    private func iconCell(symbol: String) -> some View {
        let isSelected = selectedIconName == symbol
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? selectedColor : Color.pixels.background)
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    isSelected
                        ? Color.pixels.appearance(for: trimmedName).border
                        : Color.pixels.borderDefault,
                    lineWidth: isSelected
                        ? PixelsLayout.BorderWidth.selectedCategory
                        : PixelsLayout.BorderWidth.default
                )
            Image(systemName: symbol)
                .font(.system(size: 16))
                .foregroundStyle(
                    isSelected
                        ? (selectedColor.isLight ? Color.pixels.textPrimary : .white)
                        : Color.pixels.textSecondary
                )
        }
        .frame(width: 40, height: 40)
        .onTapGesture {
            selectedIconName = symbol
        }
    }

    // MARK: - Custom colour sheet

    private var customColorSheet: some View {
        VStack(spacing: 24) {
            Text("Custom Colour")
                .font(.pixels.body.weight(.semibold))
                .foregroundStyle(Color.pixels.textPrimary)
                .padding(.top, 8)

            ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                .labelsHidden()
                .scaleEffect(1.4)

            Button {
                showColorPicker = false
            } label: {
                Text("Done")
                    .font(.pixels.body.weight(.semibold))
                    .foregroundStyle(Color.pixels.textPrimary)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.pixels.accent))
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 32)
        .presentationDetents([.height(260)])
        .presentationBackground(Color.pixels.background)
    }

    // MARK: - Shared background

    private var surfaceCard: some View {
        RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
            .fill(Color.pixels.surface)
            .overlay(
                RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.card)
                    .strokeBorder(Color.pixels.borderSurface, lineWidth: PixelsLayout.BorderWidth.default)
            )
    }

    // MARK: - Helpers

    private func populate() {
        guard let cat = category else { return }
        name = cat.name
        selectedIconName = cat.iconName
        let color = Color(hex: cat.colorHex) ?? Color.pixels.healthFill
        selectedColor = color
        selectedSwatchIndex = presetColors.firstIndex {
            $0.toHex() == color.toHex()
        }
    }

    private func validateDuplicate() {
        let t = trimmedName
        guard !t.isEmpty else { duplicateError = false; return }
        duplicateError = allCategories.contains {
            $0.name.lowercased() == t.lowercased() && $0.id != category?.id
        }
    }

    private func save() {
        let t = trimmedName
        guard !t.isEmpty, !duplicateError else { return }

        let hex = selectedColor.toHex() ?? "#888888"

        if let cat = category {
            cat.name = t
            cat.colorHex = hex
            cat.iconName = selectedIconName
        } else {
            let newCat = Category(name: t, colorHex: hex, iconName: selectedIconName, isDefault: false)
            modelContext.insert(newCat)
        }

        try? modelContext.save()
        dismiss()
    }
}
