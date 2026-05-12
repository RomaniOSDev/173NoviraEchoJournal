//
//  JournalHubView.swift
//  173NoviraEchoJournal
//

import SwiftUI

private enum JournalSection: String, CaseIterable, Identifiable {
    case history = "History"
    case trends = "Trends"
    var id: String { rawValue }
}

struct JournalHubView: View {
    @State private var section: JournalSection = .history

    var body: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $section) {
                ForEach(JournalSection.allCases) { item in
                    Text(item.rawValue).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color.appPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .appCardBackground(cornerRadius: 14, style: .rich, elevation: .listItem)
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 8)

            Group {
                switch section {
                case .history:
                    Feature2View()
                case .trends:
                    Feature3View()
                }
            }
            .transition(.slide)
            .animation(.easeInOut(duration: 0.3), value: section)
        }
    }
}
