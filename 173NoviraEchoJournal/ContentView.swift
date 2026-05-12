//
//  ContentView.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = JournalStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var activeSessionStart: Date?

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if store.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }

            AchievementBannerHost()
                .padding(.top, 8)
        }
        .environmentObject(store)
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                activeSessionStart = Date()
            case .background:
                if let start = activeSessionStart {
                    let seconds = Int(Date().timeIntervalSince(start))
                    store.addForegroundTime(seconds)
                }
                activeSessionStart = nil
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onAppear {
            if scenePhase == .active {
                activeSessionStart = Date()
            }
        }
    }
}

#Preview {
    ContentView()
}
