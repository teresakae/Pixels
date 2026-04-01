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

    @Relationship(deleteRule: .cascade) var subCategories: [SubCategory] = []
    @Relationship(deleteRule: .nullify) var activities: [Activity] = []

    init(name: String, colorHex: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.isDefault = isDefault
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
