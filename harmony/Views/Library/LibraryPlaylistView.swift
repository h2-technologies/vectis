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
                
            }
        }
        .padding(.leading, 15)
    }
}


#Preview() {
    LibraryPlaylistView()
}
