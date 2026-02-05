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

public struct QueueEntry: Identifiable, Equatable {
	public let id: String
	public let song: Song
	public let isCurrent: Bool
}

public class AppMusicPlayer: ObservableObject {
	private var isObserving = false
	private var player = ApplicationMusicPlayer.shared
	
	@Published public var currentSong: Song? = nil
	@Published public var status: ApplicationMusicPlayer.PlaybackStatus?
	@Published public var queue: [Song] = []
	@Published public var playbackTime: TimeInterval = 0
	
	@Published public var queueEntries: [QueueEntry] = []
	@Published public var currentEntry: QueueEntry? = nil
	@Published public var upNextEntries: [QueueEntry] = []
	@Published public var historyEntries: [QueueEntry] = []
	
	
	private var cancellables = Set<AnyCancellable>()
	private var playbackTimer: Timer?
	
	init() {
		// Configure audio session for background playback
		configureAudioSession()
	}
	
	@MainActor
	func startObserving() {
		guard !isObserving else { return }
		isObserving = true
		
		Task {
			for await _ in player.state.objectWillChange.values {
				self.updatePlayerState()
			}
		}
		
		Task {
			for await _ in player.queue.objectWillChange.values {
				self.updatePlayerState()
			}
		}

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
		} else {
			currentSong = nil
		}
		
		let entries = player.queue.entries
		let currentEntryId = player.queue.currentEntry?.id
		
		let mapped: [QueueEntry] = entries.compactMap { entry -> QueueEntry? in
			guard case let .song(song) = entry.item else { return nil }
			let id = entry.id
			return QueueEntry(id: id, song: song, isCurrent: entry.id == currentEntryId)
		}
		
		queueEntries = mapped
		currentEntry = mapped.first(where: { $0.isCurrent })
		
		if let currentIndex = mapped.firstIndex(where: { $0.isCurrent }) {
			historyEntries = Array(mapped.prefix(upTo: currentIndex))
			upNextEntries = Array(mapped.suffix(from: currentIndex + 1))
		} else {
			historyEntries = []
			upNextEntries = mapped
		}
		
		queue = mapped.map { $0.song }
		status = player.state.playbackStatus
		
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
	func addToQueue(_ song: MusicItemCollection<Track>.Element) async {
		do {
			if player.queue.currentEntry == nil {
				player.queue = ApplicationMusicPlayer.Queue(for: MusicItemCollection([song]))
			} else {
				try await player.queue.insert(song, position: .tail)
			}
		} catch {
			print("Error adding to queue: \(error.localizedDescription)")
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
			print("Error inserting play next: \(error.localizedDescription)")
		}
	}
	
	@MainActor
	func removeFromQueue(entryID: String) async {
		let newUpNext = upNextEntries
			.filter { $0.id != entryID }
			.map { $0.song }
		await rebuildQueue(keepingCurrent: true, newUpNext: newUpNext)
	}
	
	@MainActor
	func clearUpNext() async {
		await rebuildQueue(keepingCurrent: true, newUpNext: [])
	}
	
	@MainActor
	func moveUpNext(fromOffsets: IndexSet, toOffset: Int) async {
		var working = upNextEntries
		working = moveEntries(working, fromOffsets: fromOffsets, toOffset: toOffset)
		await rebuildQueue(keepingCurrent: true, newUpNext: working.map { $0.song })
	}

	private func moveEntries(_ entries: [QueueEntry], fromOffsets: IndexSet, toOffset: Int) -> [QueueEntry] {
		var reordered = entries
		let items = fromOffsets.sorted().map { reordered[$0] }
		for index in fromOffsets.sorted(by: >) {
			reordered.remove(at: index)
		}
		
		let adjustedOffset = toOffset - fromOffsets.filter { $0 < toOffset }.count
		var insertIndex = max(0, min(adjustedOffset, reordered.count))
		for item in items {
			reordered.insert(item, at: insertIndex)
			insertIndex += 1
		}
		
		return reordered
	}
	
	@MainActor
	private func rebuildQueue(keepingCurrent: Bool, newUpNext: [Song]) async {
		if keepingCurrent, let current = currentSong {
			let combined = [current] + newUpNext
			let collection = MusicItemCollection(combined)
			player.queue = ApplicationMusicPlayer.Queue(for: collection)
		} else {
			let collection = MusicItemCollection(newUpNext)
			player.queue = ApplicationMusicPlayer.Queue(for: collection)
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
		} catch {
			print("Error queuing songs: \(error.localizedDescription)")
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
	func enqueueStation(_ station: Station) {
		player.queue = ApplicationMusicPlayer.Queue()
		player.queue = [station]
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
