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
	
	func addAlbumToLibrary(_ album: Album) async -> Result<Void, LibraryManagerError> {
		
	}
	
	func removeAlbumFromLibrary(_ album: Album) async -> Result<Void, LibraryManagerError> {
		
	}
	
	func addTracksToPlaylist(_ tracks: MusicItemCollection<Track>, playlist: Playlist) async -> Result<Void, LibraryManagerError> {
		
	}
	
	func removeTrackFromPlaylist(_ track: Track, playlist: Playlist) async -> Result<Void, LibraryManagerError> {
		
	}
	
	private func validateAccess() async -> Result<Void, LibraryManagerError> {
		if (MusicAuthorization.currentStatus != .authorized) {
			return .failure(.notAuthorized)
		}
	}

}

enum LibraryAction {
	case addAlbumToLibrary(albumID: MusicItemID)
	case removeAlbumFromLibrary(albumID: MusicItemID)
	case addSongsToPlaylist(playlistID: MusicItemID, count: Int)
	case removeSongFromPlaylist(playlistID: MusicItemID, songID: MusicItemID)
}

enum LibraryManagerError: LocalizedError {
	case notAuthorized, subscriptionRequired, network, notFound, rateLimited, unknown(String)
}
