//
//  HistoryFilterSheet.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct HistoryFilterSheet: View {
    @EnvironmentObject private var store: JournalStore
    @Environment(\.dismiss) private var dismiss
    @State private var selection: FilterPreset = .allTime
    @State private var customStart = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEnd = Date()

    enum FilterPreset: String, CaseIterable, Identifiable {
        case allTime = "All Time"
        case lastSeven = "Last 7 Days"
        case lastThirty = "Last 30 Days"
        case custom = "Custom Range"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    Section {
                        Picker("Preset", selection: $selection) {
                            ForEach(FilterPreset.allCases) { preset in
                                Text(preset.rawValue).tag(preset)
                            }
                        }
                        .pickerStyle(.inline)
                        .foregroundStyle(Color.appTextPrimary)
                    } header: {
                        Text("Range")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .listRowBackground(filterFormRowBackground)

                    if selection == .custom {
                        Section {
                            DatePicker("Start", selection: $customStart, displayedComponents: .date)
                                .foregroundStyle(Color.appTextPrimary)
                            DatePicker("End", selection: $customEnd, displayedComponents: .date)
                                .foregroundStyle(Color.appTextPrimary)
                        } header: {
                            Text("Custom")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .listRowBackground(filterFormRowBackground)
                    }
                }
                .scrollContentBackground(.hidden)
                .tint(Color.appPrimary)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appSurface.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackHub.tap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        FeedbackHub.tap()
                        applyFilter()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .onAppear {
                switch store.filterDateRange {
                case .allTime:
                    selection = .allTime
                case .lastSevenDays:
                    selection = .lastSeven
                case .lastThirtyDays:
                    selection = .lastThirty
                case let .custom(start, end):
                    selection = .custom
                    customStart = start
                    customEnd = end
                }
            }
        }
    }

    private func applyFilter() {
        let range: DateRangeFilter
        switch selection {
        case .allTime:
            range = .allTime
        case .lastSeven:
            range = .lastSevenDays
        case .lastThirty:
            range = .lastThirtyDays
        case .custom:
            range = .custom(start: customStart, end: customEnd)
        }
        store.setFilterDateRange(range)
    }

    private var filterFormRowBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.93),
                        Color.appSurface.opacity(0.78)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
            )
    }
}
