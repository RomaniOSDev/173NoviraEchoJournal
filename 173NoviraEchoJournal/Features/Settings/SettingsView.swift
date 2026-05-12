//
//  SettingsView.swift
//  173NoviraEchoJournal
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: JournalStore
    @State private var showingResetAlert = false

    private var versionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    statsCard
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                Section {
                    Button {
                        FeedbackHub.tap()
                        rateApp()
                    } label: {
                        settingsRowLabel(title: "Rate us", systemImage: "star.fill", trailing: "chevron.right")
                    }
                    .frame(minHeight: 44)

                    Button {
                        FeedbackHub.tap()
                        openURL(AppExternalLink.privacyPolicy)
                    } label: {
                        settingsRowLabel(title: "Privacy", systemImage: "hand.raised.fill", trailing: "arrow.up.right")
                    }
                    .frame(minHeight: 44)

                    Button {
                        FeedbackHub.tap()
                        openURL(AppExternalLink.termsOfUse)
                    } label: {
                        settingsRowLabel(title: "Terms", systemImage: "doc.text.fill", trailing: "arrow.up.right")
                    }
                    .frame(minHeight: 44)
                } header: {
                    Text("App")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .listRowBackground(Color.appSurface.opacity(0.55))

                Section {
                    Button {
                        FeedbackHub.tap()
                        openSupportEmail()
                    } label: {
                        settingsRowLabel(title: "Support", systemImage: "envelope.fill", trailing: "chevron.right")
                    }
                    .frame(minHeight: 44)
                } header: {
                    Text("Help")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                }
                .listRowBackground(Color.appSurface.opacity(0.55))

                Section {
                    Button(role: .destructive) {
                        FeedbackHub.tap()
                        showingResetAlert = true
                    } label: {
                        Text("Reset All Data")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 6)
                    }
                    .frame(minHeight: 44)
                }
                .listRowBackground(Color.appSurface.opacity(0.55))

                Section {
                    Text("Version \(versionText)")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(LayeredAppBackground())
            .navigationTitle("Settings")
            .alert("Reset all data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackHub.tap()
                }
                Button("Reset", role: .destructive) {
                    FeedbackHub.mediumImpact()
                    store.resetAllData()
                }
            } message: {
                Text("This removes all saved observations, achievements, and settings on this device.")
            }
        }
    }

    private func settingsRowLabel(title: String, systemImage: String, trailing: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 28, alignment: .center)
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: trailing)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, 6)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                statBlock(title: "Entries", value: "\(store.itemsCreated)")
                Spacer()
                statBlock(title: "Minutes", value: "\(store.totalMinutesUsed)")
                Spacer()
                statBlock(title: "Streak", value: "\(store.streakDays)d")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 18, style: .rich, elevation: .raised)
    }

    private func statBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(Color.appPrimary)
        }
    }

    private func openURL(_ link: AppExternalLink) {
        if let url = link.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openSupportEmail() {
        guard let url = URL(string: "mailto:support@example.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
