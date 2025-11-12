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
                    .clipShape(.rect(cornerRadius: 20))
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
                .clipShape(.rect(cornerRadius: 20))
                
                
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
                .clipShape(.rect(cornerRadius: 20))
            }.padding(.top, 10)
            
            Rectangle().frame(width:350, height: 1)
                .foregroundStyle(.gray)
                .padding(.top, 5)
                .padding(.bottom, 5)
            
            if let tracks = playlist.tracks {
                trackListView(tracks: tracks)
            }
            
            //TODO: Add an "Add Songs" button
            
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
    }
    
    @ViewBuilder
    private func trackListView(tracks: MusicItemCollection<Track>) -> some View {
        VStack {
            ForEach(Array(tracks), id: \.id) { track in
                TrackRowView(
                    track: track, 
                    tracks: tracks,
                    isPlaylistContext: true,
                    onRemoveFromPlaylist: {
                        Task {
                            await removeTrackFromPlaylist(track)
                        }
                    }
                )
                .environmentObject(appMusicPlayer)
            }
        }
        
        // Playlist duration at the bottom
        HStack {
            Text(formatPlaylistDuration(tracks.count, tracks.reduce(0.0) { $0 + ($1.duration ?? 0) }))
                .font(.caption)
                .foregroundStyle(Color.gray)
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 10)
        .padding(.leading, 4)
    }
    
    @MainActor
    private func removeTrackFromPlaylist(_ track: Track) async {
        // Note: MusicKit's Playlist editing capabilities are limited
        // This is a placeholder for when the API supports it
        print("Remove track from playlist: \(track.title)")
        // TODO: Implement actual removal when MusicKit API supports it
        // For now, just log the action
    }
    
    private func formatPlaylistDuration(_ songCount: Int, _ totalDuration: TimeInterval) -> String {
        let hours = Int(totalDuration) / 3600
        let minutes = (Int(totalDuration) % 3600) / 60
        
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
