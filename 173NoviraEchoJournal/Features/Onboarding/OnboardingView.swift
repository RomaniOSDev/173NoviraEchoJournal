//
//  OnboardingView.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: JournalStore
    @State private var pageIndex = 0
    @State private var contentScale: CGFloat = 0.92
    @State private var contentOpacity: Double = 0

    private let pages: [(title: String, subtitle: String, kicker: String)] = [
        (
            "Capture the sky",
            "Log temperature, conditions, wind, and notes in one place. Your journal stays on this device.",
            "Observe"
        ),
        (
            "Rich entries, fast",
            "Use presets for sky and comfort, add a place label, and search everything later from History.",
            "Detail"
        ),
        (
            "You are ready",
            "Open Home for your dashboard, Log for new entries, and Journal for history and trends.",
            "Begin"
        )
    ]

    var body: some View {
        ZStack {
            LayeredAppBackground()

            VStack(spacing: 0) {
                welcomeHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                TabView(selection: $pageIndex) {
                    ForEach(0 ..< pages.count, id: \.self) { index in
                        onboardingSlide(
                            kicker: pages[index].kicker,
                            title: pages[index].title,
                            subtitle: pages[index].subtitle,
                            illustration: { illustration(for: index) }
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.28), value: pageIndex)
                .frame(minHeight: 380, idealHeight: 420, maxHeight: 520)

                pageIndicator
                    .padding(.top, 18)
                    .padding(.bottom, 14)

                primaryActionButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
            }
        }
        .onAppear {
            animateContentIn()
        }
        .onChange(of: pageIndex) { _ in
            contentScale = 0.92
            contentOpacity = 0
            animateContentIn()
        }
    }

    private var welcomeHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.42),
                                Color.appSurface.opacity(0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
            }
            .frame(width: 52, height: 52)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appPrimary)
                    .textCase(.uppercase)
                Text("Your weather journal")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .appCardBackground(cornerRadius: 20, style: .rich, elevation: .raised)
    }

    @ViewBuilder
    private func onboardingSlide(
        kicker: String,
        title: String,
        subtitle: String,
        @ViewBuilder illustration: () -> some View
    ) -> some View {
        VStack(spacing: 18) {
            illustration()
                .frame(maxWidth: .infinity)
                .scaleEffect(contentScale)
                .opacity(contentOpacity)

            VStack(alignment: .leading, spacing: 10) {
                Text(kicker.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.appAccent)
                Text(title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .appCardBackground(cornerRadius: 22, style: .standard, elevation: .listItem)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func illustration(for index: Int) -> some View {
        switch index {
        case 0:
            recordIllustrationCard
        case 1:
            logIllustrationCard
        default:
            startIllustrationCard
        }
    }

    private var recordIllustrationCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.38),
                            Color.appSurface.opacity(0.9),
                            Color.appBackground.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                )

            ZStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 64, weight: .medium))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.appAccent.opacity(0.55), Color.appPrimary.opacity(0.35))
                    .offset(x: -72, y: -28)

                Image(systemName: "cloud.heavyrain.fill")
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(Color.appPrimary.opacity(0.45))
                    .offset(x: 48, y: -18)

                Image(systemName: "thermometer.medium")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .offset(x: 0, y: 38)

                Image(systemName: "wind")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color.appPrimary.opacity(0.4))
                    .offset(x: 88, y: 28)
            }
            .frame(height: 200)
            .allowsHitTesting(false)

            Text("Log what you see")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appBackground.opacity(0.92))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.95),
                                    Color.appPrimary.opacity(0.78)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(14)
        }
        .frame(height: 212)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.09), radius: 12, x: 0, y: 6)
    }

    private var logIllustrationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.appAccent)
                Text("Entry preview")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary.opacity(0.7))
            }
            .padding(.bottom, 14)

            VStack(alignment: .leading, spacing: 10) {
                placeholderLine(width: 0.55, accent: Color.appAccent.opacity(0.75))
                placeholderLine(width: 0.72, accent: Color.appPrimary.opacity(0.85))
                placeholderLine(width: 0.42, accent: Color.appTextSecondary.opacity(0.45))
                placeholderLine(width: 0.62, accent: Color.appTextSecondary.opacity(0.35))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appBackground.opacity(0.55),
                                Color.appSurface.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 212)
        .appCardBackground(cornerRadius: 26, style: .rich, elevation: .prominent)
    }

    private func placeholderLine(width: CGFloat, accent: Color) -> some View {
        GeometryReader { geo in
            Capsule()
                .fill(accent)
                .frame(width: max(44, geo.size.width * width), height: 9)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 9)
    }

    private var startIllustrationCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.95),
                            Color.appPrimary.opacity(0.22),
                            Color.appSurface.opacity(0.75)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.appAccent.opacity(0.4),
                                    Color.appPrimary.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.35),
                                    Color.appSurface.opacity(0.9)
                                ],
                                center: .center,
                                startRadius: 4,
                                endRadius: 56
                            )
                        )
                        .frame(width: 112, height: 112)
                        .overlay(
                            Circle()
                                .stroke(Color.appAccent.opacity(0.4), lineWidth: 2)
                        )
                    Image(systemName: "pencil.and.list.clipboard")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }

                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.caption.weight(.bold))
                    Text("Home")
                        .font(.caption.weight(.bold))
                    Text("·")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                    Image(systemName: "cloud.sun.fill")
                        .font(.caption.weight(.bold))
                    Text("Log")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.vertical, 20)
        }
        .frame(height: 212)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 11, x: 0, y: 5)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? Color.appPrimary : Color.appSurface.opacity(0.55))
                    .frame(width: index == pageIndex ? 28 : 8, height: 8)
                    .overlay(
                        Capsule()
                            .stroke(
                                index == pageIndex ? Color.clear : Color.appAccent.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .animation(.spring(response: 0.38, dampingFraction: 0.78), value: pageIndex)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.appSurface.opacity(0.5))
                .overlay(
                    Capsule()
                        .stroke(Color.appPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var primaryActionButton: some View {
        Button(action: advance) {
            HStack(spacing: 10) {
                Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                    .font(.body.weight(.bold))
                Image(systemName: pageIndex == pages.count - 1 ? "arrow.right.circle.fill" : "arrow.right")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(Color.appBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary,
                                Color.appPrimary.opacity(0.82)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.appAccent.opacity(0.45), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.16), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func animateContentIn() {
        withAnimation(.spring(response: 0.48, dampingFraction: 0.78)) {
            contentScale = 1
            contentOpacity = 1
        }
    }

    private func advance() {
        FeedbackHub.tap()
        if pageIndex < pages.count - 1 {
            pageIndex += 1
        } else {
            store.completeOnboarding()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(JournalStore())
}
