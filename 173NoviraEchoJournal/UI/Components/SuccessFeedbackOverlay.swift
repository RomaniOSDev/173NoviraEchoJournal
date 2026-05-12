//
//  SuccessFeedbackOverlay.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct SuccessFeedbackOverlay: View {
    let isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.18))
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }
}

struct RowPulseModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.appAccent.opacity(isActive ? 0.35 : 0))
                    .animation(.easeInOut(duration: 0.4), value: isActive)
            )
    }
}

extension View {
    func rowPulse(_ active: Bool) -> some View {
        modifier(RowPulseModifier(isActive: active))
    }
}
