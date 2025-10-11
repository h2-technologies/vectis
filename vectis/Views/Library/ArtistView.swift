//
//  ArtistView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/5/25.
//
import MusicKit
import SwiftUI

struct ArtistView: View {
    let artist: Artist
    @State private var albums: [Album] = []
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
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
                .font(.largeTitle)
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
                ForEach(albums.sorted(by: { $0.libraryAddedDate ?? Date() > $1.libraryAddedDate ?? Date()}), id: \.id) { album in
                    NavigationLink(destination: AlbumView(album)) {
                        VStack {
                            if let artwork = album.artwork {
                                ArtworkImage(artwork, width: 175, height: 175)
                                    .cornerRadius(12)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(12)
                            }
                            VStack(alignment: .leading) {
                                Text(album.title)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(album.releaseDate?.formatted(.dateTime.year()) ?? "Unknown Year")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                    }
                }
            }
        }
        .task(id: artist.id) {
            do {
                let loaded = try await artist.with(.albums)
                if let loadedAlbums = loaded.albums {
                    self.albums = loadedAlbums.sorted { $0.title < $1.title }
                }
            } catch {
                print("Error loading artist albums: \(error)")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}
