//
//  AppExternalLink.swift
//  173NoviraEchoJournal
//

import Foundation

/// Central place for outbound URLs (privacy, terms, etc.).
enum AppExternalLink: String, CaseIterable {
    case privacyPolicy = "https://noviraechojournal173.site/privacy/178"
    case termsOfUse = "https://noviraechojournal173.site/terms/178"

    var url: URL? {
        URL(string: rawValue)
    }
}
