//
//  AlbumView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/1/25.
//

import SwiftUI
import MusicKit

struct AlbumView: View {
    
    @State var album: Album
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    init(_ album: Album) {
        self.album = album
        print(album.genreNames)
    }
    
    var body: some View {
        ScrollView {
            if let artwork = album.artwork {
                ArtworkImage(artwork, width: 225, height: 225)
                    .cornerRadius(20)
            }
            
            Text(album.title)
                .bold()
            
            HStack {
                if let genre = album.genreNames.first {
                    Text(genre)
                }
                
                if let releaseYear = album.releaseDate?.formatted(.dateTime.year()) {
                    Text(releaseYear)
                    
                }
                
                if let format = album.audioVariants?.last {
                    //TODO: Replace with badges once Dolby Asset Center is approved
                    switch(format) {
                    case .lossless: Text("Lossless")
                    case .dolbyAtmos: Text("Dolby Atmos")
                    default: Text("")
                    }
                }
            }
                
            HStack {
                Button {
                    Task {
                        if let tracks = album.tracks {
                            await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: tracks[0])
                            await appMusicPlayer.play()
                        }
                        
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(height: 40)
                    .foregroundStyle(.pink)
                }
                .frame(width: 150, alignment: .center)
                .background(Color(red: 40/255, green: 45/255, blue: 45/255))
                .cornerRadius(20)
                
                
                Button {
                    Task {
                        if let tracks = album.tracks {
                            await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: tracks[0])
                            appMusicPlayer.shuffle(true)
                            await appMusicPlayer.play()
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .frame(height: 40)
                    .foregroundStyle(.pink)
                }
                .frame(width: 150, alignment: .center)
                .background(Color(red: 40/255, green: 45/255, blue: 45/255))
                .cornerRadius(20)
            }.padding(.top, 10)
            
            Rectangle().frame(width:350, height: 1)
                .foregroundStyle(.gray)
                .padding(.top, 5)
                .padding(.bottom, 5)
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}
