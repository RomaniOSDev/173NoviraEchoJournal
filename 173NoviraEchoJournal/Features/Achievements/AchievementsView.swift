//
//  AchievementsView.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: JournalStore
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { achievement in
            achievement.isUnlocked(
                itemsCreated: store.itemsCreated,
                streakDays: store.streakDays,
                sessionsCompleted: store.totalSessionsCompleted
            )
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heroHeader
                    summaryStrip
                    badgesSectionHeader
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(AchievementDefinition.all.enumerated()), id: \.element.id) { index, achievement in
                            achievementBadgeCard(achievement, index: index)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .scrollIndicators(.visible)
            .background(LayeredAppBackground())
            .navigationTitle("Achievements")
        }
    }

    private var heroHeader: some View {
        HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.appPrimary.opacity(0.55),
                                Color.appSurface.opacity(0.9)
                            ],
                            center: .topLeading,
                            startRadius: 8,
                            endRadius: 56
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(Color.appAccent.opacity(0.45), lineWidth: 2)
                    )
                Image(systemName: "trophy.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Milestones")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .textCase(.uppercase)
                Text("Track your journal progress")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Text("\(unlockedCount) of 8 unlocked")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                    progressDots
                }
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 24, style: .rich, elevation: .prominent)
    }

    private var progressDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(index < unlockedCount ? Color.appPrimary : Color.appTextSecondary.opacity(0.25))
                    .frame(width: index < unlockedCount ? 8 : 6, height: index < unlockedCount ? 8 : 6)
            }
        }
        .accessibilityLabel("\(unlockedCount) of 8 achievements unlocked")
    }

    private var summaryStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Live stats")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 10) {
                summaryMiniCard(
                    icon: "square.stack.3d.up.fill",
                    title: "Entries",
                    value: "\(store.itemsCreated)",
                    accent: Color.appPrimary
                )
                summaryMiniCard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(store.streakDays)d",
                    accent: Color.appAccent
                )
                summaryMiniCard(
                    icon: "chart.xyaxis.line",
                    title: "Trend days",
                    value: "\(store.totalSessionsCompleted)",
                    accent: Color.appPrimary
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 20, style: .standard, elevation: .raised)
    }

    private func summaryMiniCard(icon: String, title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(accent)
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appCardBackground(cornerRadius: 16, style: .deep, elevation: .listItem)
    }

    private var badgesSectionHeader: some View {
        HStack(spacing: 10) {
            Image(systemName: "medal.fill")
                .foregroundStyle(Color.appAccent)
            Text("Badges")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Rectangle()
                .fill(Color.appAccent.opacity(0.35))
                .frame(height: 2)
        }
    }

    private func achievementBadgeCard(_ achievement: AchievementDefinition, index: Int) -> some View {
        let unlocked = achievement.isUnlocked(
            itemsCreated: store.itemsCreated,
            streakDays: store.streakDays,
            sessionsCompleted: store.totalSessionsCompleted
        )
        let hint = lockedProgressHint(for: achievement, unlocked: unlocked)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(badgeCircleFill(unlocked: unlocked))
                        .frame(width: 52, height: 52)
                    Image(systemName: badgeIcon(for: achievement.id))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary.opacity(0.7))
                    if !unlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(5)
                            .background(Circle().fill(Color.appBackground.opacity(0.7)))
                            .offset(x: 18, y: 16)
                    }
                }

                Spacer(minLength: 0)

                if unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appPrimary)
                }
            }

            Text(achievement.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if let hint {
                Text(hint)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.appPrimary.opacity(0.12))
                    )
            } else if unlocked, let date = store.achievementUnlockedDate(for: achievement.id) {
                Text("Unlocked \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.appAccent)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
        .appCardBackground(
            cornerRadius: 20,
            style: unlocked ? .standard : .muted,
            elevation: .listItem
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(badgeStroke(unlocked: unlocked), lineWidth: unlocked ? 1.5 : 1)
        )
        .opacity(unlocked ? 1 : 0.92)
        .animation(.spring(response: 0.45, dampingFraction: 0.78).delay(Double(index) * 0.04), value: unlocked)
    }

    private func badgeCircleFill(unlocked: Bool) -> some ShapeStyle {
        if unlocked {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.35), Color.appSurface.opacity(0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(Color.appSurface.opacity(0.5))
    }

    private func badgeStroke(unlocked: Bool) -> some ShapeStyle {
        if unlocked {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.55), Color.appAccent.opacity(0.35)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(
            LinearGradient(
                colors: [Color.appTextSecondary.opacity(0.12), Color.appTextSecondary.opacity(0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func badgeIcon(for id: String) -> String {
        switch id {
        case "first_entry":
            return "pencil.and.list.clipboard"
        case "daily_logger":
            return "calendar"
        case "committed_recorder":
            return "calendar.badge.clock"
        case "weather_enthusiast":
            return "cloud.sun.bolt.fill"
        case "climate_tracker":
            return "chart.line.uptrend.xyaxis"
        case "observation_master":
            return "crown.fill"
        case "dedicated_analyst":
            return "binoculars.fill"
        case "consistent_contributor":
            return "square.stack.3d.up.fill"
        default:
            return "star.fill"
        }
    }

    private func lockedProgressHint(for achievement: AchievementDefinition, unlocked: Bool) -> String? {
        guard !unlocked else { return nil }
        switch achievement.id {
        case "first_entry":
            return store.itemsCreated > 0 ? nil : "Save 1 observation"
        case "daily_logger":
            return "\(min(store.streakDays, 7))/7 streak days"
        case "committed_recorder":
            return "\(min(store.streakDays, 30))/30 streak days"
        case "weather_enthusiast":
            return "\(min(store.itemsCreated, 10))/10 entries"
        case "climate_tracker", "dedicated_analyst":
            return "\(min(store.totalSessionsCompleted, 50))/50 trend days"
        case "observation_master":
            return "\(min(store.streakDays, 90))/90 streak days"
        case "consistent_contributor":
            return "\(min(store.itemsCreated, 100))/100 entries"
        default:
            return nil
        }
    }
}
