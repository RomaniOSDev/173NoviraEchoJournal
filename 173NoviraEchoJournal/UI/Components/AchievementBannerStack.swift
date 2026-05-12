//
//  AchievementBannerStack.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct AchievementBannerHost: View {
    @EnvironmentObject private var store: JournalStore
    @State private var currentTitle: String?
    @State private var offset: CGFloat = -200

    var body: some View {
        VStack(spacing: 4) {
            if let title = currentTitle {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.appTextSecondary)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .appCardBackground(cornerRadius: 18, style: .rich, elevation: .raised)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .allowsHitTesting(offset > -80)
        .onAppear {
            pumpQueueIfIdle()
        }
        .onChange(of: store.achievementBannerQueue.count) { _ in
            pumpQueueIfIdle()
        }
    }

    private func pumpQueueIfIdle() {
        guard currentTitle == nil else { return }
        guard let title = store.consumeNextAchievementBanner() else { return }
        present(title)
    }

    private func present(_ title: String) {
        currentTitle = title
        withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
            offset = 12
        }
        FeedbackHub.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.35)) {
                offset = -200
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                currentTitle = nil
                pumpQueueIfIdle()
            }
        }
    }
}
