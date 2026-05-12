//
//  MainTabView.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var tabBarHeight: CGFloat = TabBarHeightPreferenceKey.defaultValue

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground
                .ignoresSafeArea()
                .allowsHitTesting(false)

            Color.appSurface.opacity(0.94)
                .frame(height: tabBarHeight + 56)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .log:
                    Feature1View()
                case .journal:
                    JournalHubView()
                case .achievements:
                    AchievementsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, tabBarHeight)

            customTabBar
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: TabBarHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                    }
                )
        }
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            tabBarHeight = max(height, 72)
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    FeedbackHub.tap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                    .foregroundStyle(selectedTab == tab ? Color.appBackground : Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectedTab == tab ? Color.appPrimary : Color.clear)
                    )
                }
                .buttonStyle(ScaleOnPressButtonStyle())
                .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .appFloatingPanelBackground(cornerRadius: 22)
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }
}
