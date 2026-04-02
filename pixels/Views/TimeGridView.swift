//
//  TimeGridView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI
import SwiftData

struct TimeGridView: View {
    let selectedDate: Date
    let activities: [Activity]
    let onSlotTap: (Int) -> Void
    let onActivityTap: (Activity) -> Void

    @State private var rowHeight: CGFloat = 56
    @State private var baseRowHeight: CGFloat = 56
    private let timeColumnWidth: CGFloat = 52
    private let minRowHeight: CGFloat = 32
    private let maxRowHeight: CGFloat = 80
    private let totalSlots = 48

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        ForEach(0..<totalSlots, id: \.self) { slot in
                            SlotRowView(
                                slot: slot,
                                timeColumnWidth: timeColumnWidth,
                                rowHeight: rowHeight,
                                isOccupied: isOccupied(slot)
                            )
                            .onTapGesture {
                                if !isOccupied(slot) {
                                    onSlotTap(slot)
                                }
                            }
                            .id(slot)
                        }
                    }

                    ForEach(activities) { activity in
                        ActivityBlockView(
                            activity: activity,
                            rowHeight: rowHeight,
                            timeColumnWidth: timeColumnWidth
                        )
                        .onTapGesture {
                            onActivityTap(activity)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let newHeight = (baseRowHeight * value).clamped(to: minRowHeight...maxRowHeight)
                        rowHeight = newHeight
                    }
                    .onEnded { _ in
                        baseRowHeight = rowHeight
                    }
            )
            .onAppear {
                let currentSlot = currentTimeSlot()
                proxy.scrollTo(max(0, currentSlot - 2), anchor: .top)
            }
        }
    }

    private func isOccupied(_ slot: Int) -> Bool {
        activities.contains { activity in
            slot >= activity.startSlot && slot < activity.startSlot + activity.durationSlots
        }
    }

    private func currentTimeSlot() -> Int {
        let cal = Calendar.current
        let now = Date()
        let hour = cal.component(.hour, from: now)
        let minute = cal.component(.minute, from: now)
        return hour * 2 + (minute >= 30 ? 1 : 0)
    }
}

// MARK: - Slot Row
struct SlotRowView: View {
    let slot: Int
    let timeColumnWidth: CGFloat
    let rowHeight: CGFloat
    let isOccupied: Bool

    private var showTimeLabel: Bool { slot % 2 == 0 }

    private var timeLabel: String {
        let hour = slot / 2
        return String(format: "%02d:00", hour)
    }

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if showTimeLabel {
                    Text(timeLabel)
                        .font(.system(size: 12, weight: .regular).monospacedDigit())
                        .foregroundStyle(.secondary)
                        .offset(y: -8)
                }
            }
            .frame(width: timeColumnWidth, alignment: .trailing)
            .padding(.trailing, 8)

            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .overlay(alignment: .top) {
                        Divider()
                            .opacity(showTimeLabel ? 1 : 0.3)
                    }

                if !isOccupied {
                    Text("+ Add Activity")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                        .opacity(0.6)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

// MARK: - Activity Block
struct ActivityBlockView: View {
    let activity: Activity
    let rowHeight: CGFloat
    let timeColumnWidth: CGFloat

    @Environment(\.modelContext) private var modelContext
    @State private var dragOffset: CGFloat = 0
    @State private var lastSnappedSlots: Int = 0

    private var blockColor: Color {
        activity.category?.color ?? Color(.systemGray4)
    }

    private var textColor: Color {
        blockColor.isLight ? Color(hex: "#2C2C2C") : Color.white
    }

    private var subtitleColor: Color {
        blockColor.isLight ? Color(hex: "#2C2C2C").opacity(0.65) : Color.white.opacity(0.85)
    }
    
    var body: some View {
        let blockHeight = CGFloat(activity.durationSlots) * rowHeight + dragOffset
        let yOffset = CGFloat(activity.startSlot) * rowHeight
        let xOffset = timeColumnWidth + 8 + 16

        RoundedRectangle(cornerRadius: 12)
            .fill(blockColor)
            .frame(maxWidth: .infinity)
            .frame(height: max(rowHeight, blockHeight))
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.detail)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(textColor)
                        .lineLimit(1)

                    if let sub = activity.subCategory {
                        Text("\(activity.category?.name ?? "") · \(sub.name)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(subtitleColor)
                            .lineLimit(1)
                    } else {
                        Text(activity.category?.name ?? "")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(subtitleColor)
                            .lineLimit(1)
                    }
                }
                .padding(10)
            }
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(subtitleColor)
                    .frame(width: 36, height: 4)
                    .padding(.bottom, 6)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                                let extraSlots = Int((dragOffset / rowHeight).rounded())
                                let newSlots = max(1, activity.durationSlots + extraSlots)
                                if newSlots != lastSnappedSlots {
                                    lastSnappedSlots = newSlots
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                            .onEnded { value in
                                let extraSlots = Int((value.translation.height / rowHeight).rounded())
                                activity.durationSlots = max(1, activity.durationSlots + extraSlots)
                                activity.updatedAt = Date()
                                dragOffset = 0
                                lastSnappedSlots = 0
                            }
                    )
            }
            .padding(.leading, xOffset)
            .padding(.trailing, 16)
            .offset(y: yOffset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: - Extensions
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Color {
    var isLight: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.75
    }
}
