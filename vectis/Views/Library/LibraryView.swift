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
                    
                    VStack {
                        ForEach(Array(chunkedItems.enumerated()), id: \.offset) { index, row in
                            ItemRow(row)
                        }
                        
                    }
                }
                .padding(.leading, 15)
            }
        }.onAppear() {
            Task {
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
        do {
            let playlistRequest = MusicLibraryRequest<Playlist>()
            let playlistResponse = try await playlistRequest.response()
            playlists = playlistResponse.items.compactMap { $0 as Playlist }
            playlists = playlists.sorted(by: { ($0.libraryAddedDate ?? Date.distantPast) > ($1.libraryAddedDate ?? Date.distantPast) })

            let albumRequest = MusicLibraryRequest<Album>()
            let albumResponse = try await albumRequest.response()
            albums = albumResponse.items.compactMap{ $0 as Album }
            albums = albums.sorted(by: { ($0.libraryAddedDate ?? Date.distantPast) > ($1.libraryAddedDate ?? Date.distantPast) })
            
            items = playlists.map { .playlist($0) } + albums.map { .album($0) }
            
            items = items.sorted(by: { ($0.libraryAddedDate ?? Date.distantPast) > ($1.libraryAddedDate ?? Date.distantPast) })
            
            chunkedItems = chunkArray(array: items, chunkSize: 2)
            
            
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
