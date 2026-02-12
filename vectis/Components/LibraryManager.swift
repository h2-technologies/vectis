//
//  LibraryManager.swift
//  vectis
//
//  Created by Samuel Valencia on 2/11/26.
//

import Foundation
import MusicKit

@MainActor
final class LibraryManager: ObservableObject {
	@Published var isLoading: Bool = false
	@Published var inFlightAction: LibraryAction?
	@Published var lastError: LibraryManagerError?
	@Published var lastSuccessMessage: String?
	
	@Published private(set) var libraryAlbums: [Album] = []
	@Published private(set) var libraryPlaylists: [Playlist] = []
	@Published private(set) var playlistTracksById: [MusicItemID: [Track]] = [:]
	
	private var lastAlbumsRefresh: Date?
	private var lastPlaylistsRefresh: Date?
	private var lastPlaylistTracksRefresh: [MusicItemID: Date] = [:]
	
	private var albumsRefreshTask: Task<Void, Never>?
	private var playlistsRefreshTask: Task<Void, Never>?
	private var playlistTrackTasks: [MusicItemID: Task<Void, Never>] = [:]
	
	func addAlbumToLibrary(_ album: Album) async -> Result<Void, LibraryManagerError> {
		let access = await validateAccess()
		guard case .success = access else { return access }
		
		let result = await perform(.addAlbumToLibrary(albumID: album.id)) {
			try await MusicLibrary.shared.add(album)
		}
		
		if case .success = result {
			await refreshLibraryAlbums(policy: .force)
		}
		return result
	}
	
	func removeAlbumFromLibrary(_ album: Album) async -> Result<Void, LibraryManagerError> {
		let access = await validateAccess()
		guard case .success = access else { return access }
		
		let result = await perform(.removeAlbumFromLibrary(albumID: album.id)) {
			try await deleteLibraryResource(resourceType: "albums", id: album.id.rawValue)
		}
		
		if case .success = result {
			await refreshLibraryAlbums(policy: .force)
		}
		return result
	}
	
	func addTracksToPlaylist(_ tracks: MusicItemCollection<Track>, playlist: Playlist) async -> Result<Void, LibraryManagerError> {
		let access = await validateAccess()
		guard case .success = access else { return access }
		
		let result = await perform(.addSongsToPlaylist(playlistID: playlist.id, count: tracks.count)) {
			for track in tracks {
				_ = try await MusicLibrary.shared.add(track, to: playlist)
			}
		}
		
		if case .success = result {
			await refreshPlaylistTracks(playlist: playlist, policy: .force)
		}
		return result
	}
	
	func removeTrackFromPlaylist(_ track: Track, playlist: Playlist) async -> Result<Void, LibraryManagerError> {
		let access = await validateAccess()
		guard case .success = access else { return access }
		
		let result = await perform(.removeSongFromPlaylist(playlistID: playlist.id, songID: track.id)) {
			let loaded = try await playlist.with([.tracks])
			guard let tracks = loaded.tracks else {
				throw LibraryManagerError.notFound
			}
			
			let updatedTracks = tracks.filter { $0.id != track.id }
			_ = try await MusicLibrary.shared.edit(
				playlist,
				name: nil,
				description: nil,
				authorDisplayName: nil,
				items: updatedTracks
			)
		}
		
		if case .success = result {
			await refreshPlaylistTracks(playlist: playlist, policy: .force)
		}
		return result
	}
	
	func refreshAll(policy: RefreshPolicy = .ifStale(60)) async {
		await refreshLibraryAlbums(policy: policy)
		await refreshLibraryPlaylists(policy: policy)
	}
	
	func refreshLibraryAlbums(policy: RefreshPolicy = .ifStale(60)) async {
		guard shouldRefresh(lastAlbumsRefresh, policy: policy) else { return }
		guard albumsRefreshTask == nil else {
			await albumsRefreshTask?.value
			return
		}
		
		albumsRefreshTask = Task { [weak self] in
			guard let self = self else { return }
			defer { self.albumsRefreshTask = nil }
			
			do {
				var request = MusicLibraryRequest<Album>()
				request.limit = 100
				let response = try await request.response()
				self.libraryAlbums = Array(response.items)
				self.lastAlbumsRefresh = Date()
			} catch {
				self.lastError = self.mapError(error)
			}
		}
		
		await albumsRefreshTask?.value
	}
	
	func refreshLibraryPlaylists(policy: RefreshPolicy = .ifStale(60)) async {
		guard shouldRefresh(lastPlaylistsRefresh, policy: policy) else { return }
		guard playlistsRefreshTask == nil else {
			await playlistsRefreshTask?.value
			return
		}
		
		playlistsRefreshTask = Task { [weak self] in
			guard let self = self else { return }
			defer { self.playlistsRefreshTask = nil }
			
			do {
				var request = MusicLibraryRequest<Playlist>()
				request.limit = 100
				let response = try await request.response()
				self.libraryPlaylists = Array(response.items)
				self.lastPlaylistsRefresh = Date()
			} catch {
				self.lastError = self.mapError(error)
			}
		}
		
		await playlistsRefreshTask?.value
	}
	
	func refreshPlaylistTracks(playlist: Playlist, policy: RefreshPolicy = .ifStale(30)) async {
		let playlistId = playlist.id
		guard shouldRefresh(lastPlaylistTracksRefresh[playlistId], policy: policy) else { return }
		guard playlistTrackTasks[playlistId] == nil else {
			await playlistTrackTasks[playlistId]?.value
			return
		}
		
		playlistTrackTasks[playlistId] = Task { [weak self] in
			guard let self = self else { return }
			defer { self.playlistTrackTasks[playlistId] = nil }
			
			do {
				let loaded = try await playlist.with([.tracks])
				self.playlistTracksById[playlistId] = Array(loaded.tracks ?? [])
				self.lastPlaylistTracksRefresh[playlistId] = Date()
			} catch {
				self.lastError = self.mapError(error)
			}
		}
		
		await playlistTrackTasks[playlistId]?.value
	}
	
	func invalidateAlbums() {
		lastAlbumsRefresh = nil
	}
	
	func invalidatePlaylists() {
		lastPlaylistsRefresh = nil
	}
	
	func invalidatePlaylistTracks(_ playlistID: MusicItemID) {
		lastPlaylistTracksRefresh[playlistID] = nil
	}
	
	private func validateAccess(requireCloudLibrary: Bool = true) async -> Result<Void, LibraryManagerError> {
		let status = await MusicAuthorization.request()
		guard status == .authorized else {
			return .failure(.notAuthorized)
		}
		
		do {
			let subscription = try await MusicSubscription.current
			guard subscription.canPlayCatalogContent else {
				return .failure(.subscriptionRequired)
			}
			if requireCloudLibrary, !subscription.hasCloudLibraryEnabled {
				return .failure(.subscriptionRequired)
			}
		} catch {
			return .failure(mapError(error))
		}
		
		return .success(())
	}
	
	private func deleteLibraryResource(resourceType: String, id: String) async throws {
		var components = URLComponents(string: "https://api.music.apple.com/v1/me/library")!
		components.queryItems = [URLQueryItem(name: "ids[\(resourceType)]", value: id)]
		
		var request = URLRequest(url: components.url!)
		request.httpMethod = "DELETE"
		
		let dataRequest = MusicDataRequest(urlRequest: request)
		let response = try await dataRequest.response()
		
		guard let http = response.urlResponse as? HTTPURLResponse else {
			throw LibraryManagerError.unknown("Invalid response")
		}
		
		guard (200...299).contains(http.statusCode) else {
			throw mapStatusCode(http.statusCode)
		}
	}
	
	private func perform(_ action: LibraryAction, operation: () async throws -> Void) async -> Result<Void, LibraryManagerError> {
		isLoading = true
		inFlightAction = action
		lastError = nil
		lastSuccessMessage = nil
		defer {
			isLoading = false
			inFlightAction = nil
		}
		
		do {
			try await operation()
			lastSuccessMessage = "Success"
			return .success(())
		} catch let error as LibraryManagerError {
			lastError = error
			return .failure(error)
		} catch {
			let mapped = mapError(error)
			lastError = mapped
			return .failure(mapped)
		}
	}
	
	private func shouldRefresh(_ last: Date?, policy: RefreshPolicy) -> Bool {
		switch policy {
		case .force:
			return true
		case .ifStale(let ttl):
			guard let last = last else { return true }
			return Date().timeIntervalSince(last) > ttl
		}
	}
	
	private func mapStatusCode(_ code: Int) -> LibraryManagerError {
		switch code {
		case 401, 403:
			return .notAuthorized
		case 404:
			return .notFound
		case 408, 500...599:
			return .network
		case 429:
			return .rateLimited
		default:
			return .unknown("Request failed (\(code))")
		}
	}
	
	private func mapError(_ error: Error) -> LibraryManagerError {
		if let libraryError = error as? LibraryManagerError {
			return libraryError
		}
		let nsError = error as NSError
		if nsError.domain == NSURLErrorDomain {
			return .network
		}
		return .unknown(error.localizedDescription)
	}
}

enum LibraryAction: Equatable {
	case addAlbumToLibrary(albumID: MusicItemID)
	case removeAlbumFromLibrary(albumID: MusicItemID)
	case addSongsToPlaylist(playlistID: MusicItemID, count: Int)
	case removeSongFromPlaylist(playlistID: MusicItemID, songID: MusicItemID)
}

enum LibraryManagerError: LocalizedError, Equatable {
	case notAuthorized
	case subscriptionRequired
	case network
	case notFound
	case rateLimited
	case unknown(String)
	
	var errorDescription: String? {
		switch self {
		case .notAuthorized:
			return "Apple Music access is not authorized."
		case .subscriptionRequired:
			return "An active Apple Music subscription with Sync Library is required."
		case .network:
			return "Network error. Try again."
		case .notFound:
			return "Requested item was not found."
		case .rateLimited:
			return "Too many requests. Try again in a moment."
		case .unknown(let message):
			return message
		}
	}
}

enum RefreshPolicy {
	case force
	case ifStale(TimeInterval)
}
