//
//  PlaylistView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/12/25.
//

import SwiftUI
import MusicKit

struct PlaylistView: View {
    
    @State var playlist: MusicItemCollection<Playlist>.Element
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    init(_ playlist: MusicItemCollection<Playlist>.Element) {
        self.playlist = playlist
    }
    
    var body: some View {
        ScrollView {
            if let artwork = playlist.artwork {
                ArtworkImage(artwork, width: 225, height: 225)
                    .cornerRadius(20)
            }
            
            
            Text(playlist.name)
                .bold()
            
            if let lastModifiedDate = playlist.lastModifiedDate {
                Text("Updated \(RelativeDateTimeFormatter().localizedString(for: lastModifiedDate, relativeTo: Date()))")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
            
            HStack {
                Button {
                    Task {
                        if let tracks = playlist.tracks {
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
                        if let tracks = playlist.tracks {
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
            
            if let tracks = playlist.tracks {
                VStack {
                    ForEach(tracks, id: \.id) { track in
                        //TODO: Implement song view
                        Button(action: {
                            Task {
                                await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: track)
                                await appMusicPlayer.play()
                            }
                        }) {
                                //TODO: implement star for favorites
                                if let trackArtwork = track.artwork {
                                    ArtworkImage(trackArtwork, width: 75)
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(5)
                                        .padding(.trailing, 5)
                                }
                                
                                
                                VStack(alignment: .leading) {
                                    Text(track.title)
                                        .lineLimit(1)
                                        
                                    Text(track.artistName)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Menu")
                                }) {
                                    Image(systemName: "ellipsis")
                                }
                                .padding(.trailing, 5)
                            
                            
                        }
                        .padding(.leading, 4)
                        .padding(.trailing, 4)
                        .padding(.bottom, 2.5)
                        .foregroundStyle(.white)
                        
                        Rectangle().frame(width: 350, height: 1)
                            .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
                    }
                    
                }
            }
            
            //TODO: Add an "Add Songs" button
            
            //TODO: Display song duration
            
            Spacer()
        }
        .task(id: playlist.id) {
            do {
                self.playlist = try await playlist.with(.tracks)
            } catch {
                print("Error fetching playlist tracks: \(error)")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
    
}
