//
//  TrackRowView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/12/25.
//

import SwiftUI
import MusicKit

struct PlaylistTrackRowView: View {
    let track: Track
    let tracks: MusicItemCollection<Track>
	
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
	@EnvironmentObject private var libraryManager: LibraryManager

    @State private var catalogURL: URL?
    @State private var isLoadingURL = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    Task {
                        await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: track)
                        await appMusicPlayer.play()
                    }
                }) {
                    HStack {
                        if let trackArtwork = track.artwork {
                            ArtworkImage(trackArtwork, width: 75)
                                .frame(width: 50, height: 50)
                                .clipShape(.rect(cornerRadius: 5))
                                .padding(.trailing, 5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(track.title)
                                .lineLimit(1)
                                
                            Text(track.artistName)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
						
						Menu {
							Button {
								Task {
									let result = await libraryManager.removeTrackFromPlaylist(track, playlist: playlist)
								}
							} label: {
								Label("Remove from Playlist", systemImage: "trash")
							}
							
						} label: {
							Image(systemName: "ellipsis")
						}
						.padding(.trailing, 15)
						
						
                    }
                }
                .foregroundStyle(.white)
            }
            .padding(.leading, 4)
            .padding(.trailing, 4)
			.padding(.bottom, 5)
            
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
        }
    }
    
    @MainActor
    private func fetchCatalogURL() async {
        // Prevent duplicate API calls
        guard catalogURL == nil, !isLoadingURL else { return }
        isLoadingURL = true
        defer { isLoadingURL = false }
        
        // First check if the track already has a URL (catalog tracks)
        if let existingURL = track.url {
            catalogURL = existingURL
            print("✅ Track already has URL: \(existingURL.absoluteString)")
            return
        }
        
        // If no URL, search the catalog
        do {
            // Search using both title and artist for better results
            let searchTerm = "\(track.title) \(track.artistName)"
            var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
            searchRequest.limit = 10
            
            let searchResponse = try await searchRequest.response()
            
            print("🔍 Searching for: \(searchTerm)")
            print("📊 Found \(searchResponse.songs.count) results")
            
            // Find the matching song by comparing title and artist
            if let matchingSong = searchResponse.songs.first(where: { song in
                song.title.lowercased() == track.title.lowercased() &&
                song.artistName.lowercased() == track.artistName.lowercased()
            }) {
                // Try to use the song's URL if available
                if let songURL = matchingSong.url {
                    catalogURL = songURL
                    print("✅ Found exact match with URL: \(songURL.absoluteString)")
                } else {
                    // Construct Apple Music universal link from song ID
                    let songID = matchingSong.id.rawValue
                    print("🔧 Raw song ID: \(songID)")
                    // Use Apple Music universal link format
                    if let constructedURL = URL(string: "https://music.apple.com/us/song/\(songID)") {
                        catalogURL = constructedURL
                        print("✅ Found exact match, constructed URL: \(constructedURL.absoluteString)")
                    } else {
                        print("❌ Failed to construct URL from ID: \(songID)")
                    }
                }
            } else if let firstResult = searchResponse.songs.first {
                // Use first result as fallback
                if let songURL = firstResult.url {
                    catalogURL = songURL
                    print("⚠️ Using first result with URL: \(songURL.absoluteString)")
                } else {
                    var songID = firstResult.id.rawValue
                    print("🔧 Raw song ID (first result): \(songID)")
                    if songID.hasPrefix("s.") {
                        songID = String(songID.dropFirst(2))
                    }
                    if let constructedURL = URL(string: "https://music.apple.com/us/song/id\(songID)") {
                        catalogURL = constructedURL
                        print("⚠️ Using first result, constructed URL: \(constructedURL.absoluteString)")
                    } else {
                        print("❌ Failed to construct URL from ID: \(songID)")
                    }
                }
            } else {
                print("❌ No search results found")
            }
            
        } catch {
            print("❌ Error fetching catalog track: \(error)")
        }
    }
}
