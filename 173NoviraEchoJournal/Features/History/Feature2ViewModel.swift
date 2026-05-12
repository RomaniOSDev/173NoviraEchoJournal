//
//  Feature2ViewModel.swift
//  173NoviraEchoJournal
//

import Combine
import Foundation

struct HistoryDaySection: Identifiable, Equatable {
    let id: Date
    let heading: String
    let entries: [WeatherEntry]

    static func buildSections(from entries: [WeatherEntry], sortNewestFirst: Bool) -> [HistoryDaySection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        let days = grouped.keys.sorted { sortNewestFirst ? $0 > $1 : $0 < $1 }

        return days.compactMap { day in
            guard let raw = grouped[day] else { return nil }
            let sortedItems = raw.sorted { sortNewestFirst ? $0.date > $1.date : $0.date < $1.date }
            return HistoryDaySection(id: day, heading: dayHeading(for: day), entries: sortedItems)
        }
    }

    private static func dayHeading(for day: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(day) {
            return "Today"
        }
        if calendar.isDateInYesterday(day) {
            return "Yesterday"
        }
        return day.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year())
    }
}

@MainActor
final class Feature2ViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sortNewestFirst: Bool = true

    func displayedEntries(from store: JournalStore, now: Date = Date()) -> [WeatherEntry] {
        var list = store.weatherEntries.filter { store.filterDateRange.contains($0.date, relativeTo: now) }

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

    func filterSummary(from store: JournalStore) -> String {
        switch store.filterDateRange {
        case .allTime:
            return "All time"
        case .lastSevenDays:
            return "Last 7 days"
        case .lastThirtyDays:
            return "Last 30 days"
        case let .custom(start, end):
            let a = start.formatted(date: .abbreviated, time: .omitted)
            let b = end.formatted(date: .abbreviated, time: .omitted)
            return "\(a) – \(b)"
        }
    }

    func entryCount(from store: JournalStore) -> Int {
        store.weatherEntries.filter { store.filterDateRange.contains($0.date, relativeTo: Date()) }.count
    }
}
