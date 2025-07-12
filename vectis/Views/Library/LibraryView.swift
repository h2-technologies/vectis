//
//  LibraryView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI
import MusicKit

struct LibraryView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading) {
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
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack {
                        HStack {
                            LibraryAlbumButton("Album 1", "Arist 1")
                            Spacer()
                            LibraryAlbumButton("Album 2", "Arist 1")
                        }
                        .padding(.trailing, 15)
                        
                        HStack {
                            LibraryAlbumButton("Album 3", "Arist 2")
                            Spacer()
                            LibraryAlbumButton("Album 4", "Arist 2")
                        }
                        .padding(.trailing, 15)
                        
                    }
                }
                .padding(.leading, 15)
            }
        }
    }
}

#Preview {
    LibraryView()
}
