//
//  WhiteNoisePlayerApp.swift
//  WhiteNoisePlayer
//
//  Created by luckly on 2026/4/26.
//

import SwiftData
import SwiftUI

@main
struct WhiteNoisePlayerApp: App {
    private let container: ModelContainer
    @StateObject private var playerVM: PlayerViewModel
    @StateObject private var collectionStore: CollectionStore
    @StateObject private var mixLibraryStore: MixLibraryStore

    init() {
        let container = try! ModelContainer(for: CollectedSound.self, Mixsound.self)
        self.container = container
        let context = container.mainContext
        _playerVM = StateObject(wrappedValue: PlayerViewModel())
        _collectionStore = StateObject(wrappedValue: CollectionStore(context: context))
        _mixLibraryStore = StateObject(wrappedValue: MixLibraryStore(context: context))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(playerVM)
                .environmentObject(collectionStore)
                .environmentObject(mixLibraryStore)
        }
        .modelContainer(container)
    }
}
