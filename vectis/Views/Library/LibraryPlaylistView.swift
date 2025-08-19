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
                
                if let safePlaylists = playlists {
                    ForEach(safePlaylists) { playlist in
                        NavigationLink(destination: PlaylistView(playlist)) {
                            HStack {
                                //TODO: implement star for favorites
                                ArtworkImage(playlist.artwork!, width: 75)
                                    .frame(width: 75, height: 75)
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
                        
                        if safePlaylists.last != playlist {
                            Rectangle().frame(width: 365, height: 1).foregroundStyle(Color.gray)
                        }
                        
                    }
                }
                
                
            }
        }
        .padding(.leading, 15)
        .onAppear() {
            Task {
                do {
                    try await loadLibraryPlaylists()
                } catch {
                    print("Error loading playlists: \(error)")
                }
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
