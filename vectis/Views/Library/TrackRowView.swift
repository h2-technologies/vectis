//
//  TrackRowView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/12/25.
//

import SwiftUI
import MusicKit

struct TrackRowView: View {
    let track: Track
    let tracks: MusicItemCollection<Track>
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
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
                    }
                }
                .foregroundStyle(.white)
                
                Menu {
                    if let url = catalogURL {
                        ShareLink(item: url, subject: Text(track.title), message: Text("Check out this song!")) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Button(action: {
                            Task {
                                await fetchCatalogURL()
                            }
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    // ...existing menu items...
                    Button(action: {
                        // TODO: Implement add to playlist functionality
                        print("Add to a Playlist")
                    }) {
                        Label("Add to a Playlist", systemImage: "text.badge.plus")
                    }
                    
                    Button(action: {
                        // TODO: Implement play next functionality
                        print("Play Next")
                    }) {
                        Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                    }
                    
                    Button(action: {
                        // TODO: Implement create station functionality
                        print("Create Station")
                    }) {
                        Label("Create Station", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    
                    Button(action: {
                        // TODO: Implement go to album functionality
                        print("Go to Album")
                    }) {
                        Label("Go to Album", systemImage: "square.stack")
                    }
                    
                    Button(action: {
                        // TODO: Implement view credits functionality
                        print("View Credits")
                    }) {
                        Label("View Credits", systemImage: "person.2")
                    }
                    
                    Button(role: .destructive, action: {
                        // TODO: Implement remove from playlist functionality
                        print("Remove from Playlist")
                    }) {
                        Label("Remove from Playlist", systemImage: "trash")
                    }
                    
                    Button(action: {
                        // TODO: Implement add/remove download functionality
                        print("Add/Remove Download")
                    }) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .onAppear {
                    // Fetch the catalog URL when the menu appears
                    Task {
                        await fetchCatalogURL()
                    }
                }
            }
            .padding(.leading, 4)
            .padding(.trailing, 4)
            .padding(.bottom, 2.5)
            
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
