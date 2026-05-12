//
//  DateRangeFilter.swift
//  173NoviraEchoJournal
//

import Foundation

enum DateRangeFilter: Codable, Equatable, Hashable {
    case allTime
    case lastSevenDays
    case lastThirtyDays
    case custom(start: Date, end: Date)

    private enum CodingKeys: String, CodingKey {
        case kind
        case start
        case end
    }

    private enum Kind: String, Codable {
        case allTime
        case lastSevenDays
        case lastThirtyDays
        case custom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .allTime:
            self = .allTime
        case .lastSevenDays:
            self = .lastSevenDays
        case .lastThirtyDays:
            self = .lastThirtyDays
        case .custom:
            let start = try container.decode(Date.self, forKey: .start)
            let end = try container.decode(Date.self, forKey: .end)
            self = .custom(start: start, end: end)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .allTime:
            try container.encode(Kind.allTime, forKey: .kind)
        case .lastSevenDays:
            try container.encode(Kind.lastSevenDays, forKey: .kind)
        case .lastThirtyDays:
            try container.encode(Kind.lastThirtyDays, forKey: .kind)
        case let .custom(start, end):
            try container.encode(Kind.custom, forKey: .kind)
            try container.encode(start, forKey: .start)
            try container.encode(end, forKey: .end)
        }
    }

    func contains(_ date: Date, relativeTo now: Date) -> Bool {
        let calendar = Calendar.current
        switch self {
        case .allTime:
            return true
        case .lastSevenDays:
            guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return true }
            return date >= start && date <= now
        case .lastThirtyDays:
            guard let start = calendar.date(byAdding: .day, value: -30, to: now) else { return true }
            return date >= start && date <= now
        case let .custom(start, end):
            return date >= start && date <= end
        }
    }
}
