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
                .padding(.bottom, 10)
            
            if let tracks = album.tracks {
                VStack {
                    ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                        Button(action: {
                            Task {
                                await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: track)
                                await appMusicPlayer.play()
                            }
                        }) {
                                Text("\(index + 1)") // Track number
                                    .padding(.trailing, 5)
                                    .foregroundStyle(.gray)
                                
                                Text(track.title)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Menu")
                                }) {
                                    Image(systemName: "ellipsis")
                                }
                                .padding(.trailing, 5)
                            
                        }
                        .frame(height: 30)
                        .padding(.leading, 4)
                        .padding(.trailing, 4)
                        .padding(.bottom, 2.5)
                        .foregroundStyle(.white)
                        
                        Rectangle().frame(width: 350, height: 1)
                            .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
                    }
                }
                
                Spacer()
            }
            
        }
        .task(id: album.id) {
            do {
                self.album = try await album.with(.tracks)
            } catch {
                print("Error fetching album tracks: \(error)")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}
