//
//  Subcategory.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//

import SwiftData

@Model
class SubCategory {
    var id: UUID
    var name: String
    var createdAt: Date

    var category: Category?
    @Relationship(deleteRule: .nullify) var activities: [Activity] = []

    init(name: String, category: Category) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.category = category
    }
}
