//
//  LibrarySongView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/11/25.
//

import SwiftUI
import MusicKit

struct SongSection: Identifiable {
    let id: String
    let songs: [Song]
}

struct LibrarySongView: View {
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    @State var songs: [Song] = []
    @State private var isLoading = false
    
    private var groupedSongs: [(key: String, value: [Song])] {
        let groups = Dictionary(grouping: songs) { song in
            String(song.title.prefix(1)).uppercased()
        }
        
        return groups.sorted { lhs, rhs in
            let lhsIsAlpha = lhs.key.range(of: "^[A-Z]$", options: .regularExpression) != nil
            let rhsIsAlpha = rhs.key.range(of: "^[A-Z]$", options: .regularExpression) != nil
            switch (lhsIsAlpha, rhsIsAlpha) {
            case (true, false): return true
            case (false, true): return false
            default: return lhs.key < rhs.key
            }
        }
    }
    
    private var sections: [SongSection] {
        groupedSongs.map { SongSection(id: $0.key, songs: $0.value) }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text("Songs")
                    .font(.title)
                    .fontWeight(.bold)
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    ForEach(sections) { section in
                        SongSectionView(section: section, allSongs: songs, appMusicPlayer: appMusicPlayer)
                    }
                }
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .task {
            if songs.isEmpty {
                await loadLibrarySongs()
            }
        }
    }
    
    @MainActor
    func loadLibrarySongs() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            
            self.songs = Array(response.items)
            
        } catch {
            print("Error fetching songs: \(error)")
        }
    }
}

struct SongSectionView: View {
    let section: SongSection
    let allSongs: [Song]
    @ObservedObject var appMusicPlayer: AppMusicPlayer
    @State private var catalogURL: URL?
    @State private var isLoadingURL = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.id)
                .font(.headline)
                .padding(.top, 12)
            ForEach(section.songs, id: \.id) { song in
                HStack {
                    Button(action: {
                        Task {
                            let sortedSongs = allSongs.sorted(by: { $0.title < $1.title })
                            let musicCollection = MusicItemCollection(sortedSongs)
                            await appMusicPlayer.enqueuePlaylist(playlist: musicCollection, firstSong: song)
                            await appMusicPlayer.play()
                        }
                    }) {
                        HStack {
                            if let trackArtwork = song.artwork {
                                ArtworkImage(trackArtwork, width: 75, height: 75)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                    .padding(.trailing, 5)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(song.title)
                                    .lineLimit(1)
                                Text(song.artistName)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                        }
                    }
                    .foregroundStyle(.white)
                    
                    Menu {
                        if let url = catalogURL {
                            ShareLink(item: url, subject: Text(song.title), message: Text("Check out this song!")) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } else {
                            Button(action: {
                                Task {
                                    await fetchCatalogURL(for: song)
                                }
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Implement add to playlist functionality
                            print("Add to a Playlist")
                        }) {
                            Label("Add to a Playlist", systemImage: "text.badge.plus")
                        }
                        
                        Button(action: {
                            Task {
                                await appMusicPlayer.playNext(song)
                            }
                        }) {
                            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                        }
                        
                        Button(action: {
                            // TODO: Implement create station functionality (Blocked by issue #24)
                            print("Create Station")
                        }) {
                            Label("Create Station", systemImage: "antenna.radiowaves.left.and.right")
                        }
                        
                        if let album = song.albums?.first {
                            NavigationLink(destination: AlbumView(album)) {
                                Label("Go to Album", systemImage: "square.stack")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Implement view credits functionality
                            print("View Credits")
                        }) {
                            Label("View Credits", systemImage: "person.2")
                        }
                        
                        Button(action: {
                            // TODO: Implement suggest less functionality
                            print("Suggest Less")
                        }) {
                            Label("Suggest Less", systemImage: "hand.thumbsdown")
                        }
                        
                        Button(role: .destructive, action: {
                            Task {
                                await deleteFromLibrary(song)
                            }
                        }) {
                            Label("Delete from Library", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.white)
                            .font(.system(size: 18))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .onAppear {
                        Task {
                            await fetchCatalogURL(for: song)
                        }
                    }
                }
                .padding(.leading, 4)
                .padding(.trailing, 4)
                .padding(.bottom, 2.5)
                
                Rectangle().frame(width: 350, height: 1)
                    .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
            }
        }
    }
    
    @MainActor
    private func fetchCatalogURL(for song: Song) async {
        // Prevent duplicate API calls
        guard catalogURL == nil, !isLoadingURL else { return }
        isLoadingURL = true
        defer { isLoadingURL = false }
        
        // First check if the song already has a URL (catalog songs)
        if let existingURL = song.url {
            catalogURL = existingURL
            print("✅ Song already has URL: \(existingURL.absoluteString)")
            return
        }
        
        // If no URL, search the catalog
        do {
            let searchTerm = "\(song.title) \(song.artistName)"
            var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
            searchRequest.limit = 10
            
            let searchResponse = try await searchRequest.response()
            
            // Find the matching song by comparing title and artist
            if let matchingSong = searchResponse.songs.first(where: { catalogSong in
                catalogSong.title.lowercased() == song.title.lowercased() &&
                catalogSong.artistName.lowercased() == song.artistName.lowercased()
            }) {
                if let songURL = matchingSong.url {
                    catalogURL = songURL
                    print("✅ Found exact match with URL: \(songURL.absoluteString)")
                } else {
                    let songID = matchingSong.id.rawValue
                    if let constructedURL = URL(string: "https://music.apple.com/us/song/\(songID)") {
                        catalogURL = constructedURL
                        print("✅ Found exact match, constructed URL: \(constructedURL.absoluteString)")
                    }
                }
            } else if let firstResult = searchResponse.songs.first {
                if let songURL = firstResult.url {
                    catalogURL = songURL
                    print("⚠️ Using first result with URL: \(songURL.absoluteString)")
                }
            }
        } catch {
            print("❌ Error fetching catalog song: \(error)")
        }
    }
    
    @MainActor
    private func deleteFromLibrary(_ song: Song) async {
        do {
            // Note: MusicKit library management capabilities may be limited
            // This attempts to remove the song from the user's library
            try await MusicLibrary.shared.delete(song)
            print("✅ Deleted song from library: \(song.title)")
        } catch {
            print("❌ Error deleting song from library: \(error)")
        }
    }
}
