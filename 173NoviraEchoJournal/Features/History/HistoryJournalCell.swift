//
//  HistoryJournalCell.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct HistoryJournalCell: View {
    let entry: WeatherEntry

    private var timeString: String {
        entry.date.formatted(date: .omitted, time: .shortened)
    }

    private var conditionDisplay: String {
        let trimmed = entry.condition.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No condition set" : trimmed
    }

    private var notesPreview: String? {
        let trimmed = entry.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var precipPreview: String? {
        let trimmed = entry.precipitationText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private var metaLine: String? {
        var parts: [String] = []
        let loc = entry.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !loc.isEmpty { parts.append(loc) }
        let sky = entry.skyCover.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sky.isEmpty { parts.append(sky) }
        let wind = entry.windText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !wind.isEmpty { parts.append("Wind \(wind)") }
        let comfort = entry.comfortTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !comfort.isEmpty { parts.append(comfort) }
        if parts.isEmpty { return nil }
        return parts.joined(separator: " · ")
    }

    private var tempPreview: String? {
        let trimmed = entry.temperatureText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.22),
                                Color.appSurface.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: WeatherConditionIcon.symbolName(for: entry.condition))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 52, height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    Text(timeString)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.appPrimary.opacity(0.16))
                        )

                    Spacer(minLength: 4)

                    if let tempPreview {
                        Text(tempPreview)
                            .font(.subheadline.monospacedDigit().weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(
                                Capsule()
                                    .stroke(Color.appAccent.opacity(0.55), lineWidth: 1.5)
                            )
                    }
                }

                Text(conditionDisplay)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                if let metaLine {
                    Text(metaLine)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }

                if let notesPreview {
                    Text(notesPreview)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                if let precipPreview {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                        Text(precipPreview)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
        .padding(14)
        .appCardBackground(cornerRadius: 20, style: .standard, elevation: .listItem)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        var parts: [String] = [timeString, conditionDisplay]
        if let tempPreview {
            parts.append("Temperature \(tempPreview)")
        }
        if let notesPreview {
            parts.append(notesPreview)
        }
        return parts.joined(separator: ", ")
    }
}
