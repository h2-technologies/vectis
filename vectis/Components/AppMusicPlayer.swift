//
//  AppMusicPlayer.swift
//  vectis
//
//  Created by Samuel Valencia on 8/29/25.
//

import Foundation
import MusicKit
import Combine
import AVFoundation

public class AppMusicPlayer: ObservableObject {
    private var player = ApplicationMusicPlayer.shared
    
    @Published public var currentSong: Song? = nil
    @Published public var status: ApplicationMusicPlayer.PlaybackStatus?
    @Published public var queue: [Song] = []
    @Published public var playbackTime: TimeInterval = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var playbackTimer: Timer?
    
    init() {
        // Configure audio session for background playback
        configureAudioSession()
        
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
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func updatePlayerState() {
        if case let .song(song) = player.queue.currentEntry?.item {
            currentSong = song
        }
        queue = self.player.queue.entries.compactMap {
            if case let .song(song) = $0.item {
                return song
            }
            return nil
        }
        status = self.player.state.playbackStatus
        
        // Start or stop timer based on playback status
        if status == .playing {
            startPlaybackTimer()
        } else {
            stopPlaybackTimer()
        }
    }
    
    private func startPlaybackTimer() {
        guard playbackTimer == nil else { return }
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.playbackTime = self.player.playbackTime
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
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
    
    @MainActor
    func playNext(_ song: MusicItemCollection<Track>.Element) async {
        do {
            if player.queue.currentEntry == nil {
                player.queue = ApplicationMusicPlayer.Queue(for: MusicItemCollection([song]))
            } else {
                try await player.queue.insert(song, position: .afterCurrentEntry)
            }
        } catch {
            print("Error queuing song to play next: \(error.localizedDescription)")
        }
    }
    
    //Replaces the queue with a new queue of the playlist
    @MainActor
    func enqueuePlaylist<T: PlayableMusicItem>(playlist: MusicItemCollection<T>, firstSong: T) async {
        shuffle(false)
        guard let startIndex = playlist.firstIndex(where: { $0.id == firstSong.id }) else {
            return
        }
        
        let newQueue = MusicItemCollection(playlist.suffix(from: startIndex))
        
        player.queue = ApplicationMusicPlayer.Queue(for: newQueue)
        
    }
    
    //Clears the queue and queues an artist
    @MainActor
    func enqueueArtist(_ artist: Artist) async {
        shuffle(false) // disable shuffle
        player.queue = ApplicationMusicPlayer.Queue() // clear the queue
        if let albums = artist.albums {
            for album in albums {
                do {
                    let albumWithTracks = try await album.with(.tracks)
                    if let tracks = albumWithTracks.tracks {
                        if album == albums.first {
                            await self.enqueuePlaylist(playlist: tracks, firstSong: tracks[0])
                        } else {
                            await self.enqueue(songs: tracks)
                        }
                    }
                } catch {
                    print("Error fetching album tracks: \(error)" )
                }
                
                
            }
        }
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
    
    @MainActor
    func seek(to time: TimeInterval) async {
        player.playbackTime = time
    }
}
