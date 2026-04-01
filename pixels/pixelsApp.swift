//
//  pixelsApp.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//

import SwiftUI
import SwiftData

@main
struct pixelsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Category.self, SubCategory.self, Activity.self],
                        onSetup: { result in
            if case .failure(let error) = result {
                print("SwiftData setup failed: \(error)")
            }
        })
    }
}
