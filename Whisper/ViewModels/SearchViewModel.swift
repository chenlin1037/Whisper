//
//  SearchViewModel.swift
//  Whisper
//
//  Created by luckly on 2026/2/6.
//

// SearchViewModel.swift

import Combine
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchText: String = ""
    @Published var searchResults: [Sound] = []
    @Published var isSearching: Bool = false
    @Published var searchHistory: [String] = []

    // MARK: - Private Properties

    private var allSounds: [Sound] = []
    private var cancellables = Set<AnyCancellable>()

    private let debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(500)
    private let maxHistoryCount = 10

    // 注入 Store
    private let historyStore: SearchHistoryStore

    // MARK: - Initialization

    init(historyStore: SearchHistoryStore = UserDefaultsSearchHistoryStore()) {
        self.historyStore = historyStore
        loadSearchHistory()
        setupSearchDebounce()
    }

    // MARK: - Public Methods

    func setSounds(_ sounds: [Sound]) {
        allSounds = sounds
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
        isSearching = false
    }

    func searchWithHistory(_ text: String) {
        searchText = text
    }

    func performSearch() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        executeSearch(with: trimmedText)
    }

    func removeFromHistory(_ text: String) {
        searchHistory.removeAll { $0 == text }
        saveSearchHistory()
    }

    func clearAllHistory() {
        searchHistory.removeAll()
        saveSearchHistory()
    }

    // MARK: - Private Methods

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: debounceInterval, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .sink { [weak self] trimmedText in
                self?.executeSearch(with: trimmedText)
            }
            .store(in: &cancellables)
    }

    private func executeSearch(with text: String) {
        guard !text.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true

        Task {
            let results = await performAsyncSearch(query: text)

            await MainActor.run {
                self.searchResults = results
                self.isSearching = false

                if !results.isEmpty {
                    self.addToSearchHistory(text)
                }
            }
        }
    }

    private func performAsyncSearch(query: String) async -> [Sound] {
        await Task.detached(priority: .userInitiated) { [allSounds] in
            allSounds.filter { sound in
                sound.name.localizedCaseInsensitiveContains(query) ||
                sound.category.localizedCaseInsensitiveContains(query)
            }
        }.value
    }

    private func addToSearchHistory(_ text: String) {
        searchHistory.removeAll { $0 == text }
        searchHistory.insert(text, at: 0)

        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }

        saveSearchHistory()
    }

    // 👇 使用注入的 store
    private func saveSearchHistory() {
        historyStore.save(searchHistory)
    }

    private func loadSearchHistory() {
        searchHistory = historyStore.load()
    }
}
