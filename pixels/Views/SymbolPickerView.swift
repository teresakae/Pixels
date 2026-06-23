//
//  SymbolPickerView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI

struct SymbolPickerView: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    static let symbols: [(label: String, name: String)] = [
        // Work & productivity
        ("Briefcase",    "briefcase"),
        ("Laptop",       "laptopcomputer"),
        ("Chart Bar",    "chart.bar"),
        ("Chart Up",     "chart.line.uptrend.xyaxis"),
        ("Calendar",     "calendar"),
        ("Clipboard",    "clipboard"),
        ("Doc",          "doc.text"),
        ("Folder",       "folder"),
        ("Pencil",       "pencil"),
        ("Envelope",     "envelope"),
        ("Phone",        "phone"),
        ("Video",        "video"),
        ("Clock",        "clock"),
        ("Bell",         "bell"),
        ("Tag",          "tag"),
        ("Pin",          "pin"),
        ("Link",         "link"),
        ("Globe",        "globe"),
        ("Building",     "building.2"),
        ("Tray",         "tray.full"),
        // Health & body
        ("Heart",        "heart"),
        ("Dumbbell",     "dumbbell"),
        ("Walk",         "figure.walk"),
        ("Run",          "figure.run"),
        ("Mind & Body",  "figure.mind.and.body"),
        ("Bicycle",      "bicycle"),
        ("Flame",        "flame"),
        ("Drop",         "drop"),
        ("Brain",        "brain.head.profile"),
        ("Bandage",      "bandage"),
        ("Pill",         "pill"),
        ("Stethoscope",  "stethoscope"),
        ("Lungs",        "lungs"),
        // Food & drink
        ("Fork & Knife", "fork.knife"),
        ("Cup",          "cup.and.saucer"),
        ("Mug",          "mug"),
        ("Wineglass",    "wineglass"),
        ("Cart",         "cart"),
        ("Bag",          "bag"),
        ("Takeout Bag",  "bag.fill"),
        // Social & people
        ("Person",       "person"),
        ("People",       "person.2"),
        ("Bubbles",      "bubble.left.and.bubble.right"),
        ("Message",      "message"),
        ("Hand Wave",    "hand.wave"),
        ("Party",        "party.popper"),
        ("Gift",         "gift"),
        ("Heart Fill",   "heart.fill"),
        // Learning & creativity
        ("Book",         "book"),
        ("Books",        "books.vertical"),
        ("Graduation",   "graduationcap"),
        ("Lightbulb",    "lightbulb"),
        ("Music Note",   "music.note"),
        ("Headphones",   "headphones"),
        ("Camera",       "camera"),
        ("Film",         "film"),
        ("Paintbrush",   "paintbrush"),
        ("Gamepad",      "gamecontroller"),
        ("Pencil Draw",  "pencil.and.outline"),
        // Rest & home
        ("Moon",         "moon"),
        ("Zzz",          "zzz"),
        ("House",        "house"),
        ("Bed",          "bed.double"),
        ("Sun",          "sun.max"),
        ("Leaf",         "leaf"),
        ("Tree",         "tree"),
        // Travel & misc
        ("Car",          "car"),
        ("Airplane",     "airplane"),
        ("Suitcase",     "suitcase"),
        ("Star",         "star"),
        ("Sparkles",     "sparkles"),
        ("Bolt",         "bolt"),
        ("Compass",      "safari"),
        ("Checkmark",    "checkmark.circle"),
        ("Grid",         "square.grid.2x2"),
    ]

    private var filtered: [(label: String, name: String)] {
        guard !query.isEmpty else { return Self.symbols }
        return Self.symbols.filter {
            $0.label.localizedCaseInsensitiveContains(query) ||
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }

    // 4 columns instead of 5
        private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filtered, id: \.name) { item in
                            Button {
                                selected = item.name
                                dismiss()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: item.name)
                                        .font(.title)          // was .title2
                                        .frame(width: 44, height: 44)
                                        .background(
                                            selected == item.name
                                                ? Color.accentColor.opacity(0.15)
                                                : Color(.systemGray6)
                                        )
                                        .foregroundStyle(
                                            selected == item.name
                                                ? Color.accentColor
                                                : .primary
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(
                                                    selected == item.name
                                                        ? Color.accentColor
                                                        : .clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    Text(item.label)
                                        .font(.system(size: 10))   // was 9
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)                               // was .padding() default
                }
                .navigationTitle("Choose Icon")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $query, prompt: "Search icons")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }}
