# Pixels — Agent Handoff

## What this project is
An iOS daily activity journal app ("Pixels"). Each day is divided into 48 half-hour slots. The user logs activities by category; the app renders a colour-coded time grid. The redesign goal is to take it from prototype quality to a refined product using a token-based design system.

---

## The one rule that overrides everything
**Only use DesignSystem.swift tokens — no hardcoded hex values, no system colours.**
Use `Color.pixels.*`, `Font.pixels.*`, `PixelsLayout.*`.
Do not change SwiftData models, business logic, or data flow. Do not add new dependencies.

---

## File layout
```
pixels/
  ContentView.swift              — tab bar shell
  Utilities/
    DesignSystem.swift           — single source of truth for all tokens
    ColorExtension.swift         — Color(hex:), isLight, clamped(to:)
    PixelHelper.swift            — slot arithmetic helpers
  Views/
    TodayView.swift              — Tab 0 (DONE)
    DateStripView.swift          — horizontal date picker (DONE)
    TimeGridView.swift           — 48-slot time grid + activity blocks (DONE)
    ActivityFormView.swift       — add/edit activity sheet (DONE)
    InsightView.swift            — Tab 1 (NOT YET REDESIGNED)
    WeekPixelView.swift          — week colour grid (NOT YET REDESIGNED)
    MonthPixelView.swift         — month colour grid (NOT YET REDESIGNED)
    PixelGridView.swift          — year colour grid (NOT YET REDESIGNED)
    CategoryLegendView.swift     — legend pills (NOT YET REDESIGNED)
    StatsView.swift              — stat cards (NOT YET REDESIGNED)
    CategoriesView.swift         — Tab 2 (untouched, low priority)
    SettingsView.swift           — Tab 3 (untouched, low priority)
```

---

## Design system quick reference

### Colors (`Color.pixels.*`)
| Token | Use |
|---|---|
| `background` | App canvas (`#FDF6F0` warm parchment) |
| `surface` | Cards, scroller track (`#F5EDE8`) |
| `accent` | Selected states, active tab, Save button (`#F2B8B5` dusty rose) |
| `accentDark` | Pressed accent (`#E8968F`) |
| `textPrimary` | Headers, block titles (`#2C1A14`) |
| `textSecondary` | Taglines, eyebrow labels (`#8C7068`) |
| `textTertiary` | Time labels, muted UI (`#C4A89E`) |
| `textPlaceholder` | Empty field hint (`#D8C4BC`) |
| `borderDefault` | Dividers 0.5px (`#EAE0D8`) |
| `borderStrong` | Date strip bottom 1.5px (`#E0D0C8`) |
| `borderSurface` | Card borders (`#E8D8D0`) |
| `borderEmpty` | Dashed empty slot border (`#D8C4BC`) |
| `tabBarBackground` | Tab pill background |
| `tabBarActive` | Active tab item |
| `tabBarInactive` | Inactive tab item |
| `futureDot` | Unlogged year pixels (28% opacity) |

**Activity block colors** — use `Color.pixels.appearance(for: categoryName)` which returns `CategoryAppearance(fill: Color, border: Color)`. Do NOT hardcode per-category colours inline.

### Fonts (`Font.pixels.*`)
`header`, `title`, `blockTitle`, `blockSubtitle`, `timeDisplay`, `eyebrow`, `body`, `caption`, `dateLabel`, `dateNumber`, `timeLabel`

### Layout (`PixelsLayout.*`)
- `Spacing.margin` = 16
- `CornerRadius.block` = 12, `.card` = 10, `.pill` = 20, `.dateCell` = 10, `.categoryIcon` = 13, `.tabBar` = 40
- `BorderWidth.default` = 0.5, `.strong` = 1.5, `.selectedCategory` = 2.0
- `Size.rowHeightDefault` = 56, `.rowHeightMin` = 32, `.rowHeightMax` = 80, `.timeLabelWidth` = 52

### Utility components
- `PixelsDivider()` — 0.5px warm horizontal rule
- `.pixelsEyebrow()` view modifier — uppercase, kerned, textTertiary, 10pt
- `Color.pixels.appearance(for: name)` → `CategoryAppearance(fill:border:)`
- `Color(hex:)` — defined in ColorExtension.swift
- `color.isLight` — bool, used for adaptive text on coloured blocks
- `value.clamped(to: range)` — defined on Comparable in ColorExtension.swift

---

## Completed work

### Tab bar (ContentView.swift)
- Floating pill with iOS 26 `.glassEffect(.regular.tint(...), in: .capsule)`
- System UITabBar fully suppressed in `init()` via `UITabBar.appearance()`
- Active tab: `.semibold` weight, `tabBarActive` colour; inactive: `.regular`, `tabBarInactive`
- 4 tabs: Today (index 0), Insight (1), Categories (2), Settings (3)

### Add Activity sheet (ActivityFormView.swift)
- Presented as `.sheet` with `.presentationDetents([.large])`, `.presentationDragIndicator(.hidden)`, `.presentationBackground(Color.pixels.background)`
- Custom `ZStack` header: centered live title (activity name or "Add Activity") + Back (chevron.down) left + Save pill right
- Time display: three columns — START / END / DURATION, separated by 0.5px vertical rules
- Duration scroller: horizontal `ScrollView` of pills on `surface` background, selected pill has `background` fill + `borderStrong` border
- Category grid: `LazyVGrid` 4 columns, `categoryCell` with 52×52 icon box, border thickens to 2pt when selected
- Subcategory section: collapsible with chevron, 2-column pill grid using accent fill when selected
- Two text fields: "What did you do?" (activity name) + "Add details" (notes)
- **Model trick**: `Activity.detail` stores `"name\n\nnotes"`. Split with `.components(separatedBy: "\n\n")` to read back. Do NOT add new model fields.
- `canSave`: requires `selectedCategory != nil && activityName not empty`
- Delete button (edit mode only) with confirmation dialog
- Overlap detection before save

### Today tab (TodayView.swift)
- `NavigationStack` with `.toolbar(.hidden, for: .navigationBar)`
- Full background: `Color.pixels.background.ignoresSafeArea()` in ZStack
- Header: eyebrow text ("Today · June 23" / "Yesterday · …" / "Monday · …"), then `HStack(alignment: .center)` with `"Your day, in colour."` + overlapping colour dots (12pt circles, spacing -5, border colour of each category, no label text)
- `PixelsDivider()` after header
- `DateStripView` with 8pt vertical padding
- 1.5pt `borderStrong` rule after date strip
- `TimeGridView` fills remaining space

### DateStripView.swift
- 365-day horizontal scroll, auto-scrolls to today on appear
- Selected cell: `accent` fill, `CornerRadius.dateCell`, `textPrimary` text
- Inactive: day name in `textTertiary`, day number in `textPrimary`
- Fonts: `dateLabel` (day name), `dateNumber` (day number)

### TimeGridView.swift
**Layout fix (critical — do not revert):**
SwiftUI's `.offset()` moves VISUALS only, not the layout frame used for hit testing. Activity blocks must be positioned via a `VStack` with a `Color.clear.frame(height: yOffset).allowsHitTesting(false)` spacer at the top, so the layout frame lands at the correct Y coordinate. The drag animation then uses `.offset(y: moveOffset)` (visual only, not layout) on just the block content inside the VStack.

- 48 half-hour slot rows (`SlotRowView`): time label column (52pt) + dashed content area
- Dashed border on empty slots via `StrokeStyle(lineWidth: 0.5, dash: [4, 3])`
- "+ add activity" text only on hour marks (every other row)
- `SlotRowView.onTapGesture` fires `onSlotTap(slot)` — opens `ActivityFormView` via sheet in TodayView
- Pinch-to-zoom via `MagnificationGesture` on the `ScrollView`, clamped to `rowHeightMin...rowHeightMax`
- Auto-scrolls to current time slot on appear
- **Drag-to-move**: `LongPressGesture(minimumDuration: 0.35).sequenced(before: DragGesture(minimumDistance: 0))`. Hold fires medium haptic + scale to 1.03; drag moves block with light haptic per slot boundary; release commits to model if no conflict. LongPress-first prevents ScrollView gesture competition (eliminates jitter).
- **Resize**: drag handle at bottom of block (`DragGesture` on the 36×4 pill handle only)
- **Tap block** → `onTap()` → opens `ActivityFormView` in edit mode
- `ActivityBlockView` uses `Color.pixels.appearance(for: category.name)` for fill/border
- Adaptive title text: `appearance.fill.isLight ? Color.pixels.textPrimary : .white`

---

## Next task: Task 4 — Insight tab

The Insight tab (`InsightView.swift`) is currently **unstyled prototype code** — hardcoded fonts, system colours, no design tokens. The sub-views (`WeekPixelView`, `MonthPixelView`, `PixelGridView`, `CategoryLegendView`, `StatsView`) are also unstyled.

### Current InsightView structure (what exists, needs redesign):
- `NavigationStack` with system nav bar (needs to go — hide it, add custom header like TodayView)
- Period picker: `Picker(.segmented)` with WEEK / MONTH / YEAR (needs restyling as pills or custom segment)
- Hardcoded fonts: `Font.system(size: 16)`, `Font.system(size: 28, weight: .black)` etc.
- Header text: "A glimpse of" / "INSIGHT" — restyle with design system
- Settings gear icon in toolbar → moves to Settings tab, remove from here
- `PixelGridView`, `MonthPixelView`, `WeekPixelView` each take `(dates:activities:categories:onDayTap:)` — keep these signatures
- `CategoryLegendView(categories:activities:)` and `StatsView(categories:activities:)` — keep these signatures

### What the Insight tab should look like (apply same pattern as TodayView):
1. **Header**: eyebrow label (e.g. "This week", "This month", "2026") + bold title like "Your year, in colour." — same VStack pattern as TodayView header. No system nav bar.
2. **Period switcher**: three pill buttons (WEEK / MONTH / YEAR) styled as a custom segmented row using `surface` background, `accent` fill for active. NOT a system `Picker`.
3. **Pixel grid**: the coloured day grid (keep existing logic, just apply token colours for fills, borders, empty states)
4. **Legend**: category legend pills — `surface` background pill with `borderSurface` border, colour dot using `appearance(for:).border`, `textSecondary` label text
5. **Stats cards**: cards on `surface` background with `borderSurface` 0.5px border, `CornerRadius.card`, `textPrimary` numbers, `textTertiary` labels

### Key things to match from the design system in pixel grid views:
- Logged day → fill with `appearance(for: dominantCategory).fill`, border `appearance.border`
- Unlogged/future day → `Color.pixels.futureDot` (already a token, 28% opacity cream)
- Cell corner radii: `CornerRadius.weekCell` = 6, `CornerRadius.monthCell` = 4, `CornerRadius.yearCell` = 2
- Cell sizes: `Size.weekCell` = 44×58, `Size.monthCell` = 32×32
- Cell gaps: `Spacing.weekCellGap` = 2, `Spacing.monthCellGap` = 3, `Spacing.yearCellGap` = 1.5

---

## Known issues / limitations

1. **Drag-to-move is imperfect** — the LongPress + DragGesture sequencing inside a ScrollView still has some jitter on the simulator. Works better on real device. The user accepted this; do not spend more time on it.
2. **Empty slot tappability** — works correctly after the VStack+spacer layout fix. If it ever regresses, the root cause is `.offset()` not moving hit areas; the fix is the transparent spacer approach described above.
3. **`Activity.detail` dual field hack** — name and notes are stored as `"name\n\nnotes"` in a single `String` field. This is intentional to avoid model migration. Don't add new `@Model` properties.
4. **Category colours are hardcoded in DesignSystem** — `appearance(for:)` uses a switch on category name (case-insensitive). User-created categories with names other than the 8 defaults get `otherFill`/`otherBorder`. This is fine for now.

---

## Model summary (do not change)

```swift
@Model class Activity {
    var date: Date
    var startSlot: Int        // 0–47 (half-hours from midnight)
    var durationSlots: Int    // 1+ slots
    var detail: String        // "name\n\nnotes" (see hack above)
    var updatedAt: Date
    var category: Category?
    var subCategory: SubCategory?
}

@Model class Category {
    var name: String
    var colorHex: String      // stored but NOT used for display — use appearance(for: name) instead
    var iconName: String      // SF Symbol name
    var isDefault: Bool
    var subCategories: [SubCategory]
}

@Model class SubCategory {
    var name: String
    var category: Category?
}
```
