//
//  Feature2View.swift
//  173NoviraEchoJournal
//

import SwiftUI

struct Feature2View: View {
    @EnvironmentObject private var store: JournalStore
    @StateObject private var viewModel = Feature2ViewModel()
    @State private var showingFilter = false
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

    private var entriesInCurrentFilter: Int {
        viewModel.entryCount(from: store)
    }

    private var isSearchActive: Bool {
        !viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var showEmptyJournal: Bool {
        entriesInCurrentFilter == 0
    }

    private var showNoSearchMatches: Bool {
        entriesInCurrentFilter > 0 && displayedEntries.isEmpty && isSearchActive
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                if showEmptyJournal {
                    Section {
                        emptyJournalPlaceholder
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
                        journalSummaryCard
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
                                        draft = duplicate(entry)
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
                .background(LayeredAppBackground())

                historyAddEntryButton
            }
            .navigationTitle("History")
            .navigationDestination(for: WeatherEntry.self) { entry in
                WeatherEntryDetailView(entry: entry)
            }
            .searchable(text: $viewModel.searchText, prompt: "Search notes, conditions, temperature…")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 2) {
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

                        Button {
                            FeedbackHub.tap()
                            showingFilter = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Filter entries")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                HistoryFilterSheet()
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingEditor) {
                WeatherEntryEditorSheet(
                    draft: $draft,
                    isNew: editingEntryID == nil,
                    onSave: { saved in
                        persist(saved)
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

    private var historyAddEntryButton: some View {
        Button {
            FeedbackHub.tap()
            draft = WeatherEntry()
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

    private var journalSummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSearchActive ? "\(displayedEntries.count) matches" : "\(displayedEntries.count) entries")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(viewModel.filterSummary(from: store))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Image(systemName: "book.pages.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appAccent.opacity(0.85))
            }
            Text("Tap a card for full details. Swipe for edit or delete.")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardBackground(cornerRadius: 18, style: .rich, elevation: .raised)
    }

    private var emptyJournalPlaceholder: some View {
        VStack(spacing: 18) {
            ZStack {
                Image(systemName: "book.closed")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Color.appPrimary)
                Image(systemName: "cloud.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .offset(y: -26)
            }
            Text("No entries in this range yet. Tap New to add one.")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 12)
        .appCardBackground(cornerRadius: 22, style: .standard, elevation: .raised)
    }

    private var noSearchResultsPlaceholder: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(Color.appAccent)
            Text("No matches")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
            Text("Try another word or clear the search field.")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 12)
        .appCardBackground(cornerRadius: 22, style: .standard, elevation: .raised)
    }

    private func duplicate(_ entry: WeatherEntry) -> WeatherEntry {
        WeatherEntry(
            id: entry.id,
            date: entry.date,
            temperatureText: entry.temperatureText,
            condition: entry.condition,
            notes: entry.notes,
            precipitationText: entry.precipitationText,
            locationLabel: entry.locationLabel,
            windText: entry.windText,
            humidityText: entry.humidityText,
            visibilityText: entry.visibilityText,
            skyCover: entry.skyCover,
            comfortTag: entry.comfortTag
        )
    }

    private func persist(_ entry: WeatherEntry) {
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
