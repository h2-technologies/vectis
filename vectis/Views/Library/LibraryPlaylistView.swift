//
//  LibraryPlaylistView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistView: View {
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Text("Playlists")
                    .font(.title)
                    .fontWeight(.bold)
                
                LibraryPlaylistButton("Playlist 1")
                LibraryPlaylistButton("Playlist 2")
                LibraryPlaylistButton("Playlist 3")
                LibraryPlaylistButton("Playlist 4")
                LibraryPlaylistButton("Playlist 5")
                
                
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
        print(response)
    }
        
}


#Preview() {
    LibraryPlaylistView()
}
