//
//  TrackRowView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/12/25.
//

import SwiftUI
import MusicKit

struct TrackRowView: View {
    let track: Track
    let tracks: MusicItemCollection<Track>
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    Task {
                        await appMusicPlayer.enqueuePlaylist(playlist: tracks, firstSong: track)
                        await appMusicPlayer.play()
                    }
                }) {
                    HStack {
                        if let trackArtwork = track.artwork {
                            ArtworkImage(trackArtwork, width: 75)
                                .frame(width: 50, height: 50)
                                .clipShape(.rect(cornerRadius: 5))
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
                    }
                }
                .foregroundStyle(.white)
                
                Menu {
                    Button(action: {
                        Task {
                            print("Share button tapped for: \(track.title)")
                            
                            print(track.url)
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
                        // TODO: Implement play next functionality
                        print("Play Next")
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
                        // TODO: Implement go to album functionality
                        print("Go to Album")
                    }) {
                        Label("Go to Album", systemImage: "square.stack")
                    }
                    
                    Button(action: {
                        // TODO: Implement view credits functionality
                        print("View Credits")
                    }) {
                        Label("View Credits", systemImage: "person.2")
                    }
                    
                    Button(role: .destructive, action: {
                        // TODO: Implement remove from playlist functionality
                        print("Remove from Playlist")
                    }) {
                        Label("Remove from Playlist", systemImage: "trash")
                    }
                    
                    Button(action: {
                        // TODO: Implement add/remove download functionality
                        print("Add/Remove Download")
                    }) {
                        Label("Download", systemImage: "arrow.down.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            }
            .padding(.leading, 4)
            .padding(.trailing, 4)
            .padding(.bottom, 2.5)
            
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundStyle(Color(red: 69/255, green: 74/255, blue: 82/255))
        }
    }
}
