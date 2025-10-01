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
    
    init(_ playlists: [Playlist]) {
        self.playlists = playlists.sorted(by: { $0.name < $1.name} )
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Text("Playlists")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(playlists) { playlist in
                    NavigationLink(destination: PlaylistView(playlist)) {
                        HStack {
                            //TODO: implement star for favorites
                            ArtworkImage(playlist.artwork!, width: 70)
                                .frame(width: 70, height: 70)
                                .cornerRadius(5)
                                .padding(.trailing, 10)
                            
                            Text(playlist.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom, 2.5)
                        .foregroundStyle(.white)
                    }
                    
                    if playlists.last != playlist {
                        Rectangle().frame(width: 365, height: 1).foregroundStyle(Color.gray)
                    }
                    
                }
            }
        }
        .padding(.leading, 15)
        
    }
        
}
