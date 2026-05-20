import Combine
import SwiftUI
import WhiteNoiseSDK

@MainActor
final class PlayerViewModel: ObservableObject {
    // MARK: - Published state

    var activeTracks: [String: AudioTrack] { engine.tracks }
    var engineState: EngineState { engine.state }

    @Published private(set) var loadingIDs: Set<String> = []
    @Published var errorMessage: String?
    @Published var sleepMinutes: Double = 0
    @Published private(set) var sleepCountdown: String = ""

    // MARK: - Derived helpers

    var isPlaying: Bool { engineState == .playing }
    var anyActive: Bool { !activeTracks.isEmpty }

    func isActive(_ id: String) -> Bool { activeTracks[id] != nil }
    func isLoading(_ id: String) -> Bool { loadingIDs.contains(id) }
    func track(for id: String) -> AudioTrack? { activeTracks[id] }

    // MARK: - Private

    private let engine = WhiteNoiseEngine.shared
    private let sounds = SoundDataManager.shared.sounds
    private var cancellables = Set<AnyCancellable>()
    private var sleepTask: Task<Void, Never>?

    let soundsByID: [String: Sound] = Dictionary(
        uniqueKeysWithValues: SoundDataManager.shared.sounds.map { ($0.id, $0) }
    )

    func currentMixItems() -> [MixsoundItem] {
        activeTracks.values
            .sorted { $0.id < $1.id }
            .map { MixsoundItem(soundID: $0.id, volume: $0.volume) }
    }

    // MARK: - Init

    init() {
        engine.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        engine.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    // MARK: - Intent: Toggle

    func toggle(_ sound: Sound) {
        if isActive(sound.id) {
            engine.remove(id: sound.id)
        } else {
            Task { await load(sound) }
        }
    }

    // MARK: - Intent: Volume

    func setVolume(_ value: Float, for id: String) {
        engine.setVolume(value, for: id)
    }

    // MARK: - Intent: Playback control

    func togglePlayPause() {
        isPlaying ? engine.pauseAll() : engine.resumeAll()
    }

    func stopAll() {
        engine.stopAll()
        cancelSleepTimer()
    }

    // MARK: - Intent: Load

    func load(_ sound: Sound) async {
        await load(sound, volume: 1)
    }

    func load(_ sound: Sound, volume: Float) async {
        loadingIDs.insert(sound.id)
        defer { loadingIDs.remove(sound.id) }
        errorMessage = nil
        do {
            try await engine.play(url: sound.url, id: sound.id, volume: volume, name: sound.name)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Intent: Apply Mix

    func applyMix(snapshot: MixSnapshot, replaceCurrent _: Bool) {
        Task {
            do {
                // 根据 soundID 从 sounds 数组里找到完整的 Sound 对象
                let items: [(soundID: String, volume: Float, url: URL, name: String)] = snapshot.items.compactMap { item in
                    guard let sound = sounds.first(where: { $0.id == item.soundID }) else {
                        print("找不到 soundID: \(item.soundID)，跳过")
                        return nil // compactMap 自动过滤 nil
                    }
                    return (
                        soundID: sound.id,
                        volume: item.volume,
                        url: sound.url,
                        name: sound.name
                    )
                }

                try await engine.applyMix(items: items, mixName: snapshot.name)

            } catch {
                print("applyMix 失败: \(error)")
            }
        }
    }

    private func performApplyMix(
        snapshot: [(soundID: String, volume: Float)],
        replaceCurrent: Bool
    ) async {
        let validSounds = snapshot.compactMap { item -> (Sound, Float)? in
            guard let sound = soundsByID[item.soundID] else { return nil }
            return (sound, item.volume)
        }

        guard !validSounds.isEmpty else {
            errorMessage = "这个混合音里的声音已不可用"
            return
        }

        errorMessage = nil

        if replaceCurrent { stopAll() }

        for (sound, volume) in validSounds {
            if isActive(sound.id) {
                setVolume(volume, for: sound.id)
            } else {
                await load(sound, volume: volume)
            }
        }

        if !isPlaying, anyActive {
            togglePlayPause()
        }
    }

    // MARK: - Intent: Sleep timer

    func startSleepTimer() {
        guard sleepMinutes > 0 else { cancelSleepTimer(); return }
        cancelSleepTimer()

        let totalSeconds = Int(sleepMinutes * 60)

        sleepTask = Task { [weak self] in
            guard let self else { return }
            for remaining in stride(from: totalSeconds, through: 1, by: -1) {
                guard !Task.isCancelled else { return }
                self.updateCountdown(remaining: remaining)
                try? await Task.sleep(for: .seconds(1))
            }
            guard !Task.isCancelled else { return }
            await self.fireSleepTimer()
        }
    }

    func cancelSleepTimer() {
        sleepTask?.cancel()
        sleepTask = nil
        sleepCountdown = ""
    }

    private func updateCountdown(remaining: Int) {
        let m = remaining / 60
        let s = remaining % 60
        sleepCountdown = String(format: "%d:%02d", m, s)
    }

    private func fireSleepTimer() async {
        let idsToFade = Set(engine.tracks.keys)
        for id in idsToFade {
            engine.remove(id: id, fadeDuration: 3)
        }
        try? await Task.sleep(for: .seconds(3))
        guard !Task.isCancelled else { return }
        cancelSleepTimer()
    }
}
