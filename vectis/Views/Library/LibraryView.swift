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
                        NavigationLink (destination: LibraryPlaylistView()) {
                            LibraryCategoryButton("Playlists", buttonImage: "music.note.list")
                        }
                        .tint(.white)
                        
                        LibraryCategoryButton("Artists", buttonImage: "music.microphone")
                        
                        LibraryCategoryButton("Albums", buttonImage: "play.square.stack")
                        
                        LibraryCategoryButton("Songs", buttonImage: "music.note")
                    }
                    .padding(.leading, -15)
                    
                    Text("Recently Added")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack {
                        ForEach(chunkedItems, id: \.self) { row in
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
            
            
            
            print(chunkedItems)
            
        }
    }
    
    func ItemRow(_ row: [ CombinedItems ]) -> some View {
        return HStack {
            ForEach (row, id: \.self) {item in
                switch item {
                case .album(let album):
                    LibraryAlbumButton(album.title, album.artistName)
                    
                case .playlist(let playlist) :
                    LibraryAlbumButton("", "")
                }
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
            print(playlists)

            let albumRequest = MusicLibraryRequest<Album>()
            let albumResponse = try await albumRequest.response()
            albums = albumResponse.items.compactMap{ $0 as Album }
            albums = albums.sorted(by: { $0.libraryAddedDate! > $1.libraryAddedDate! })
            
            items = playlists.map { .playlist($0) } + albums.map { .album($0) }
            
            //TODO: Sort array by date added to library
            
            chunkedItems = chunkArray(array: items, chunkSize: 2)
            
            //print(chunkedItems)
            
            
        } catch {
            print("Error fetching library: \(error)")
        }
                
    }
}

#Preview {
    LibraryView()
}
