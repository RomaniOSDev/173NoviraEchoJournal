//
//  Feature3View.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct Feature3View: View {
    @EnvironmentObject private var store: JournalStore
    @StateObject private var viewModel = Feature3ViewModel()
    @State private var granularity: TrendGranularity = .daily
    @State private var showingEditor = false
    @State private var draft = WeatherEntry()
    @State private var showSuccessBadge = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Picker("Granularity", selection: $granularity) {
                        ForEach(TrendGranularity.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 4)

                    if buckets.isEmpty {
                        emptyState
                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Temperature trend")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                            TrendLineChart(values: buckets.map(\.averageTemperature), stroke: .appAccent)
                            Text("Precipitation trend")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                            TrendBarChart(values: buckets.map(\.totalPrecipitation), fill: .appPrimary)
                        }
                        .padding(.horizontal, 4)

                        if buckets.count > 1 {
                            TabView {
                                ForEach(buckets) { bucket in
                                    bucketSummaryCard(bucket)
                                        .padding(.horizontal, 4)
                                }
                            }
                            .frame(height: 200)
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                        } else if let bucket = buckets.first {
                            bucketSummaryCard(bucket)
                                .padding(.horizontal, 4)
                        }

                        summarySection
                    }

                    Button {
                        FeedbackHub.tap()
                        draft = WeatherEntry()
                        showingEditor = true
                    } label: {
                        Text("Log New Entry")
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.appPrimary)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.visible)
            .background(LayeredAppBackground())
            .navigationTitle("Trends Overview")
            .onAppear {
                store.registerTrendSessionVisit()
            }
            .sheet(isPresented: $showingEditor) {
                WeatherEntryEditorSheet(
                    draft: $draft,
                    isNew: true,
                    onSave: { entry in
                        FeedbackHub.lightImpact()
                        FeedbackHub.trendSavedChime()
                        FeedbackHub.success()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
                            store.saveEntry(entry, isNew: true)
                        }
                        showingEditor = false
                        showSuccessBadge = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showSuccessBadge = false
                            }
                        }
                    },
                    onCancel: {
                        showingEditor = false
                    }
                )
                .presentationDetents([.large])
            }
            .overlay(alignment: .center) {
                SuccessFeedbackOverlay(isVisible: showSuccessBadge)
            }
        }
    }

    private var buckets: [TrendBucket] {
        viewModel.buckets(for: store, granularity: granularity)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color.appPrimary)
            Text("Your weather trends will appear here as you record observations")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 16)
        .appCardBackground(cornerRadius: 22, style: .standard, elevation: .raised)
    }

    private func bucketSummaryCard(_ bucket: TrendBucket) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(bucket.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg temp")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(bucket.averageTemperature, format: .number.precision(.fractionLength(1)))
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Precipitation")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(bucket.totalPrecipitation, format: .number.precision(.fractionLength(1)))
                        .font(.title3.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
        .padding(16)
        .appCardBackground(cornerRadius: 20, style: .standard, elevation: .raised)
    }

    private var summarySection: some View {
        let summary = viewModel.overallAverages(from: buckets)
        return VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Average temperature")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(summary.temperature, format: .number.precision(.fractionLength(1)))
                        .font(.title2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total precipitation")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(summary.precipitation, format: .number.precision(.fractionLength(1)))
                        .font(.title2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
        .padding(16)
        .appCardBackground(cornerRadius: 20, style: .deep, elevation: .raised)
    }
}
