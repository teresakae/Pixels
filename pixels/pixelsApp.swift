//
//  pixelsApp.swift
//  pixels
//
//  Created by Teresa Kae on 01/04/26.
//
// XCODE SETUP — required before iCloud sync works:
// 1. In Xcode: target → Signing & Capabilities → "+ Capability" → add "CloudKit"
// 2. Under CloudKit, add a container: "iCloud.com.yourname.pixels"
// 3. Confirm pixels.entitlements contains com.apple.developer.icloud-container-identifiers
//    and com.apple.developer.ubiquity-kvstore-identifier entries
// 4. In Info.plist add NSUbiquitousContainers with your container ID if Xcode doesn't
//    generate it automatically

import SwiftUI
import SwiftData

@main
struct pixelsApp: App {
    @AppStorage("iCloudEnabled") private var iCloudEnabled = false

    var sharedModelContainer: ModelContainer = {
        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudEnabled")
        let schema = Schema([Activity.self, Category.self, SubCategory.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: iCloudEnabled ? .automatic : .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData setup failed: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
