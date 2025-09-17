//
//  harmonyApp.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI
import MusicKit

@main
struct vectisApp: App {
    @StateObject private var appMusicPlayer = AppMusicPlayer()
    
    init() {
        Task.detached {
            let authorization = await MusicAuthorization.request()
            if authorization == .denied {
                //TODO: Alert user to denied
            }
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appMusicPlayer)
        }
    }
}

struct MainView: View {
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                Tab("Home", systemImage: "house") {
                    HomeView()
                }
                Tab("Radio", systemImage: "antenna.radiowaves.left.and.right") {
                    
                }
                Tab("Library", systemImage: "play.square.stack") {
                    LibraryView()
                }
                Tab("Search", systemImage: "magnifyingglass") {
                    
                }
            }
            
            NowPlayingWidget()
                .padding(.bottom, 60)
            
        }
    }
}

struct NowPlayingWidget: View {
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    var body: some View {
        HStack {
            if let song = appMusicPlayer.currentSong {
                if let artwork = song.artwork {
                    ArtworkImage(artwork, width: 32, height: 32)
                        .scaledToFit()
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text("Nothing Playing")
                        .font(.headline)
                }
            }
            VStack(alignment: .leading) {
                if let song = appMusicPlayer.currentSong {
                    Text(song.title)
                        .font(.headline)
                    Text(song.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                if appMusicPlayer.status == .playing {
                    appMusicPlayer.pause()
                    //TODO: Implement pause function
                } else {
                    Task {
                        await appMusicPlayer.play()
                    }
                   
                }
            }) {
                if appMusicPlayer.status == .playing{
                    Image(systemName: "pause.fill")
                } else {
                    Image(systemName: "play.fill")
                }
            }
            .padding(.trailing, 5)
            
            Button(action: {
                Task {
                    await appMusicPlayer.skipToNext()
                }
            }) {
                Image(systemName: "forward.fill")
            }
        }
        .padding(15)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    MainView()
}
