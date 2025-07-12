//
//  LibraryPlaylistView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistView: View {
    
    @State var playlists: MusicItemCollection<Playlist>?
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Text("Playlists")
                    .font(.title)
                    .fontWeight(.bold)
                
                if (playlists == nil) {
                    Text("No playlists found")
                } else {
                    ForEach(playlists!) { playlist in
                        if playlist == playlists!.last {
                            LibraryPlaylistButton(playlist.name, playlist.artwork, last: true)
                        } else {
                            LibraryPlaylistButton(playlist.name, playlist.artwork)
                        }
                        
                    }
                }
                
                
            }
        }
        .padding(.leading, 15)
        .onAppear() {
            Task {
                try await loadLibraryPlaylists()
            }
        }
    }
    
    @MainActor
    func loadLibraryPlaylists() async throws {
        let request = MusicLibraryRequest<Playlist>()
        let response = try await request.response()
        
        playlists = response.items
    }
        
}


#Preview() {
    LibraryPlaylistView()
}
