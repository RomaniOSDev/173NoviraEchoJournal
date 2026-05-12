//
//  Feature1View.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct Feature1View: View {
    @EnvironmentObject private var store: JournalStore
    @StateObject private var viewModel = Feature1ViewModel()
    @State private var showingEditor = false
    @State private var draft = WeatherEntry()
    @State private var editingEntryID: UUID?
    @State private var showSuccessBadge = false
    @State private var pulseEntryID: UUID?

    private var displayedEntries: [WeatherEntry] {
        viewModel.displayedEntries(from: store)
    }

    private var sections: [HistoryDaySection] {
        viewModel.daySections(from: displayedEntries)
    }

    private var isSearchActive: Bool {
        !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var showEmptyJournal: Bool {
        store.weatherEntries.isEmpty
    }

    private var showNoSearchMatches: Bool {
        !store.weatherEntries.isEmpty && displayedEntries.isEmpty && isSearchActive
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    if showEmptyJournal {
                        Section {
                            emptyLogPlaceholder
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    } else if showNoSearchMatches {
                        Section {
                            noSearchResultsPlaceholder
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        Section {
                            logSummaryCard
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 4, trailing: 12))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                        ForEach(sections) { section in
                            Section {
                                ForEach(section.entries) { entry in
                                    NavigationLink(value: entry) {
                                        HistoryJournalCell(entry: entry)
                                            .rowPulse(pulseEntryID == entry.id)
                                    }
                                    .listRowInsets(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            FeedbackHub.tap()
                                            draft = viewModel.duplicateAsNewEntry(from: entry)
                                            editingEntryID = nil
                                            showingEditor = true
                                        } label: {
                                            Label("Log again", systemImage: "doc.badge.plus")
                                        }
                                        .tint(Color.appAccent)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            FeedbackHub.tap()
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                store.deleteEntry(id: entry.id)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            FeedbackHub.tap()
                                            draft = viewModel.duplicate(from: entry)
                                            editingEntryID = entry.id
                                            showingEditor = true
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Color.appPrimary)
                                    }
                                }
                            } header: {
                                Text(section.heading)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .textCase(nil)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 4)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.sortNewestFirst)
                .animation(.easeInOut(duration: 0.25), value: viewModel.searchText)

                if !showEmptyJournal {
                    addEntryFloatingButton
                }
            }
            .background(LayeredAppBackground())
            .navigationTitle("Weather Log")
            .navigationDestination(for: WeatherEntry.self) { entry in
                WeatherEntryDetailView(entry: entry)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search conditions, place, wind, notes…")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            FeedbackHub.tap()
                            viewModel.sortNewestFirst = true
                        } label: {
                            HStack {
                                Text("Newest first")
                                if viewModel.sortNewestFirst {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button {
                            FeedbackHub.tap()
                            viewModel.sortNewestFirst = false
                        } label: {
                            HStack {
                                Text("Oldest first")
                                if !viewModel.sortNewestFirst {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.appPrimary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Sort order")
                }
            }
            .sheet(isPresented: $showingEditor) {
                WeatherEntryEditorSheet(
                    draft: $draft,
                    isNew: editingEntryID == nil,
                    onSave: { saved in
                        persist(entry: saved)
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

    private var logSummaryCard: some View {
        let total = viewModel.totalEntryCount(from: store)
        let streak = store.streakDays

        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.appPrimary.opacity(0.35),
                                    Color.appSurface.opacity(0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.appAccent)
                }
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.appAccent.opacity(0.35), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(isSearchActive ? "\(displayedEntries.count) matches" : "\(total) observations")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    if let last = viewModel.lastLoggedSummary(from: store) {
                        Text("Last logged \(last)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appAccent)
                        Text(streakLine(streak))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
                Spacer(minLength: 0)
            }

            Text("Tap a card for details. Swipe the row for edit, delete, or Log again (same readings, new time).")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 22, style: .rich, elevation: .raised)
    }

    private func streakLine(_ streak: Int) -> String {
        if streak <= 0 {
            return "Log today to start a streak"
        }
        if streak == 1 {
            return "1 day streak"
        }
        return "\(streak) day streak"
    }

    private var emptyLogPlaceholder: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.25),
                                Color.appSurface.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(Color.appAccent)
            }
            .overlay(
                Circle()
                    .stroke(Color.appAccent.opacity(0.35), lineWidth: 1.5)
            )

            VStack(spacing: 8) {
                Text("Start your weather log")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                Text("Capture sky, air, and place in a few taps. Your entries power trends and achievements.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 8)

            Button {
                FeedbackHub.tap()
                draft = viewModel.makeDraft()
                editingEntryID = nil
                showingEditor = true
            } label: {
                Label("Add first entry", systemImage: "plus.circle.fill")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appPrimary)
            .padding(.horizontal, 24)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 12)
        .appCardBackground(cornerRadius: 26, style: .standard, elevation: .raised)
    }

    private var noSearchResultsPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(Color.appPrimary.opacity(0.75))
            Text("No matches")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("Try another word — search looks at conditions, notes, temperature, place, wind, and more.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 10)
        .appCardBackground(cornerRadius: 22, style: .standard, elevation: .listItem)
    }

    private var addEntryFloatingButton: some View {
        Button {
            FeedbackHub.tap()
            draft = viewModel.makeDraft()
            editingEntryID = nil
            showingEditor = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                Text("New")
                    .font(.subheadline.weight(.bold))
            }
            .foregroundStyle(Color.appBackground)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPrimary, Color.appPrimary.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.appAccent.opacity(0.45), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
        }
        .accessibilityLabel("Add new entry")
        .padding(.trailing, 18)
        .padding(.bottom, 12)
    }

    private func persist(entry: WeatherEntry) {
        let isNew = editingEntryID == nil
        FeedbackHub.mediumImpact()
        FeedbackHub.logSavedChime()
        FeedbackHub.success()
        FeedbackHub.successPing()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            store.saveEntry(entry, isNew: isNew)
        }
        showingEditor = false
        editingEntryID = nil
        pulseEntryID = entry.id
        showSuccessBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.25)) {
                showSuccessBadge = false
                pulseEntryID = nil
            }
        }
    }
}
