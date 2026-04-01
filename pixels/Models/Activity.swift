    //
//  Activity.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//

import SwiftData
import Foundation

@Model
class Activity {
    var id: UUID
    var date: Date          // normalized to midnight of that day
    var startSlot: Int      // 0–47 (0 = 00:00, 16 = 08:00, 18 = 09:00)
    var durationSlots: Int  // how many 30-min blocks it spans (min 1)
    var detail: String
    var createdAt: Date
    var updatedAt: Date

    var category: Category?
    var subCategory: SubCategory?

    init(date: Date, startSlot: Int, durationSlots: Int = 1, detail: String, category: Category, subCategory: SubCategory? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.startSlot = startSlot
        self.durationSlots = durationSlots
        self.detail = detail
        self.createdAt = Date()
        self.updatedAt = Date()
        self.category = category
        self.subCategory = subCategory
    }
}
