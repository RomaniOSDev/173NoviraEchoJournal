//
//  AppTab.swift
//  173NoviraEchoJournal
//

import Foundation

enum AppTab: Int, CaseIterable, Hashable {
    case home
    case log
    case journal
    case achievements
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .log: return "Log"
        case .journal: return "Journal"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .log: return "cloud.sun.fill"
        case .journal: return "book.pages.fill"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
