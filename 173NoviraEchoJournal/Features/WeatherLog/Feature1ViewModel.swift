//
//  Feature1ViewModel.swift
//  173NoviraEchoJournal
//

import Combine
import Foundation

@MainActor
final class Feature1ViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sortNewestFirst: Bool = true

    func makeDraft() -> WeatherEntry {
        WeatherEntry()
    }

    func duplicate(from entry: WeatherEntry) -> WeatherEntry {
        WeatherEntry(
            id: entry.id,
            date: entry.date,
            temperatureText: entry.temperatureText,
            condition: entry.condition,
            notes: entry.notes,
            precipitationText: entry.precipitationText,
            locationLabel: entry.locationLabel,
            windText: entry.windText,
            humidityText: entry.humidityText,
            visibilityText: entry.visibilityText,
            skyCover: entry.skyCover,
            comfortTag: entry.comfortTag
        )
    }

    /// Same readings as `entry`, new id and timestamp — for quick “log again”.
    func duplicateAsNewEntry(from entry: WeatherEntry) -> WeatherEntry {
        WeatherEntry(
            id: UUID(),
            date: Date(),
            temperatureText: entry.temperatureText,
            condition: entry.condition,
            notes: entry.notes,
            precipitationText: entry.precipitationText,
            locationLabel: entry.locationLabel,
            windText: entry.windText,
            humidityText: entry.humidityText,
            visibilityText: entry.visibilityText,
            skyCover: entry.skyCover,
            comfortTag: entry.comfortTag
        )
    }

    /// Full journal (no date-range filter — this tab is the live log).
    func displayedEntries(from store: JournalStore) -> [WeatherEntry] {
        var list = store.weatherEntries

        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let query = trimmed.lowercased()
            list = list.filter { entry in
                entry.condition.lowercased().contains(query)
                    || entry.notes.lowercased().contains(query)
                    || entry.temperatureText.lowercased().contains(query)
                    || entry.precipitationText.lowercased().contains(query)
                    || entry.locationLabel.lowercased().contains(query)
                    || entry.windText.lowercased().contains(query)
                    || entry.humidityText.lowercased().contains(query)
                    || entry.visibilityText.lowercased().contains(query)
                    || entry.skyCover.lowercased().contains(query)
                    || entry.comfortTag.lowercased().contains(query)
            }
        }

        list.sort { sortNewestFirst ? $0.date > $1.date : $0.date < $1.date }
        return list
    }

    func daySections(from entries: [WeatherEntry]) -> [HistoryDaySection] {
        HistoryDaySection.buildSections(from: entries, sortNewestFirst: sortNewestFirst)
    }

    func totalEntryCount(from store: JournalStore) -> Int {
        store.weatherEntries.count
    }

    func lastLoggedSummary(from store: JournalStore) -> String? {
        guard let last = store.lastLogDate else { return nil }
        return RelativeDateTimeFormatter().localizedString(for: last, relativeTo: Date())
    }
}
