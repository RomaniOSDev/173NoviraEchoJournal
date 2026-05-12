//
//  TabBarHeightPreferenceKey.swift
//  173NoviraEchoJournal
//

import SwiftUI

enum TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 96

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let next = nextValue()
        if next > 0 {
            value = next
        }
    }
}
