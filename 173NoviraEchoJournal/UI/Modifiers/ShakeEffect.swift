//
//  ShakeEffect.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 6
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakesPerUnit), y: 0)
        )
    }
}

extension View {
    func shake(trigger: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: trigger))
    }
}
