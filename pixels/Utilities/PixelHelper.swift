//
//  PixelHelper.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

func buildDominantColors(from activities: [Activity], categories: [Category]) -> [String: Color] {
    var slotsByDay: [String: [String: Int]] = [:]

    for activity in activities {
        let key = dayKey(activity.date)
        let catName = activity.category?.name ?? "Other"
        slotsByDay[key, default: [:]][catName, default: 0] += activity.durationSlots
    }

    var result: [String: Color] = [:]
    for (dateKey, catSlots) in slotsByDay {
        let dominant = catSlots.sorted {
            $0.value != $1.value ? $0.value > $1.value : $0.key < $1.key
        }.first?.key

        if let name = dominant,
           let cat = categories.first(where: { $0.name == name }) {
            result[dateKey] = cat.color
        }
    }
    return result
}

func dayKey(_ date: Date) -> String {
    let cal = Calendar.current
    let d = cal.dateComponents([.year, .month, .day], from: date)
    return "\(d.year!)-\(d.month!)-\(d.day!)"
}
