//
//  ArtistView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/5/25.
//
import MusicKit
import SwiftUI

struct ArtistView: View {
    
    @State var artist: Artist
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    init(_ artist: Artist) {
        
        self.artist = artist
        
       
    }
    
    var body: some View {
        ScrollView {
            if let artwork = artist.artwork {
                ArtworkImage(artwork, width: 100, height: 100)
                    .cornerRadius(20)
            }
            
            //TODO: Take to artist page outside of library
            //Reference issue #18
            Text(artist.name)
                .bold()
                .font(.headline)
            
            HStack {
                Button {
                    Task {
                        await appMusicPlayer.enqueueArtist(artist)
                            
                        await appMusicPlayer.play()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(height: 40)
                    .foregroundStyle(.pink)
                }
            }
            
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 16) {
                if let albums = artist.albums as? [Album] {
                    ForEach(albums, id: \.id) { album in
                        NavigationLink(destination: AlbumView(album)) {
                            Text(album.title)
                        }
                    }
                }
            }
        
        }.task(id: artist.id) {
            do {
                self.artist = try await artist.with(.albums)
                self.artist.albums = self.artist.albums?.sorted(by: { $0.title < $1.title })
            } catch {
                print("Error loading artist albums: \(error)")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}
