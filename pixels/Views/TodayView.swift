//
//  TodayView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerView

                // Date Strip
                DateStripView(selectedDate: $selectedDate)
                    .padding(.vertical, 8)

                Divider()

                // Time Grid (placeholder for now)
                ScrollView {
                    Text("Time grid coming next")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("So, what did you do in")
                    .font(.system(size: 16, weight: .regular))
                Text(monthName(from: selectedDate).uppercased() + "?")
                    .font(.system(size: 28, weight: .black))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}
