//
//  WeatherEntryEditorSheet.swift
//  173NoviraEchoJournal
//

import SwiftUI
import UIKit

struct WeatherEntryEditorSheet: View {
    @Binding var draft: WeatherEntry
    let isNew: Bool
    let onSave: (WeatherEntry) -> Void
    let onCancel: () -> Void

    @State private var shakeAmount: CGFloat = 0
    @State private var validationMessage: String?

    private static let skyOptions: [String] = [
        "", "Clear", "Mostly clear", "Partly cloudy", "Overcast", "Foggy", "Stormy"
    ]

    private static let comfortOptions: [String] = [
        "", "Chilly", "Cool", "Mild", "Warm", "Hot", "Humid", "Dry"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        editorHero

                        editorCard(title: "When", subtitle: "Pick the moment you observed the sky.", systemImage: "clock") {
                            DatePicker(
                                "Date & time",
                                selection: $draft.date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .foregroundStyle(Color.appTextPrimary)
                            .tint(Color.appPrimary)
                        }

                        editorCard(title: "Core readings", subtitle: "Temperature, headline condition, and rain or snow.", systemImage: "thermometer.medium") {
                            labeledField(
                                "Temperature",
                                placeholder: "e.g. 22 °C or 72 °F",
                                text: $draft.temperatureText,
                                keyboard: .numbersAndPunctuation
                            )
                            labeledField(
                                "Conditions",
                                placeholder: "e.g. breezy, hazy sunrise",
                                text: $draft.condition,
                                keyboard: .default
                            )
                            labeledField(
                                "Precipitation",
                                placeholder: "mm, intensity, or type",
                                text: $draft.precipitationText,
                                keyboard: .decimalPad
                            )
                        }

                        editorCard(title: "Sky & comfort", subtitle: "How it looked and felt at a glance.", systemImage: "cloud.sun.fill") {
                            menuPickerRow(
                                label: "Sky cover",
                                value: draft.skyCover,
                                options: Self.skyOptions,
                                display: skyDisplayLabel
                            ) { draft.skyCover = $0 }

                            menuPickerRow(
                                label: "Comfort",
                                value: draft.comfortTag,
                                options: Self.comfortOptions,
                                display: comfortDisplayLabel
                            ) { draft.comfortTag = $0 }
                        }

                        editorCard(title: "Air & visibility", subtitle: "Wind, moisture, and how far you could see.", systemImage: "wind") {
                            labeledField(
                                "Wind",
                                placeholder: "speed, gusts, direction",
                                text: $draft.windText,
                                keyboard: .default
                            )
                            labeledField(
                                "Humidity",
                                placeholder: "percent or “sticky”",
                                text: $draft.humidityText,
                                keyboard: .numbersAndPunctuation
                            )
                            labeledField(
                                "Visibility",
                                placeholder: "km, miles, or “low”",
                                text: $draft.visibilityText,
                                keyboard: .default
                            )
                        }

                        editorCard(title: "Place", subtitle: "Optional label — balcony, trail, city block.", systemImage: "mappin.and.ellipse") {
                            labeledField(
                                "Location label",
                                placeholder: "Where you were",
                                text: $draft.locationLabel,
                                keyboard: .default,
                                autocapitalization: .words
                            )
                        }

                        editorCard(title: "Notes", subtitle: "Story, smells, sounds, or anything memorable.", systemImage: "note.text") {
                            TextField("Your notes", text: $draft.notes, axis: .vertical)
                                .lineLimit(4, reservesSpace: true)
                                .font(.body)
                                .foregroundStyle(Color.appTextPrimary)
                                .tint(Color.appPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 11)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.appSurface.opacity(0.45),
                                                    Color.appBackground.opacity(0.55)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
                                )
                                .shake(trigger: shakeAmount)
                        }

                        if let validationMessage {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(Color.red.opacity(0.9))
                                Text(validationMessage)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.appSurface.opacity(0.82),
                                                Color.appSurface.opacity(0.62)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.visible)
            }
            .navigationTitle(isNew ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appSurface.opacity(0.92), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackHub.tap()
                        onCancel()
                    }
                    .foregroundStyle(Color.appTextPrimary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        attemptSave()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }

    private var editorHero: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.38),
                                Color.appSurface.opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 58, height: 58)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(isNew ? "Log a new observation" : "Update this observation")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("Temperature, sky, air, place, and notes — fill what matters to you.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .appCardBackground(cornerRadius: 22, style: .rich, elevation: .raised)
    }

    private func editorCard<Content: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 14) {
                content()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 20, style: .standard, elevation: .listItem)
    }

    private func labeledField(
        _ label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            TextField(placeholder, text: text)
                .font(.body)
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .foregroundStyle(Color.appTextPrimary)
                .tint(Color.appPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.45),
                                    Color.appBackground.opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
                )
                .shake(trigger: shakeAmount)
        }
    }

    private func menuPickerRow(
        label: String,
        value: String,
        options: [String],
        display: @escaping (String) -> String,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Menu {
                ForEach(options, id: \.self) { opt in
                    Button(display(opt)) {
                        onSelect(opt)
                    }
                }
            } label: {
                HStack {
                    Text(display(value))
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appSurface.opacity(0.45),
                                    Color.appBackground.opacity(0.55)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.12), lineWidth: 1)
                )
            }
        }
    }

    private func skyDisplayLabel(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "Not specified" }
        return t
    }

    private func comfortDisplayLabel(_ raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "Not specified" }
        return t
    }

    private func attemptSave() {
        if !hasAnyMeaningfulContent {
            FeedbackHub.warning()
            validationMessage = "Add at least one detail before saving."
            withAnimation(.easeInOut(duration: 0.2)) {
                shakeAmount += 1
            }
            return
        }

        validationMessage = nil
        onSave(draft)
    }

    private var hasAnyMeaningfulContent: Bool {
        let fields = [
            draft.temperatureText,
            draft.condition,
            draft.notes,
            draft.precipitationText,
            draft.locationLabel,
            draft.windText,
            draft.humidityText,
            draft.visibilityText,
            draft.skyCover,
            draft.comfortTag
        ]
        return fields.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
