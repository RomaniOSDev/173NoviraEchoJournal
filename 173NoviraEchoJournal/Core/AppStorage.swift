//
//  AppStorage.swift
//  173NoviraEchoJournal
//

import Combine
import Combine
import Foundation

extension Notification.Name {
    static let dataReset = Notification.Name("journal.dataReset")
}

@MainActor
final class JournalStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "journal.hasSeenOnboarding"
        static let weatherEntries = "journal.weatherEntries"
        static let lastLogDate = "journal.lastLogDate"
        static let filterDateRange = "journal.filterDateRange"
        static let temperatureLogs = "journal.temperatureLogs"
        static let precipitationLogs = "journal.precipitationLogs"
        static let entryDates = "journal.entryDates"
        static let totalSessionsCompleted = "journal.totalSessionsCompleted"
        static let totalSecondsUsed = "journal.totalSecondsUsed"
        static let streakDays = "journal.streakDays"
        static let lastActivityDate = "journal.lastActivityDate"
        static let achievementsUnlocked = "journal.achievementsUnlocked"
        static let lastStreakAnchorDay = "journal.lastStreakAnchorDay"
        static let trendVisitDays = "journal.trendVisitDays"
    }

    private let defaults: UserDefaults

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var weatherEntries: [WeatherEntry]
    @Published private(set) var lastLogDate: Date?
    @Published private(set) var filterDateRange: DateRangeFilter
    @Published private(set) var temperatureLogs: [Double]
    @Published private(set) var precipitationLogs: [Double]
    @Published private(set) var entryDates: [Date]
    @Published private(set) var totalSessionsCompleted: Int
    @Published private(set) var totalSecondsUsed: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var lastActivityDate: Date?
    @Published private(set) var achievementsUnlocked: [String: Date]
    @Published private(set) var trendVisitDays: Set<String>
    @Published var achievementBannerQueue: [String] = []

    private var lastStreakAnchorDay: Date?

    var itemsCreated: Int { weatherEntries.count }

    var totalMinutesUsed: Int { max(0, totalSecondsUsed / 60) }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        if let data = defaults.data(forKey: Keys.weatherEntries),
           let decoded = try? JSONDecoder().decode([WeatherEntry].self, from: data) {
            weatherEntries = decoded
        } else {
            weatherEntries = []
        }
        lastLogDate = Self.loadDate(key: Keys.lastLogDate, defaults: defaults)
        if let data = defaults.data(forKey: Keys.filterDateRange),
           let decoded = try? JSONDecoder().decode(DateRangeFilter.self, from: data) {
            filterDateRange = decoded
        } else {
            filterDateRange = .allTime
        }
        temperatureLogs = Self.loadDoubles(key: Keys.temperatureLogs, defaults: defaults)
        precipitationLogs = Self.loadDoubles(key: Keys.precipitationLogs, defaults: defaults)
        entryDates = Self.loadDates(key: Keys.entryDates, defaults: defaults)
        totalSessionsCompleted = max(0, defaults.integer(forKey: Keys.totalSessionsCompleted))
        totalSecondsUsed = max(0, defaults.integer(forKey: Keys.totalSecondsUsed))
        streakDays = max(0, defaults.integer(forKey: Keys.streakDays))
        lastActivityDate = Self.loadDate(key: Keys.lastActivityDate, defaults: defaults)
        if let data = defaults.data(forKey: Keys.achievementsUnlocked),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            achievementsUnlocked = decoded
        } else {
            achievementsUnlocked = [:]
        }
        if let data = defaults.data(forKey: Keys.trendVisitDays),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            trendVisitDays = Set(decoded)
        } else {
            trendVisitDays = []
        }
        lastStreakAnchorDay = Self.loadDate(key: Keys.lastStreakAnchorDay, defaults: defaults)
        reconcileTrendSeriesIfNeeded()
        refreshAchievementUnlocks()
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: Keys.hasSeenOnboarding)
        objectWillChange.send()
    }

    func setFilterDateRange(_ value: DateRangeFilter) {
        filterDateRange = value
        persistFilterDateRange()
        objectWillChange.send()
    }

    func addForegroundTime(_ seconds: Int) {
        guard seconds > 0 else { return }
        totalSecondsUsed += seconds
        defaults.set(totalSecondsUsed, forKey: Keys.totalSecondsUsed)
        objectWillChange.send()
    }

    func registerTrendSessionVisit(on date: Date = Date()) {
        let day = Self.dayKey(for: date)
        guard !trendVisitDays.contains(day) else { return }
        trendVisitDays.insert(day)
        totalSessionsCompleted += 1
        persistTrendVisitDays()
        defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted)
        touchActivity(on: date)
        refreshAchievementUnlocks()
        objectWillChange.send()
    }

    func saveEntry(_ entry: WeatherEntry, isNew: Bool) {
        if isNew {
            weatherEntries.insert(entry, at: 0)
        } else if let index = weatherEntries.firstIndex(where: { $0.id == entry.id }) {
            weatherEntries[index] = entry
        } else {
            weatherEntries.insert(entry, at: 0)
        }
        persistEntries()
        updateStreakAfterLog(on: entry.date)
        touchActivity(on: entry.date)
        lastLogDate = entry.date
        defaults.set(entry.date.timeIntervalSince1970, forKey: Keys.lastLogDate)
        reconcileTrendSeriesFromEntries()
        refreshAchievementUnlocks()
        objectWillChange.send()
    }

    func deleteEntry(id: UUID) {
        weatherEntries.removeAll { $0.id == id }
        persistEntries()
        recomputeStreakFromEntries()
        reconcileTrendSeriesFromEntries()
        refreshAchievementUnlocks()
        objectWillChange.send()
    }

    func resetAllData() {
        let keys = [
            Keys.hasSeenOnboarding,
            Keys.weatherEntries,
            Keys.lastLogDate,
            Keys.filterDateRange,
            Keys.temperatureLogs,
            Keys.precipitationLogs,
            Keys.entryDates,
            Keys.totalSessionsCompleted,
            Keys.totalSecondsUsed,
            Keys.streakDays,
            Keys.lastActivityDate,
            Keys.achievementsUnlocked,
            Keys.lastStreakAnchorDay,
            Keys.trendVisitDays
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }

        hasSeenOnboarding = false
        weatherEntries = []
        lastLogDate = nil
        filterDateRange = .allTime
        temperatureLogs = []
        precipitationLogs = []
        entryDates = []
        totalSessionsCompleted = 0
        totalSecondsUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        trendVisitDays = []
        lastStreakAnchorDay = nil
        achievementBannerQueue = []

        objectWillChange.send()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func achievementUnlockedDate(for id: String) -> Date? {
        achievementsUnlocked[id]
    }

    private func touchActivity(on date: Date) {
        lastActivityDate = date
        defaults.set(date.timeIntervalSince1970, forKey: Keys.lastActivityDate)
    }

    private func updateStreakAfterLog(on date: Date) {
        let calendar = Calendar.current
        let newDay = calendar.startOfDay(for: date)
        if let anchor = lastStreakAnchorDay {
            let anchorDay = calendar.startOfDay(for: anchor)
            if newDay == anchorDay {
                if streakDays == 0 {
                    streakDays = 1
                }
            } else if let next = calendar.date(byAdding: .day, value: 1, to: anchorDay),
                      calendar.isDate(newDay, inSameDayAs: next) {
                streakDays = max(1, streakDays + 1)
                lastStreakAnchorDay = newDay
            } else if newDay > anchorDay {
                streakDays = 1
                lastStreakAnchorDay = newDay
            }
        } else {
            streakDays = max(1, streakDays + 1)
            lastStreakAnchorDay = newDay
        }
        persistStreakState()
    }

    private func recomputeStreakFromEntries() {
        let calendar = Calendar.current
        let days = Set(weatherEntries.map { calendar.startOfDay(for: $0.date) })
        guard let latest = days.max() else {
            streakDays = 0
            lastStreakAnchorDay = nil
            persistStreakState()
            return
        }
        var count = 0
        var cursor = latest
        while days.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = calendar.startOfDay(for: previous)
        }
        streakDays = count
        lastStreakAnchorDay = latest
        persistStreakState()
    }

    private func persistStreakState() {
        defaults.set(streakDays, forKey: Keys.streakDays)
        if let anchor = lastStreakAnchorDay {
            defaults.set(anchor.timeIntervalSince1970, forKey: Keys.lastStreakAnchorDay)
        } else {
            defaults.removeObject(forKey: Keys.lastStreakAnchorDay)
        }
    }

    private func persistEntries() {
        if let data = try? JSONEncoder().encode(weatherEntries) {
            defaults.set(data, forKey: Keys.weatherEntries)
        }
    }

    private func persistFilterDateRange() {
        if let data = try? JSONEncoder().encode(filterDateRange) {
            defaults.set(data, forKey: Keys.filterDateRange)
        }
    }

    private func persistTrendSeries() {
        defaults.set(temperatureLogs, forKey: Keys.temperatureLogs)
        defaults.set(precipitationLogs, forKey: Keys.precipitationLogs)
        let timestamps = entryDates.map { $0.timeIntervalSince1970 }
        defaults.set(timestamps, forKey: Keys.entryDates)
    }

    private func persistTrendVisitDays() {
        let array = trendVisitDays.sorted()
        if let data = try? JSONEncoder().encode(array) {
            defaults.set(data, forKey: Keys.trendVisitDays)
        }
    }

    private func reconcileTrendSeriesFromEntries() {
        let sorted = weatherEntries.sorted { $0.date < $1.date }
        entryDates = sorted.map(\.date)
        temperatureLogs = sorted.map { Self.parseTemperature(from: $0.temperatureText) }
        precipitationLogs = sorted.map { Self.parsePrecipitation(from: $0.precipitationText) }
        persistTrendSeries()
    }

    private func reconcileTrendSeriesIfNeeded() {
        if temperatureLogs.isEmpty, precipitationLogs.isEmpty, entryDates.isEmpty, !weatherEntries.isEmpty {
            reconcileTrendSeriesFromEntries()
        }
    }

    private func refreshAchievementUnlocks() {
        var updated = achievementsUnlocked
        let now = Date()
        var newlyUnlockedTitles: [String] = []
        for achievement in AchievementDefinition.all {
            let unlocked = achievement.isUnlocked(
                itemsCreated: itemsCreated,
                streakDays: streakDays,
                sessionsCompleted: totalSessionsCompleted
            )
            if unlocked, updated[achievement.id] == nil {
                updated[achievement.id] = now
                newlyUnlockedTitles.append(achievement.title)
            }
        }
        if updated != achievementsUnlocked {
            achievementsUnlocked = updated
            if let data = try? JSONEncoder().encode(updated) {
                defaults.set(data, forKey: Keys.achievementsUnlocked)
            }
        }
        if !newlyUnlockedTitles.isEmpty {
            achievementBannerQueue.append(contentsOf: newlyUnlockedTitles)
        }
    }

    func consumeNextAchievementBanner() -> String? {
        guard !achievementBannerQueue.isEmpty else { return nil }
        let title = achievementBannerQueue.removeFirst()
        objectWillChange.send()
        return title
    }

    private static func dayKey(for date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: date)
    }

    private static func loadDate(key: String, defaults: UserDefaults) -> Date? {
        let value = defaults.double(forKey: key)
        guard value > 0 else { return nil }
        return Date(timeIntervalSince1970: value)
    }

    private static func loadDoubles(key: String, defaults: UserDefaults) -> [Double] {
        defaults.array(forKey: key) as? [Double] ?? []
    }

    private static func loadDates(key: String, defaults: UserDefaults) -> [Date] {
        let values = defaults.array(forKey: key) as? [Double] ?? []
        return values.map { Date(timeIntervalSince1970: $0) }
    }

    private static func parseTemperature(from text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = Set("0123456789.-")
        let filtered = trimmed.filter { allowed.contains($0) }
        return Double(filtered) ?? 0
    }

    private static func parsePrecipitation(from text: String) -> Double {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = Set("0123456789.-")
        let filtered = trimmed.filter { allowed.contains($0) }
        return Double(filtered) ?? 0
    }
}
