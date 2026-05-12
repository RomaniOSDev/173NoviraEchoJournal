//
//  LayeredAppBackground.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct LayeredAppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appSurface.opacity(0.55),
                    Color.appBackground.opacity(0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.appPrimary.opacity(0.1),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 420
            )
            .allowsHitTesting(false)

            Canvas { context, size in
                let spacing: CGFloat = 40
                var path = Path()
                var x: CGFloat = 0
                while x < size.width + spacing {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + size.height, y: size.height))
                    x += spacing
                }
                context.stroke(
                    path,
                    with: .color(Color.appTextPrimary.opacity(0.035)),
                    lineWidth: 1
                )
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
