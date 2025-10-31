//
//  SearchView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/27/25.
//

import SwiftUI
import MusicKit

struct SearchView: View {
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    @State private var searchText: String = ""
    @State private var songs: [Song] = []
    @State private var filteredSongs: [Song] = []
    @State private var isLoading: Bool = false
    @State private var searchTask: Task<Void, Never>?
    @State private var songsLoaded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text("Search")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 10)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search songs, artists, albums...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) {
                        performSearch(query: searchText)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        filteredSongs = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(red: 45/255, green: 48/255, blue: 54/255))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            // Results
            if isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if searchText.isEmpty {
                // Empty state
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("Search your library")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Find songs, artists, and albums")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else if filteredSongs.isEmpty {
                // No results
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No results found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Try a different search term")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                // Results list
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(filteredSongs.count) song\(filteredSongs.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        ForEach(filteredSongs, id: \.id) { song in
                            Button(action: {
                                Task {
                                    let musicCollection = MusicItemCollection(filteredSongs)
                                    await appMusicPlayer.enqueuePlaylist(playlist: musicCollection, firstSong: song)
                                    await appMusicPlayer.play()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    // Album Artwork
                                    if let artwork = song.artwork {
                                        ArtworkImage(artwork, width: 50, height: 50)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(5)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(5)
                                            .overlay(
                                                Image(systemName: "music.note")
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    
                                    // Song Info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(song.title)
                                            .lineLimit(1)
                                            .foregroundColor(.white)
                                        Text(song.artistName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                        if let albumTitle = song.albumTitle {
                                            Text(albumTitle)
                                                .font(.caption2)
                                                .foregroundColor(.gray.opacity(0.8))
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    // Menu Button
                                    Button(action: {
                                        //TODO: Add action menu
                                        print("Menu for \(song.title)")
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing, 5)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Divider
                            if song.id != filteredSongs.last?.id {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
                                    .padding(.leading, 74)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    func loadLibrarySongs() async {
        isLoading = true
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            self.songs = response.items.compactMap { $0 as Song }
        } catch {
            print("Error fetching songs: \(error)")
        }
        isLoading = false
    }
    
    func performSearch(query: String) {
        // Cancel any existing search task
        searchTask?.cancel()
        
        // If query is empty, clear results immediately
        guard !query.isEmpty else {
            filteredSongs = []
            return
        }
        
        searchTask = Task {
            // Load songs on first search if not already loaded
            if !songsLoaded {
                await loadLibrarySongs()
                songsLoaded = true
            }
            
            // Capture songs array on main thread before going to background
            let songsToSearch = self.songs
            
            // Debounce: wait 300ms before performing search
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            
            // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            // Perform filtering off the main thread
            let results = await Task.detached {
                let filtered = songsToSearch.filter { song in
                    song.title.localizedCaseInsensitiveContains(query) ||
                    song.artistName.localizedCaseInsensitiveContains(query) ||
                    song.albumTitle?.localizedCaseInsensitiveContains(query) ?? false
                }
                
                // Sort by relevance: title matches first, then artist, then album
                return filtered.sorted { song1, song2 in
                    let song1TitleMatch = song1.title.localizedCaseInsensitiveContains(query)
                    let song2TitleMatch = song2.title.localizedCaseInsensitiveContains(query)
                    let song1ArtistMatch = song1.artistName.localizedCaseInsensitiveContains(query)
                    let song2ArtistMatch = song2.artistName.localizedCaseInsensitiveContains(query)
                    
                    // Both match title - sort alphabetically by title
                    if song1TitleMatch && song2TitleMatch {
                        return song1.title.localizedCaseInsensitiveCompare(song2.title) == .orderedAscending
                    }
                    // Only song1 matches title
                    if song1TitleMatch { return true }
                    // Only song2 matches title
                    if song2TitleMatch { return false }
                    
                    // Both match artist - sort alphabetically by title
                    if song1ArtistMatch && song2ArtistMatch {
                        return song1.title.localizedCaseInsensitiveCompare(song2.title) == .orderedAscending
                    }
                    // Only song1 matches artist
                    if song1ArtistMatch { return true }
                    // Only song2 matches artist
                    if song2ArtistMatch { return false }
                    
                    // Both match album (or neither) - sort alphabetically by title
                    return song1.title.localizedCaseInsensitiveCompare(song2.title) == .orderedAscending
                }
            }.value
            
            // Update UI on main thread
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.filteredSongs = results
            }
        }
    }
}

#Preview {
    SearchView()
}
