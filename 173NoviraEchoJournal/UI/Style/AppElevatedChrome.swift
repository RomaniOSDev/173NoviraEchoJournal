//
//  AppElevatedChrome.swift
//  173NoviraEchoJournal
//
//  Lightweight “depth”: one gradient fill + hairline border + single soft shadow.
//  Prefer this over stacking multiple shadows, full-screen blur materials, or
//  `drawingGroup()` on scrolling content — those cost GPU time and can hitch.
//

import SwiftUI

// MARK: - Card surface

enum AppSurfaceCardStyle {
    case standard
    case rich
    case deep
    /// Dimmed cards (e.g. locked rows) — no extra shadow weight.
    case muted

    var fill: LinearGradient {
        switch self {
        case .standard:
            return LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.95),
                    Color.appSurface.opacity(0.72),
                    Color.appBackground.opacity(0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rich:
            return LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.98),
                    Color.appPrimary.opacity(0.14),
                    Color.appSurface.opacity(0.74)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .deep:
            return LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.9),
                    Color.appSurface.opacity(0.62),
                    Color.appBackground.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .muted:
            return LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.55),
                    Color.appSurface.opacity(0.4),
                    Color.appBackground.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var border: LinearGradient {
        LinearGradient(
            colors: [
                Color.appAccent.opacity(0.26),
                Color.appPrimary.opacity(0.11)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum AppCardElevation {
    /// Scrolling lists / dense grids — smallest shadow.
    case listItem
    case raised
    case prominent

    var shadowOpacity: Double {
        switch self {
        case .listItem: return 0.055
        case .raised: return 0.085
        case .prominent: return 0.11
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .listItem: return 7
        case .raised: return 10
        case .prominent: return 13
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .listItem: return 3
        case .raised: return 5
        case .prominent: return 7
        }
    }
}

extension View {
    /// Primary card chrome (panels, widgets, hero tiles).
    func appCardBackground(
        cornerRadius: CGFloat,
        style: AppSurfaceCardStyle = .standard,
        elevation: AppCardElevation = .raised
    ) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(style.fill)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(style.border, lineWidth: 1)
                }
                .shadow(
                    color: Color.black.opacity(elevation.shadowOpacity),
                    radius: elevation.shadowRadius,
                    x: 0,
                    y: elevation.shadowY
                )
        }
    }

    /// Tab bar / floating strip — slightly stronger base shadow (one only).
    func appFloatingPanelBackground(cornerRadius: CGFloat = 22) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.98),
                            Color.appSurface.opacity(0.82)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.22),
                                    Color.appPrimary.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.11), radius: 12, x: 0, y: 7)
        }
    }

    /// Form / filter rows — gradient + edge, **no** shadow (many instances).
    func appFormRowPlate(cornerRadius: CGFloat = 14) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.93),
                            Color.appSurface.opacity(0.78)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
                }
        }
    }
}
