//
//  LibraryView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI
import MusicKit

enum CombinedItems: Hashable {
    case album(Album)
    case playlist(Playlist)
    
    var libraryAddedDate: Date? {
        switch self {
        case .album (let album):
            return album.libraryAddedDate
        case .playlist (let playlist):
            return playlist.libraryAddedDate
        }
    }
}

struct LibraryView: View {
    @State var playlists: [Playlist] = []
    @State var albums: [Album] = []
    @State var items: [CombinedItems] = []
    @State var chunkedItems: [[CombinedItems]] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    Text("Library")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 15)
                    
                    VStack {
                        NavigationLink (destination: LibraryPlaylistView(playlists)) {
                            LibraryCategoryButton("Playlists", buttonImage: "music.note.list")
                        }
                        
                        NavigationLink (destination: LibraryArtistView()) {
                            LibraryCategoryButton("Artists", buttonImage: "music.microphone")
                        }
                        
                        NavigationLink (destination: LibraryAlbumView(albums)) {
                            LibraryCategoryButton("Albums", buttonImage: "play.square.stack")
                        }
                        
                        NavigationLink(destination: LibrarySongView()) {
                            LibraryCategoryButton("Songs", buttonImage: "music.note")
                        }
                        
                    }
                    .padding(.leading, -15)
                    .tint(.white)
                    
                    Text("Recently Added")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(chunkedItems.enumerated()), id: \.offset) { index, row in
                                ItemRow(row)
                            }
                        }
                    }
                }
                .padding(.leading, 15)
            }
        }.task {
            if items.isEmpty {
                await loadLibrary()
            }
        }
    }
    
    func ItemRow(_ row: [ CombinedItems ]) -> some View {
        return HStack {
            ForEach (row, id: \.self) {item in
                LibraryItemView(item)
            }
            .padding(.trailing, 15)
            
        }
    }

    
    @MainActor
    func loadLibrary() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Fetch playlists and albums concurrently
            async let playlistsFetch = MusicLibraryRequest<Playlist>().response()
            async let albumsFetch = MusicLibraryRequest<Album>().response()
            
            // Wait for both to complete
            let (playlistResponse, albumResponse) = try await (playlistsFetch, albumsFetch)
            
            playlists = Array(playlistResponse.items)
            albums = Array(albumResponse.items)
            
            // Sort once on combined items instead of sorting each collection separately
            items = (playlists.map { CombinedItems.playlist($0) } + albums.map { CombinedItems.album($0) })
                .sorted(by: { ($0.libraryAddedDate ?? Date.distantPast) > ($1.libraryAddedDate ?? Date.distantPast) })
            
            // Limit to recent items only (e.g., 20 items = 10 rows)
            let recentItems = Array(items.prefix(20))
            
            // Chunk in background
            chunkedItems = await Task.detached {
                chunkArray(array: recentItems, chunkSize: 2)
            }.value
            
        } catch {
            print("Error fetching library: \(error)")
        }
    }
}

struct LibraryItemView: View {
    let item: CombinedItems
    
    init(_ item: CombinedItems) {
        self.item = item
    }
    
    var body: some View {
        switch item {
        case .album(let album):
            NavigationLink(destination: AlbumView(album)) {
                LibraryAlbumButton(album.title, album.artistName, album.artwork!)
            }
        case .playlist(let playlist):
            NavigationLink(destination: PlaylistView(playlist)) {
                LibraryPlaylistButton(playlist.name, playlist.artwork!)
            }
        }
    }
}
