//
//  CalendarPickerView.swift
//  pixels
//
//  Created by Teresa Kae on 02/04/26.
//

import SwiftUI

struct CalendarPickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    @State private var internalDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select a date",
                    selection: $internalDate,
                    in: ...Date(), // no future dates
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Jump to Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Go") {
                        selectedDate = Calendar.current.startOfDay(for: internalDate)
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            internalDate = selectedDate
        }
    }
}
