//
//  WeatherEntry.swift
//  173NoviraEchoJournal
//

import Foundation

struct WeatherEntry: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var date: Date
    var temperatureText: String
    var condition: String
    var notes: String
    var precipitationText: String
    var locationLabel: String
    var windText: String
    var humidityText: String
    var visibilityText: String
    var skyCover: String
    var comfortTag: String

    enum CodingKeys: String, CodingKey {
        case id, date, temperatureText, condition, notes, precipitationText
        case locationLabel, windText, humidityText, visibilityText, skyCover, comfortTag
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        temperatureText: String = "",
        condition: String = "",
        notes: String = "",
        precipitationText: String = "",
        locationLabel: String = "",
        windText: String = "",
        humidityText: String = "",
        visibilityText: String = "",
        skyCover: String = "",
        comfortTag: String = ""
    ) {
        self.id = id
        self.date = date
        self.temperatureText = temperatureText
        self.condition = condition
        self.notes = notes
        self.precipitationText = precipitationText
        self.locationLabel = locationLabel
        self.windText = windText
        self.humidityText = humidityText
        self.visibilityText = visibilityText
        self.skyCover = skyCover
        self.comfortTag = comfortTag
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        temperatureText = try container.decodeIfPresent(String.self, forKey: .temperatureText) ?? ""
        condition = try container.decodeIfPresent(String.self, forKey: .condition) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        precipitationText = try container.decodeIfPresent(String.self, forKey: .precipitationText) ?? ""
        locationLabel = try container.decodeIfPresent(String.self, forKey: .locationLabel) ?? ""
        windText = try container.decodeIfPresent(String.self, forKey: .windText) ?? ""
        humidityText = try container.decodeIfPresent(String.self, forKey: .humidityText) ?? ""
        visibilityText = try container.decodeIfPresent(String.self, forKey: .visibilityText) ?? ""
        skyCover = try container.decodeIfPresent(String.self, forKey: .skyCover) ?? ""
        comfortTag = try container.decodeIfPresent(String.self, forKey: .comfortTag) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(temperatureText, forKey: .temperatureText)
        try container.encode(condition, forKey: .condition)
        try container.encode(notes, forKey: .notes)
        try container.encode(precipitationText, forKey: .precipitationText)
        try container.encode(locationLabel, forKey: .locationLabel)
        try container.encode(windText, forKey: .windText)
        try container.encode(humidityText, forKey: .humidityText)
        try container.encode(visibilityText, forKey: .visibilityText)
        try container.encode(skyCover, forKey: .skyCover)
        try container.encode(comfortTag, forKey: .comfortTag)
    }

    var observationSummary: String {
        let parts = [
            condition.trimmingCharacters(in: .whitespacesAndNewlines),
            notes.trimmingCharacters(in: .whitespacesAndNewlines),
            locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        ].filter { !$0.isEmpty }
        if parts.isEmpty {
            return "No observation text"
        }
        return parts.joined(separator: " · ")
    }
}
