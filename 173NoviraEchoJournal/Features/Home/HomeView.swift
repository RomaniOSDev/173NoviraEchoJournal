//
//  HomeView.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: JournalStore
    @Binding var selectedTab: AppTab

    private var latestEntry: WeatherEntry? {
        store.weatherEntries.max(by: { $0.date < $1.date })
    }

    private var unlockedAchievementsCount: Int {
        AchievementDefinition.all.filter { achievement in
            achievement.isUnlocked(
                itemsCreated: store.itemsCreated,
                streakDays: store.streakDays,
                sessionsCompleted: store.totalSessionsCompleted
            )
        }.count
    }

    private let widgetColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    skyHeroCollage
                    greetingBlock

                    LazyVGrid(columns: widgetColumns, spacing: 12) {
                        homeWidgetCard(
                            title: "Streak",
                            subtitle: streakSubtitle,
                            systemImage: "flame.fill",
                            accent: Color.appAccent
                        ) {
                            FeedbackHub.tap()
                            selectedTab = .log
                        }

                        homeWidgetCard(
                            title: "Observations",
                            subtitle: "\(store.itemsCreated) saved",
                            systemImage: "list.bullet.clipboard.fill",
                            accent: Color.appPrimary
                        ) {
                            FeedbackHub.tap()
                            selectedTab = .journal
                        }

                        homeWidgetCard(
                            title: "Awards",
                            subtitle: "\(unlockedAchievementsCount) of \(AchievementDefinition.all.count)",
                            systemImage: "trophy.fill",
                            accent: Color.appAccent
                        ) {
                            FeedbackHub.tap()
                            selectedTab = .achievements
                        }

                        homeWidgetCard(
                            title: "Journal filter",
                            subtitle: filterSummaryLine,
                            systemImage: "line.3.horizontal.decrease.circle",
                            accent: Color.appPrimary
                        ) {
                            FeedbackHub.tap()
                            selectedTab = .journal
                        }
                    }

                    Text("Latest log")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    latestObservationWidget

                    Text("Shortcuts")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)

                    LazyVGrid(columns: widgetColumns, spacing: 12) {
                        shortcutTile(title: "New entry", systemImage: "plus.circle.fill", tint: Color.appPrimary) {
                            selectedTab = .log
                        }
                        shortcutTile(title: "History", systemImage: "clock.arrow.circlepath", tint: Color.appAccent) {
                            selectedTab = .journal
                        }
                        shortcutTile(title: "Trends", systemImage: "chart.line.uptrend.xyaxis", tint: Color.appPrimary) {
                            selectedTab = .journal
                        }
                        shortcutTile(title: "Settings", systemImage: "gearshape.fill", tint: Color.appTextSecondary) {
                            selectedTab = .settings
                        }
                    }

                    timeInAppStrip
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.visible)
            .background(LayeredAppBackground())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var greetingBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingLine)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(Date().formatted(date: .complete, time: .omitted))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .appCardBackground(cornerRadius: 18, style: .standard, elevation: .listItem)
    }

    private var skyHeroCollage: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.45),
                            Color.appSurface.opacity(0.92),
                            Color.appBackground.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.35), lineWidth: 1.5)
                )

            // Decorative “picture” layer — stacked SF Symbols (no bitmap assets required).
            ZStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 76, weight: .medium))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.35))
                    .offset(x: -110, y: -36)

                Image(systemName: "cloud.heavyrain.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(Color.appPrimary.opacity(0.4))
                    .offset(x: 40, y: -28)

                Image(systemName: "wind")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.appAccent.opacity(0.45))
                    .offset(x: 118, y: 8)

                Image(systemName: "humidity.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.appPrimary.opacity(0.35))
                    .offset(x: -90, y: 44)

                Image(systemName: "rainbow")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Color.appAccent.opacity(0.5))
                    .offset(x: 72, y: 52)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary.opacity(0.2))
                    .offset(x: -28, y: -58)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .allowsHitTesting(false)

            Text("Your sky dashboard")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appBackground.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.95),
                                    Color.appPrimary.opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 11, x: 0, y: 6)
    }

    private var latestObservationWidget: some View {
        Group {
            if let entry = latestEntry {
                Button {
                    FeedbackHub.tap()
                    selectedTab = .journal
                } label: {
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.appPrimary.opacity(0.2))
                            Image(systemName: WeatherConditionIcon.symbolName(for: entry.condition))
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(Color.appAccent)
                        }
                        .frame(width: 72, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.appAccent.opacity(0.4), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                            Text(entry.condition.isEmpty ? "No condition" : entry.condition)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(2)
                            HStack(spacing: 10) {
                                if !entry.temperatureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Label(entry.temperatureText, systemImage: "thermometer.medium")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.appPrimary)
                                }
                                if !entry.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Label(entry.locationLabel, systemImage: "mappin.and.ellipse")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(1)
                                }
                                if entry.temperatureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    && entry.locationLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Text("Open Journal for full details")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .appCardBackground(cornerRadius: 22, style: .standard, elevation: .raised)
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "square.and.pencil.circle.fill")
                        .font(.system(size: 48))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.appAccent, Color.appPrimary.opacity(0.45))
                    Text("No observations yet")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Open Log and capture your first sky snapshot.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                    Button {
                        FeedbackHub.tap()
                        selectedTab = .log
                    } label: {
                        Label("Open Log", systemImage: "arrow.right.circle.fill")
                            .font(.subheadline.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .appCardBackground(cornerRadius: 22, style: .rich, elevation: .raised)
            }
        }
    }

    private var timeInAppStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: "hourglass.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.appAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Time in app")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(store.totalMinutesUsed) min total")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer()
        }
        .padding(14)
        .appCardBackground(cornerRadius: 16, style: .deep, elevation: .listItem)
    }

    private func homeWidgetCard(
        title: String,
        subtitle: String,
        systemImage: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: systemImage)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(accent.opacity(0.22))
                    .offset(x: 6, y: -4)

                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(accent)
                    Text(title.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .appCardBackground(cornerRadius: 20, style: .standard, elevation: .raised)
        }
        .buttonStyle(.plain)
    }

    private func shortcutTile(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            FeedbackHub.tap()
            action()
        }) {
            VStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(height: 40)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .appCardBackground(cornerRadius: 18, style: .standard, elevation: .listItem)
        }
        .buttonStyle(.plain)
    }

    private var greetingLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let tail = store.itemsCreated == 0 ? "Ready when you are." : "Here is your snapshot."
        switch hour {
        case 5 ..< 12:
            return "Good morning — \(tail)"
        case 12 ..< 17:
            return "Good afternoon — \(tail)"
        case 17 ..< 22:
            return "Good evening — \(tail)"
        default:
            return "Hello — \(tail)"
        }
    }

    private var streakSubtitle: String {
        let s = store.streakDays
        if s <= 0 { return "Start today" }
        if s == 1 { return "1 day" }
        return "\(s) days"
    }

    private var filterSummaryLine: String {
        switch store.filterDateRange {
        case .allTime:
            return "All time"
        case .lastSevenDays:
            return "Last 7 days"
        case .lastThirtyDays:
            return "Last 30 days"
        case let .custom(start, end):
            let a = start.formatted(date: .abbreviated, time: .omitted)
            let b = end.formatted(date: .abbreviated, time: .omitted)
            return "\(a) – \(b)"
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(JournalStore())
}
