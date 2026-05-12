//
//  WeatherEntryDetailView.swift
//  173NoviraEchoJournal
//

import SwiftUI
import UIKit

struct WeatherEntryDetailView: View {
    let entry: WeatherEntry

    @EnvironmentObject private var store: JournalStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditor = false
    @State private var draft = WeatherEntry()
    @State private var showingShare = false
    @State private var showDeleteConfirm = false
    @State private var showCopiedHint = false

    private var live: WeatherEntry {
        store.weatherEntries.first(where: { $0.id == entry.id }) ?? entry
    }

    private var notesTrimmed: String {
        live.notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var heroLocationText: String {
        live.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var relativeRecorded: String {
        RelativeDateTimeFormatter().localizedString(for: live.date, relativeTo: Date())
    }

    private var sharePlainText: String {
        func line(_ label: String, _ value: String) -> String {
            let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return "\(label): \(v.isEmpty ? "—" : v)"
        }

        var lines: [String] = ["Weather observation", ""]
        lines.append(line("Date", live.date.formatted(date: .long, time: .shortened)))
        lines.append(line("Location", live.locationLabel))
        lines.append(line("Temperature", live.temperatureText))
        lines.append(line("Conditions", live.condition))
        lines.append(line("Precipitation", live.precipitationText))
        lines.append(line("Sky cover", live.skyCover))
        lines.append(line("Comfort", live.comfortTag))
        lines.append(line("Wind", live.windText))
        lines.append(line("Humidity", live.humidityText))
        lines.append(line("Visibility", live.visibilityText))
        if !notesTrimmed.isEmpty {
            lines.append("")
            lines.append("Notes:")
            lines.append(notesTrimmed)
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader
                quickStatsRow
                detailCard(
                    title: "When & place",
                    systemImage: "calendar",
                    rows: [
                        ("Date & time", live.date.formatted(date: .complete, time: .shortened)),
                        ("Recorded", relativeRecorded),
                        ("Location", live.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.locationLabel),
                        ("Comfort", live.comfortTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.comfortTag),
                        ("Sky cover", live.skyCover.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.skyCover)
                    ]
                )
                detailCard(
                    title: "Readings",
                    systemImage: "cloud.sun.fill",
                    rows: [
                        ("Temperature", live.temperatureText.isEmpty ? "Not set" : live.temperatureText),
                        ("Conditions", live.condition.isEmpty ? "Not set" : live.condition),
                        ("Precipitation", live.precipitationText.isEmpty ? "Not set" : live.precipitationText),
                        ("Wind", live.windText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.windText),
                        ("Humidity", live.humidityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.humidityText),
                        ("Visibility", live.visibilityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not set" : live.visibilityText)
                    ]
                )
                notesCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.visible)
        .scrollContentBackground(.hidden)
        .background(LayeredAppBackground())
        .navigationTitle("Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        FeedbackHub.tap()
                        draft = duplicate(live)
                        showingEditor = true
                    } label: {
                        Label("Edit entry", systemImage: "pencil")
                    }

                    Button {
                        FeedbackHub.tap()
                        copySummary()
                    } label: {
                        Label("Copy summary", systemImage: "doc.on.doc")
                    }

                    Button {
                        FeedbackHub.tap()
                        showingShare = true
                    } label: {
                        Label("Share…", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button(role: .destructive) {
                        FeedbackHub.tap()
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete entry", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Entry actions")
            }
        }
        .sheet(isPresented: $showingEditor) {
            WeatherEntryEditorSheet(
                draft: $draft,
                isNew: false,
                onSave: { saved in
                    FeedbackHub.mediumImpact()
                    FeedbackHub.logSavedChime()
                    FeedbackHub.success()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                        store.saveEntry(saved, isNew: false)
                    }
                    showingEditor = false
                },
                onCancel: {
                    showingEditor = false
                }
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingShare) {
            ShareTextSheet(text: sharePlainText)
        }
        .alert("Delete this entry?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {
                FeedbackHub.tap()
            }
            Button("Delete", role: .destructive) {
                FeedbackHub.mediumImpact()
                store.deleteEntry(id: live.id)
                dismiss()
            }
        } message: {
            Text("This observation will be removed from your journal and trends.")
        }
        .overlay(alignment: .top) {
            if showCopiedHint {
                Text("Copied to clipboard")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appBackground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appPrimary,
                                        Color.appPrimary.opacity(0.88)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: showCopiedHint)
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.35),
                                    Color.appSurface.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: WeatherConditionIcon.symbolName(for: live.condition))
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }
                .frame(width: 88, height: 88)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.4), lineWidth: 1.5)
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(live.date.formatted(.dateTime.weekday(.wide).month().day().year()))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(live.date.formatted(date: .omitted, time: .shortened))
                        .font(.title2.monospacedDigit().weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(relativeRecorded)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.appPrimary)

                    if !heroLocationText.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption.weight(.semibold))
                            Text(heroLocationText)
                                .font(.caption.weight(.medium))
                                .lineLimit(2)
                        }
                        .foregroundStyle(Color.appTextSecondary)
                    }
                }
                Spacer(minLength: 0)
            }

            if !live.temperatureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(live.temperatureText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("logged")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 24, style: .rich, elevation: .prominent)
    }

    private var quickStatsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                statChip(
                    title: "Conditions",
                    value: conditionChipValue,
                    systemImage: "cloud.sun.fill"
                )
                statChip(
                    title: "Precipitation",
                    value: live.precipitationText.isEmpty ? "—" : live.precipitationText,
                    systemImage: "drop.fill"
                )
                statChip(
                    title: "Notes",
                    value: notesTrimmed.isEmpty ? "None" : "\(notesTrimmed.count) chars",
                    systemImage: "note.text"
                )
            }
            if !secondaryStatsChips.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(secondaryStatsChips, id: \.title) { chip in
                            statChip(title: chip.title, value: chip.value, systemImage: chip.icon)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var secondaryStatsChips: [(title: String, value: String, icon: String)] {
        var out: [(String, String, String)] = []
        let loc = live.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !loc.isEmpty { out.append(("Location", loc, "mappin.and.ellipse")) }
        let sky = live.skyCover.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sky.isEmpty { out.append(("Sky", sky, "cloud.fill")) }
        let comfort = live.comfortTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !comfort.isEmpty { out.append(("Comfort", comfort, "hand.raised.fill")) }
        let wind = live.windText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !wind.isEmpty { out.append(("Wind", wind, "wind")) }
        let hum = live.humidityText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !hum.isEmpty { out.append(("Humidity", hum, "humidity.fill")) }
        let vis = live.visibilityText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !vis.isEmpty { out.append(("Visibility", vis, "eye.fill")) }
        return out
    }

    private func statChip(title: String, value: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appAccent)
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appCardBackground(cornerRadius: 16, style: .standard, elevation: .listItem)
    }

    private func detailCard(title: String, systemImage: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.appPrimary)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    detailRow(label: row.0, value: row.1)
                    if index < rows.count - 1 {
                        Divider()
                            .background(Color.appAccent.opacity(0.2))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 20, style: .standard, elevation: .raised)
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .foregroundStyle(Color.appAccent)
                Text("Notes")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            if notesTrimmed.isEmpty {
                Text("No notes were added for this entry.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .italic()
            } else {
                Text(notesTrimmed)
                    .font(.body)
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 20, style: .deep, elevation: .raised)
    }

    private var conditionChipValue: String {
        let c = live.condition.trimmingCharacters(in: .whitespacesAndNewlines)
        if c.isEmpty { return "—" }
        if c.count <= 28 { return c }
        return String(c.prefix(28)) + "…"
    }

    private func duplicate(_ source: WeatherEntry) -> WeatherEntry {
        WeatherEntry(
            id: source.id,
            date: source.date,
            temperatureText: source.temperatureText,
            condition: source.condition,
            notes: source.notes,
            precipitationText: source.precipitationText,
            locationLabel: source.locationLabel,
            windText: source.windText,
            humidityText: source.humidityText,
            visibilityText: source.visibilityText,
            skyCover: source.skyCover,
            comfortTag: source.comfortTag
        )
    }

    private func copySummary() {
        UIPasteboard.general.string = sharePlainText
        FeedbackHub.success()
        FeedbackHub.successPing()
        showCopiedHint = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                showCopiedHint = false
            }
        }
    }
}

// MARK: - Share sheet (UIKit)

private struct ShareTextSheet: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
