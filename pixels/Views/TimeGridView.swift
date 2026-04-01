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
    let onSlotTap: (Int) -> Void      // called with the slot index tapped
    let onActivityTap: (Activity) -> Void

    private let rowHeight: CGFloat = 56
    private let timeColumnWidth: CGFloat = 52
    private let totalSlots = 48      // 00:00-23:30

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Background slot rows
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

                    // Activity blocks overlaid on top
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
            .onAppear {
                // Scroll to current time slot (or 8am if no entries)
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

// MARK: - Slot Row (the empty background rows)
struct SlotRowView: View {
    let slot: Int
    let timeColumnWidth: CGFloat
    let rowHeight: CGFloat
    let isOccupied: Bool

    private var showTimeLabel: Bool { slot % 2 == 0 }  // only on the hour

    private var timeLabel: String {
        let hour = slot / 2
        return String(format: "%02d:00", hour)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Time label column
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

            // Slot area
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

    var body: some View {
        let blockHeight = CGFloat(activity.durationSlots) * rowHeight
        let yOffset = CGFloat(activity.startSlot) * rowHeight
        let xOffset = timeColumnWidth + 8 + 16   // timeCol + gap + horizontal padding

        RoundedRectangle(cornerRadius: 12)
            .fill(activity.category?.color ?? Color(.systemGray4))
            .frame(maxWidth: .infinity)
            .frame(height: blockHeight)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.detail)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if let sub = activity.subCategory {
                        Text("\(activity.category?.name ?? "") · \(sub.name)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    } else {
                        Text(activity.category?.name ?? "")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }
                .padding(10)
            }
            .padding(.leading, xOffset)
            .padding(.trailing, 16)
            .offset(y: yOffset)
            .frame(maxWidth: .infinity, alignment: .leading)
            // position it absolutely within the ZStack
            .frame(maxHeight: .infinity, alignment: .top)
    }
}
