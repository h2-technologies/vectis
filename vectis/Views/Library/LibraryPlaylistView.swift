//
//  LibraryPlaylistView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistView: View {
    
    @State var playlists: [Playlist]
    
    private var sortedPlaylists: [Playlist] {
        playlists.sorted(by: { $0.name < $1.name })
    }
    
    init(_ playlists: [Playlist]) {
        self.playlists = playlists
    }
    
    var body: some View {
        ScrollView {
            LazyVStack (alignment: .leading, spacing: 0) {
                Text("Playlists")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)
                
                ForEach(Array(sortedPlaylists.enumerated()), id: \.element.id) { index, playlist in
                    NavigationLink(destination: PlaylistView(playlist)) {
                        HStack {
                            //TODO: implement star for favorites
                            if let artwork = playlist.artwork {
                                ArtworkImage(artwork, width: 70)
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(5)
                                    .padding(.trailing, 10)
                            } else {
                                Color.gray.opacity(0.2)
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(5)
                                    .padding(.trailing, 10)
                            }
                            
                            Text(playlist.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.trailing)
                        .padding(.bottom, 2.5)
                        .foregroundStyle(.white)
                    }
                    .padding(.bottom, 2.5)
                    .padding(.top, 2.5)
                    
                    if index < sortedPlaylists.count - 1 {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(Color.gray)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.leading, 15)
        
    }
        
}
