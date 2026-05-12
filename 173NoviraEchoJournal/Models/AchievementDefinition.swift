//
//  AchievementDefinition.swift
//  173NoviraEchoJournal
//

import Foundation

struct AchievementDefinition: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String

    func isUnlocked(itemsCreated: Int, streakDays: Int, sessionsCompleted: Int) -> Bool {
        switch id {
        case "first_entry":
            return itemsCreated >= 1
        case "daily_logger":
            return streakDays >= 7
        case "committed_recorder":
            return streakDays >= 30
        case "weather_enthusiast":
            return itemsCreated >= 10
        case "climate_tracker":
            return sessionsCompleted >= 50
        case "observation_master":
            return streakDays >= 90
        case "dedicated_analyst":
            return sessionsCompleted >= 50
        case "consistent_contributor":
            return itemsCreated >= 100
        default:
            return false
        }
    }

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_entry", title: "First Entry", description: "Logged the first weather observation."),
        AchievementDefinition(id: "daily_logger", title: "Daily Logger", description: "Logged observations for a week."),
        AchievementDefinition(id: "committed_recorder", title: "Committed Recorder", description: "Maintained daily logs for a month."),
        AchievementDefinition(id: "weather_enthusiast", title: "Weather Enthusiast", description: "Created ten detailed entries."),
        AchievementDefinition(id: "climate_tracker", title: "Climate Tracker", description: "Completed fifty sessions reviewing trends."),
        AchievementDefinition(id: "observation_master", title: "Observation Master", description: "Kept up logging every day for three months."),
        AchievementDefinition(id: "dedicated_analyst", title: "Dedicated Analyst", description: "Analyzed trends over fifty separate days."),
        AchievementDefinition(id: "consistent_contributor", title: "Consistent Contributor", description: "Recorded one hundred weather entries.")
    ]
}
