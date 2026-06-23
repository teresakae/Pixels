//
//  TimeGridView.swift
//  pixels
//

import SwiftUI
import SwiftData

struct TimeGridView: View {
    let selectedDate: Date
    let activities: [Activity]
    let onSlotTap: (Int) -> Void
    let onActivityTap: (Activity) -> Void

    @State private var baseRowHeight: CGFloat = PixelsLayout.Size.rowHeightDefault
    @GestureState private var magnifyScale: CGFloat = 1.0

    private var displayRowHeight: CGFloat {
        (baseRowHeight * magnifyScale)
            .clamped(to: PixelsLayout.Size.rowHeightMin...PixelsLayout.Size.rowHeightMax)
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ZStack(alignment: .topLeading) {
                    // Slot grid — always receives touches in empty areas
                    VStack(spacing: 0) {
                        ForEach(0..<48, id: \.self) { slot in
                            SlotRowView(
                                slot: slot,
                                rowHeight: displayRowHeight,
                                isOccupied: isOccupied(slot)
                            )
                            .onTapGesture {
                                if !isOccupied(slot) { onSlotTap(slot) }
                            }
                            .id(slot)
                        }
                    }

                    // Activity blocks — positioned via layout (not offset) so hit areas are correct
                    ForEach(activities) { activity in
                        ActivityBlockView(
                            activity: activity,
                            rowHeight: displayRowHeight,
                            onTap: { onActivityTap(activity) },
                            allActivities: activities
                        )
                    }
                }
                .padding(.horizontal, PixelsLayout.Spacing.margin)
            }
            .background(Color.pixels.background)
            .simultaneousGesture(
                MagnificationGesture()
                    .updating($magnifyScale) { value, state, _ in state = value }
                    .onEnded { value in
                        baseRowHeight = (baseRowHeight * value)
                            .clamped(to: PixelsLayout.Size.rowHeightMin...PixelsLayout.Size.rowHeightMax)
                    }
            )
            .onAppear {
                proxy.scrollTo(max(0, currentTimeSlot() - 2), anchor: .top)
            }
        }
    }

    private func isOccupied(_ slot: Int) -> Bool {
        activities.contains { slot >= $0.startSlot && slot < $0.startSlot + $0.durationSlots }
    }

    private func currentTimeSlot() -> Int {
        let now = Date()
        let h = Calendar.current.component(.hour, from: now)
        let m = Calendar.current.component(.minute, from: now)
        return h * 2 + (m >= 30 ? 1 : 0)
    }
}

// MARK: - Slot row

struct SlotRowView: View {
    let slot: Int
    let rowHeight: CGFloat
    let isOccupied: Bool

    private var isHourMark: Bool { slot % 2 == 0 }

    var body: some View {
        HStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if isHourMark {
                    Text(String(format: "%02d:00", slot / 2))
                        .font(.pixels.timeLabel)
                        .foregroundStyle(Color.pixels.textTertiary)
                        .offset(y: -8)
                }
            }
            .frame(width: PixelsLayout.Size.timeLabelWidth, alignment: .trailing)
            .padding(.trailing, 8)

            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: rowHeight)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.pixels.borderDefault.opacity(isHourMark ? 1 : 0.45))
                            .frame(height: PixelsLayout.BorderWidth.default)
                    }
                    .overlay {
                        if !isOccupied {
                            Rectangle()
                                .strokeBorder(
                                    Color.pixels.borderEmpty,
                                    style: StrokeStyle(lineWidth: 0.5, dash: [4, 3])
                                )
                        }
                    }

                if !isOccupied && isHourMark {
                    Text("+ add activity")
                        .font(.pixels.caption)
                        .foregroundStyle(Color.pixels.textTertiary)
                        .padding(.leading, 8)
                        .padding(.top, 8)
                }
            }
        }
        .frame(height: rowHeight)
    }
}

// MARK: - Activity block

struct ActivityBlockView: View {
    let activity: Activity
    let rowHeight: CGFloat
    let onTap: () -> Void
    let allActivities: [Activity]

    @Environment(\.modelContext) private var modelContext

    @State private var moveOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    @State private var moveSnapSlot: Int? = nil
    @State private var resizeDelta: CGFloat = 0
    @State private var resizeSnapSlots: Int = 0

    private var appearance: CategoryAppearance {
        Color.pixels.appearance(for: activity.category?.name ?? "")
    }
    private var titleColor: Color {
        appearance.fill.isLight ? Color.pixels.textPrimary : .white
    }
    private var subtitleColor: Color {
        appearance.fill.isLight ? Color.pixels.textSecondary : .white.opacity(0.8)
    }
    private var activityTitle: String {
        activity.detail.components(separatedBy: "\n\n").first ?? activity.detail
    }
    private var subtitleText: String {
        let cat = activity.category?.name ?? ""
        if let sub = activity.subCategory { return "\(cat) · \(sub.name)" }
        return cat
    }

    var body: some View {
        let blockHeight = max(rowHeight, CGFloat(activity.durationSlots) * rowHeight + resizeDelta)
        let yOffset     = CGFloat(activity.startSlot) * rowHeight
        let xOffset     = PixelsLayout.Size.timeLabelWidth + 8

        VStack(spacing: 0) {
            // Transparent spacer positions the block in layout space so hit areas
            // land at the correct Y coordinate. .offset() only moves visuals, not layout.
            Color.clear
                .frame(height: yOffset)
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.block)
                .fill(appearance.fill)
                .overlay(
                    RoundedRectangle(cornerRadius: PixelsLayout.CornerRadius.block)
                        .strokeBorder(appearance.border, lineWidth: PixelsLayout.BorderWidth.default)
                )
                .frame(maxWidth: .infinity)
                .frame(height: blockHeight)
                .overlay(alignment: .topLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activityTitle)
                            .font(.pixels.blockTitle)
                            .foregroundStyle(titleColor)
                            .lineLimit(1)
                        Text(subtitleText)
                            .font(.pixels.blockSubtitle)
                            .foregroundStyle(subtitleColor)
                            .lineLimit(1)
                    }
                    .padding(10)
                }
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(subtitleColor.opacity(0.5))
                        .frame(width: 36, height: 4)
                        .padding(.bottom, 6)
                        .gesture(resizeGesture)
                }
                // LongPress → Drag: tap stays clean, no ScrollView competition
                .gesture(moveGesture)
                .onTapGesture { onTap() }
                .scaleEffect(isDragging ? 1.03 : 1.0)
                .shadow(
                    color: isDragging ? Color.pixels.textPrimary.opacity(0.12) : .clear,
                    radius: isDragging ? 14 : 0, x: 0, y: isDragging ? 6 : 0
                )
                .animation(.spring(duration: 0.22), value: isDragging)
                .padding(.leading, xOffset)
                .offset(y: moveOffset)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .zIndex(isDragging ? 1 : 0)
    }

    // MARK: - Move gesture
    // LongPress first: ScrollView gives up its vertical drag claim after the hold
    // fires, so subsequent drag is buttery-smooth with no gesture competition.

    private var moveGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .first(true):
                    // Long press recognised — activate move mode
                    guard !isDragging else { break }
                    isDragging = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                case .second(true, let drag?):
                    moveOffset = drag.translation.height
                    let extra = Int((drag.translation.height / rowHeight).rounded())
                    let slot  = (activity.startSlot + extra).clamped(to: 0...(48 - activity.durationSlots))
                    if slot != (moveSnapSlot ?? activity.startSlot) {
                        moveSnapSlot = slot
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                default:
                    break
                }
            }
            .onEnded { value in
                if case .second(true, let drag?) = value {
                    let extra   = Int((drag.translation.height / rowHeight).rounded())
                    let newSlot = (activity.startSlot + extra).clamped(to: 0...(48 - activity.durationSlots))

                    let hasConflict = allActivities.contains { other in
                        guard other.id != activity.id else { return false }
                        let moved      = newSlot..<(newSlot + activity.durationSlots)
                        let otherRange = other.startSlot..<(other.startSlot + other.durationSlots)
                        return moved.overlaps(otherRange)
                    }

                    if !hasConflict {
                        activity.startSlot = newSlot
                        activity.updatedAt = Date()
                        try? modelContext.save()
                    }
                }

                withAnimation(.spring(duration: 0.25)) { moveOffset = 0 }
                isDragging   = false
                moveSnapSlot = nil
            }
    }

    // MARK: - Resize gesture

    private var resizeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                resizeDelta = value.translation.height
                let extra    = Int((resizeDelta / rowHeight).rounded())
                let newSlots = max(1, activity.durationSlots + extra)
                if newSlots != resizeSnapSlots {
                    resizeSnapSlots = newSlots
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onEnded { value in
                let extra       = Int((value.translation.height / rowHeight).rounded())
                let newDuration = max(1, activity.durationSlots + extra)

                if newDuration > activity.durationSlots {
                    pushChainForward(from: activity.startSlot + newDuration,
                                     excluding: activity, activities: allActivities)
                }
                activity.durationSlots = newDuration
                activity.updatedAt     = Date()
                resizeDelta     = 0
                resizeSnapSlots = 0
                try? modelContext.save()
            }
    }

    private func pushChainForward(from slot: Int, excluding: Activity, activities: [Activity]) {
        let sorted = activities.filter { $0.id != excluding.id }.sorted { $0.startSlot < $1.startSlot }
        var required = slot
        for other in sorted {
            guard other.startSlot >= excluding.startSlot else { continue }
            if other.startSlot < required { other.startSlot = required; other.updatedAt = Date() }
            required = other.startSlot + other.durationSlots
        }
    }
}
