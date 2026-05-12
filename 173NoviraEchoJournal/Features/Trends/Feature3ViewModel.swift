//
//  Feature3ViewModel.swift
//  173NoviraEchoJournal
//

import Combine
import Foundation

enum TrendGranularity: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    var id: String { rawValue }
}

struct TrendBucket: Identifiable, Equatable {
    let id: String
    let title: String
    let averageTemperature: Double
    let totalPrecipitation: Double
}

@MainActor
final class Feature3ViewModel: ObservableObject {
    func buckets(for store: JournalStore, granularity: TrendGranularity) -> [TrendBucket] {
        let pairs = zip(zip(store.entryDates, store.temperatureLogs), store.precipitationLogs)
            .map { pair -> (Date, Double, Double) in
                let ((date, temp), precip) = pair
                return (date, temp, precip)
            }
            .sorted { $0.0 < $1.0 }

        guard !pairs.isEmpty else { return [] }

        let calendar = Calendar.current

        switch granularity {
        case .daily:
            let grouped = Dictionary(grouping: pairs, by: { calendar.startOfDay(for: $0.0) })
            return grouped.keys.sorted().map { day in
                let items = grouped[day] ?? []
                let avg = items.map(\.1).reduce(0, +) / Double(max(items.count, 1))
                let precip = items.map(\.2).reduce(0, +)
                let title = day.formatted(date: .abbreviated, time: .omitted)
                return TrendBucket(id: title, title: title, averageTemperature: avg, totalPrecipitation: precip)
            }
        case .weekly:
            let grouped = Dictionary(grouping: pairs, by: { triple in
                let (date, _, _) = triple
                let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                return "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)"
            })
            return grouped.keys.sorted().compactMap { key in
                guard let items = grouped[key] else { return nil }
                let avg = items.map(\.1).reduce(0, +) / Double(max(items.count, 1))
                let precip = items.map(\.2).reduce(0, +)
                return TrendBucket(id: key, title: "Week \(key.replacingOccurrences(of: "-", with: "/"))", averageTemperature: avg, totalPrecipitation: precip)
            }
        case .monthly:
            let grouped = Dictionary(grouping: pairs, by: { triple in
                let (date, _, _) = triple
                let comps = calendar.dateComponents([.year, .month], from: date)
                return "\(comps.year ?? 0)-\(comps.month ?? 0)"
            })
            return grouped.keys.sorted().compactMap { key in
                guard let items = grouped[key] else { return nil }
                let avg = items.map(\.1).reduce(0, +) / Double(max(items.count, 1))
                let precip = items.map(\.2).reduce(0, +)
                return TrendBucket(id: key, title: key.replacingOccurrences(of: "-", with: "/"), averageTemperature: avg, totalPrecipitation: precip)
            }
        }
    }

    func overallAverages(from buckets: [TrendBucket]) -> (temperature: Double, precipitation: Double) {
        guard !buckets.isEmpty else { return (0, 0) }
        let avgTemp = buckets.map(\.averageTemperature).reduce(0, +) / Double(buckets.count)
        let precip = buckets.map(\.totalPrecipitation).reduce(0, +)
        return (avgTemp, precip)
    }
}
