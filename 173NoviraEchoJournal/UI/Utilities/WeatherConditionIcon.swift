//
//  WeatherConditionIcon.swift
//  173NoviraEchoJournal
//

import SwiftUI

enum WeatherConditionIcon {
    static func symbolName(for condition: String) -> String {
        let lower = condition.lowercased()
        if lower.contains("snow") { return "cloud.snow.fill" }
        if lower.contains("storm") || lower.contains("thunder") { return "cloud.bolt.rain.fill" }
        if lower.contains("rain") || lower.contains("drizzle") { return "cloud.rain.fill" }
        if lower.contains("fog") || lower.contains("mist") { return "cloud.fog.fill" }
        if lower.contains("wind") { return "wind" }
        if lower.contains("sun") || lower.contains("clear") { return "sun.max.fill" }
        if lower.contains("cloud") { return "cloud.fill" }
        if lower.contains("hot") { return "thermometer.sun.fill" }
        if lower.contains("cold") { return "thermometer.snowflake" }
        return "cloud.sun.fill"
    }
}
