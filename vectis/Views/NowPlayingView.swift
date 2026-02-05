//
//  NowPlayingView.swift
//  vectis
//
//  Created by Samuel Valencia on 11/2/25.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    @Environment(\.dismiss) private var dismiss
    @State private var isSeeking = false
    @State private var seekPosition: TimeInterval = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient based on artwork
                if let song = appMusicPlayer.currentSong, let artwork = song.artwork {
                    ArtworkImage(artwork, width: 500, height: 500)
                        .blur(radius: 100)
                        .opacity(0.3)
                        .ignoresSafeArea()
                }
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Album Artwork
                    if let song = appMusicPlayer.currentSong {
                        if let artwork = song.artwork {
                            ArtworkImage(artwork, width: 300, height: 300)
                                .frame(width: 300, height: 300)
                                .cornerRadius(12)
                                .shadow(radius: 20)
                        } else {
                            ZStack {
                                Color.gray.opacity(0.2)
                                Image(systemName: "music.note")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 300, height: 300)
                            .cornerRadius(12)
                        }
                        
                        // Song Info
                        VStack(spacing: 8) {
                            Text(song.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(1)
                            
                            Text(song.artistName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            
                            if let albumTitle = song.albumTitle {
                                Text(albumTitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Progress Bar with Seeking
                        VStack(spacing: 8) {
                            Slider(
                                value: isSeeking ? $seekPosition : Binding(
                                    get: { appMusicPlayer.playbackTime },
                                    set: { seekPosition = $0 }
                                ),
                                in: 0...(song.duration ?? 0),
                                onEditingChanged: { editing in
                                    isSeeking = editing
                                    if !editing {
                                        Task {
                                            await appMusicPlayer.seek(to: seekPosition)
                                        }
                                    } else {
                                        seekPosition = appMusicPlayer.playbackTime
                                    }
                                }
                            )
                            .tint(.white)
                            .accentColor(.white)
                            
                            HStack {
                                Text(formatTime(isSeeking ? seekPosition : appMusicPlayer.playbackTime))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(formatTime(song.duration ?? 0))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        
                    } else {
                        // Nothing Playing
                        VStack(spacing: 20) {
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.secondary)
                            
                            Text("Nothing Playing")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Playback Controls
                    HStack(spacing: 40) {
                        Button(action: {
                            Task {
                                await appMusicPlayer.skipToPrevious()
                            }
                        }) {
                            Image(systemName: "backward.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                        
                        Button(action: {
                            if appMusicPlayer.status == .playing {
                                appMusicPlayer.pause()
                            } else {
                                Task {
                                    await appMusicPlayer.play()
                                }
                            }
                        }) {
                            Image(systemName: appMusicPlayer.status == .playing ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                        
                        Button(action: {
                            Task {
                                await appMusicPlayer.skipToNext()
                            }
                        }) {
                            Image(systemName: "forward.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                    }
                    .padding(.top, 20)
                    
                    // Additional Controls (Lyrics, Queue & AirPlay)
                    HStack(spacing: 50) {
                        Button(action: {
                            // TODO: Show lyrics
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "quote.bubble")
                                    .font(.title2)
                                Text("Lyrics")
                                    .font(.caption)
                            }
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                        
                        Button(action: {
                            // TODO: Show AirPlay picker
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "airplayaudio")
                                    .font(.title2)
                                Text("AirPlay")
                                    .font(.caption)
                            }
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                        
                        Button(action: {
                            // TODO: Show queue
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "list.bullet")
                                    .font(.title2)
                                Text("Queue")
                                    .font(.caption)
                            }
                        }
                        .disabled(appMusicPlayer.currentSong == nil)
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NowPlayingView()
        .environmentObject(AppMusicPlayer())
}
