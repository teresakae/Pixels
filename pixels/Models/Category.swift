//
//  category.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//

import SwiftData
import SwiftUI

@Model
class Category {
    var id: UUID
    var name: String
    var colorHex: String
    var isDefault: Bool
    var createdAt: Date
    var iconName: String

    @Relationship(deleteRule: .cascade) var subCategories: [SubCategory] = []
    @Relationship(deleteRule: .nullify) var activities: [Activity] = []

    // 🛠️ FIXED: Added iconName to the parameters and setup!
    init(name: String, colorHex: String, iconName: String = "square.grid.2x2", isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName // Maps the parameter to the property
        self.isDefault = isDefault
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
