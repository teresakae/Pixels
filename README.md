# Pixels

> An offline-first iOS daily activity journal. Log what you did, not what you planned.

---

## What it is

Pixels is a minimal iOS app for journaling how you actually spend your time — not what you planned. Each day is broken into 30-minute slots on a 24-hour grid. You log activities, tag them with a category, and over time build a visual picture of your life in colour.

---

## Build Constraints

This app was built under strict constraints as a 1-day MVP sprint:

| Constraint | Decision |
|---|---|
| Timeline | 1 day build |
| Pages | 2 only — Today + Insight (sheets/modals don't count) |
| Connectivity | Fully offline. No network calls. Airplane mode safe. |
| UI Framework | SwiftUI (originally specced as UIKit; SwiftUI used throughout) |
| Persistence | SwiftData (iOS 17+) |
| Future DB | Supabase-ready data model from day 1 |
| Minimum iOS | iOS 17 |

---

## Features

### Today Tab
- **24-hour time grid** — 48 rows of 30-minute slots, midnight to midnight
- **Pinch to zoom** — scale row height between compact (32pt) and spacious (80pt)
- **Date strip** — horizontal scrollable date picker, no future dates, defaults to today
- **Calendar jump** — calendar icon opens a full date picker to jump to any past date
- **Activity blocks** — colour-coded, shows detail + category, tap to edit
- **Drag to resize** — drag the bottom handle of any block to extend/shrink in 30-min increments with haptic feedback
- **Overlap detection** — prevents saving activities that conflict with existing ones
- **Adaptive text colour** — dark text on light-coloured blocks (teal, gray) for readability
- **Auto-scroll** — grid scrolls to current time on launch

### Insight Tab
- **Three periods** — WEEK, MONTH, YEAR views via segmented control
- **Year in Pixels** — 12-row grid, one cell per day, coloured by dominant category
- **Month view** — calendar-style grid with correct weekday offset
- **Week view** — 7 large cells with today highlighted
- **Category legend** — scrollable pills showing only active categories for the period
- **Stats** — time breakdown and frequency breakdown as horizontal stacked bars, per period

---

## Data Model

Three SwiftData models, designed to map cleanly to Postgres/Supabase later:

### `Category`
- `id: UUID` — primary key
- `name: String` — e.g. "Work"
- `colorHex: String` — e.g. "#5CC2C6"
- `isDefault: Bool` — true for the 8 seeded categories
- `createdAt: Date`
- Relationships: `subCategories`, `activities`

### `SubCategory`
- `id: UUID`
- `name: String`
- `createdAt: Date`
- Relationship: `category`, `activities`

### `Activity`
- `id: UUID`
- `date: Date` — normalised to midnight
- `startSlot: Int` — 0–47 (0 = 00:00, 16 = 08:00)
- `durationSlots: Int` — number of 30-min blocks (min 1)
- `detail: String` — free text, e.g. "WFC at Cafe"
- `createdAt: Date`, `updatedAt: Date`
- Relationships: `category`, `subCategory` (optional)

### Default Categories (seeded on first launch)

| Name | Colour | Hex |
|---|---|---|
| Work | Turquoise | `#5CC2C6` |
| Personal | Coral Pink | `#FFACAB` |
| Health | Mint Green | `#A1E0DD` |
| Social | Hot Pink | `#FA85B9` |
| Learning | Dusty Blue | `#88AED2` |
| Rest | Pale Peach | `#FFDBBA` |
| Food | Warm Rose | `#FF8894` |
| Other | Light Gray | `#D2D8D9` |

---

## File Structure

```
pixels/
├── App/
│   ├── pixelsApp.swift           # App entry point, SwiftData container
│   └── ContentView.swift         # TabView, category seeding
├── Models/
│   ├── Activity.swift
│   ├── Category.swift
│   └── Subcategory.swift
├── Views/
│   ├── TodayView.swift           # Today tab root
│   ├── InsightView.swift         # Insight tab root
│   ├── TimeGridView.swift        # 24hr grid, slot rows, activity blocks
│   ├── DateStripView.swift       # Horizontal date scroller
│   ├── ActivityFormView.swift    # Add/edit sheet
│   ├── CalendarPickerView.swift  # Full calendar date jump
│   ├── PixelGridView.swift       # Year in pixels grid
│   ├── MonthPixelView.swift      # Month calendar grid
│   ├── WeekPixelView.swift       # Week 7-cell view
│   ├── CategoryLegendView.swift  # Scrollable category pills
│   └── StatsView.swift           # Stacked bar stats
└── Utilities/
    ├── ColorExtension.swift      # Color(hex:) init
    └── PixelHelper.swift         # Shared dominant colour + dayKey logic
```

---

## Tech Stack

- **Language:** Swift
- **UI:** SwiftUI
- **Persistence:** SwiftData
- **Minimum iOS:** 17.0
- **Architecture:** lightweight MVVM — views own their state, SwiftData handles the model layer

---

## Supabase Migration Path

The data model is designed to migrate cleanly:
- `id: UUID` → Postgres primary key
- `createdAt` / `updatedAt` → sync conflict resolution
- Add `isSynced: Bool` flag when ready to add a sync layer
- SwiftData also supports CloudKit with a one-line config change (`ModelConfiguration` with `cloudKitDatabase`)

---

## What's Cut (Post-MVP)

| Feature | Notes |
|---|---|
| Category management UI | Data model supports full CRUD; UI screen not built |
| Tap pixel → navigate to day | Stretch goal; grid is visual-only for now |
| Supabase sync | Model is ready; sync layer not built |
| iCloud backup | Supported by SwiftData with one config line |
| Notifications / reminders | Future |
| Widget | Future |

---

## Design System

- **Row height:** 56pt default, 32–80pt via pinch gesture
- **Time label column:** 52pt
- **Horizontal padding:** 16pt
- **Activity block corner radius:** 12pt
- **Typography:** SF Pro system font — titles `.black` weight, time labels `.monospacedDigit`
- **Adaptive text:** dark charcoal (`#2C2C2C`) on light-coloured blocks (luminance > 0.75), white on all others
