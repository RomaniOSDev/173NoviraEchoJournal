//
//  FeedbackHub.swift
//  173NoviraEchoJournal
//

import AudioToolbox
import UIKit

enum FeedbackHub {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func successPing() {
        AudioServicesPlaySystemSound(1057)
    }

    static func tick() {
        AudioServicesPlaySystemSound(1003)
    }

    static func logSavedChime() {
        AudioServicesPlaySystemSound(1104)
    }

    static func trendSavedChime() {
        AudioServicesPlaySystemSound(1103)
    }
}
