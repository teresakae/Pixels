//
//  SettingsView.swift
//  pixels
//
//  Created by Teresa Kae on 09/05/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("iCloudEnabled") private var iCloudEnabled = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Categories
                Section {
                    NavigationLink(destination: CategoriesView()) {
                        Label("Categories", systemImage: "tag")
                    }
                } header: {
                    Text("Customise")
                }

                // MARK: - iCloud
                Section("Sync") {
                    Toggle(isOn: $iCloudEnabled) {
                        Label("iCloud Backup", systemImage: "icloud")
                    }
                    if iCloudEnabled {
                        Text("Syncs across devices on the same Apple ID. Enable once your data is ready.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - About
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
