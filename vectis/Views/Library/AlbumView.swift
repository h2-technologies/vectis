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
                        HStack {
                            Button(action: {
                                Task {
                                    await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: track)
                                    await appMusicPlayer.play()
                                }
                            }) {
                                HStack {
                                    Text("\(index + 1)") // Track number
                                        .padding(.trailing, 5)
                                        .foregroundStyle(.gray)
                                    
                                    Text(track.title)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                }
                            }
                            .foregroundStyle(.white)
                            
                            Menu {
                                Button(action: {
                                    Task {
                                        if let url = track.url {
                                            // Share using the track's URL if available
                                            print("Share: \(url)")
                                        }
                                    }
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                
                                Button(action: {
                                    // TODO: Implement add to playlist functionality
                                    print("Add to a Playlist")
                                }) {
                                    Label("Add to a Playlist", systemImage: "text.badge.plus")
                                }
                                
                                Button(action: {
                                    Task {
                                        await appMusicPlayer.playNext(track)
                                    }
                                }) {
                                    Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
                                }
                                
                                Button(action: {
                                    // TODO: Implement create station functionality
                                    print("Create Station")
                                }) {
                                    Label("Create Station", systemImage: "antenna.radiowaves.left.and.right")
                                }
                                
                                Button(action: {
                                    // TODO: Implement view credits functionality
                                    print("View Credits")
                                }) {
                                    Label("View Credits", systemImage: "person.2")
                                }
                                
                                Button(action: {
                                    // TODO: Implement download functionality
                                    print("Download")
                                }) {
                                    Label("Download", systemImage: "arrow.down.circle")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(.white)
                            }
                            .padding(.trailing, 5)
                        }
                        .frame(height: 30)
                        .padding(.leading, 4)
                        .padding(.trailing, 4)
                        .padding(.bottom, 2.5)
                        
                        Rectangle().frame(width: 350, height: 1)
                            .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
                    }
                    
                    // Album duration at the bottom
                    let totalDuration = tracks.reduce(0.0) { $0 + ($1.duration ?? 0) }
                    HStack {
                        Text(formatAlbumDuration(tracks.count, totalDuration))
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        Spacer()
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                    .padding(.leading, 4)
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
    
    private func formatAlbumDuration(_ songCount: Int, _ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        let songText = songCount == 1 ? "song" : "songs"
        let hourText = hours == 1 ? "hour" : "hours"
        let minuteText = minutes == 1 ? "minute" : "minutes"
        
        if hours > 0 {
            return "\(songCount) \(songText), \(hours) \(hourText) \(minutes) \(minuteText)"
        } else {
            return "\(songCount) \(songText), \(minutes) \(minuteText)"
        }
    }
}
