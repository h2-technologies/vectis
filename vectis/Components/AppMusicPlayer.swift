//
//  AppMusicPlayer.swift
//  vectis
//
//  Created by Samuel Valencia on 8/29/25.
//

import Foundation
import MusicKit
import Combine

public class AppMusicPlayer: ObservableObject {
    private var player = ApplicationMusicPlayer.shared
    
    @Published public var currentSong: Song? = nil
    @Published public var status: MusicPlayer.PlaybackStatus?
    @Published public var queue: [Song] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        player.state.objectWillChange.sink { [weak self] in
            Task { @MainActor in
                self?.updatePlayerState()
            }
        }.store(in: &cancellables)
        
        player.queue.objectWillChange.sink { [weak self] in
            Task { @MainActor in
                self?.updatePlayerState()
            }
        }.store(in: &cancellables)
        
        
    }
    
    private func updatePlayerState() {
        if case let .song(song) = player.queue.currentEntry?.item {
            currentSong = song as Song
            
        }
        queue = player.queue.entries.compactMap { $0.item as? Song }
        status = player.state.playbackStatus
    }
    
    @MainActor
    func enqueue(_ song: MusicItemCollection<Track>.Element) async {
        do {
            if player.queue.currentEntry == nil {
                player.queue = ApplicationMusicPlayer.Queue(for: MusicItemCollection([song]))
            } else {
                try await player.queue.insert(song, position: .tail)
            }
        } catch {
            print("Error queuing song: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func enqueue(songs: MusicItemCollection<Track>) async {
        do {
            if player.queue.currentEntry == nil {
                player.queue = ApplicationMusicPlayer.Queue(for: songs)
            } else {
                songs.forEach { song in
                    Task {
                        try await player.queue.insert(song, position: .tail)
                    }
                }
            }
        }
    }
    
    //Clears the queue and queues a playlist
    @MainActor
    func enqueuePlaylist(playlist: MusicItemCollection<Track>, firstSong: MusicItemCollection<Track>.Element) async {
        shuffle(false)
        guard let startIndex = playlist.firstIndex(where: { $0.id == firstSong.id }) else {
            return
        }
        
        let newQueue = MusicItemCollection(playlist.suffix(from: startIndex))
        
        player.queue = ApplicationMusicPlayer.Queue(for: newQueue)
        
    }
    
    @MainActor
    func shuffle(_ mode: Bool) {
        if mode {
            player.state.shuffleMode = .songs
        } else {
            player.state.shuffleMode = .off
        }
    }
    
    @MainActor
    func play() async {
        do {
            try await player.prepareToPlay()
            try await player.play()
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func pause() {
        player.pause()
    }
    
    @MainActor
    func skipToNext() async {
        do {
            try await player.skipToNextEntry()
        } catch {
            print("Error skipping song: \(error.localizedDescription)")
        }
        
    }
    
    @MainActor
    func skipToPrevious() async {
        do {
            try await player.skipToPreviousEntry()
        } catch {
            print("Error skipping to last song: \(error.localizedDescription)")
        }
        
    }
}
