//
//  LibrarySongView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/11/25.
//

import SwiftUI
import MusicKit

struct SongSection: Identifiable {
    let id: String
    let songs: [Song]
}

struct LibrarySongView: View {
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    @State var songs: [Song] = []
    
    private var groupedSongs: [(key: String, value: [Song])] {
        let groups = Dictionary(grouping: songs) { song in
            String(song.title.prefix(1)).uppercased()
        }
        
        return groups.sorted { lhs, rhs in
            let lhsIsAlpha = lhs.key.range(of: "^[A-Z]$", options: .regularExpression) != nil
            let rhsIsAlpha = rhs.key.range(of: "^[A-Z]$", options: .regularExpression) != nil
            switch (lhsIsAlpha, rhsIsAlpha) {
            case (true, false): return true
            case (false, true): return false
            default: return lhs.key < rhs.key
            }
        }
    }
    
    private var sections: [SongSection] {
        groupedSongs.map { SongSection(id: $0.key, songs: $0.value) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Songs")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(sections) { section in
                    SongSectionView(section: section, allSongs: songs, appMusicPlayer: appMusicPlayer)
                }
                Spacer()
            }.onAppear() {
                Task {
                    await loadLibrarySongs()
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        
    }
    
    @MainActor
    func loadLibrarySongs() async {
        do {
            let request = MusicLibraryRequest<Song>()
            let response = try await request.response()
            
            self.songs = response.items.compactMap { $0 as Song }
            
            print(response)
        } catch {
            print("Error fetching songs: \(error)")
        }
    }
}

struct SongSectionView: View {
    let section: SongSection
    let allSongs: [Song]
    @ObservedObject var appMusicPlayer: AppMusicPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.id)
                .font(.headline)
                .padding(.top, 12)
            ForEach(section.songs, id: \.id) { song in
                Button(action: {
                    Task {
                        let sortedSongs = allSongs.sorted(by: { $0.title < $1.title })
                        let musicCollection = MusicItemCollection(sortedSongs)
                        await appMusicPlayer.enqueuePlaylist(playlist: musicCollection, firstSong: song)
                        await appMusicPlayer.play()
                    }
                }) {
                    HStack {
                        if let trackArtwork = song.artwork {
                            ArtworkImage(trackArtwork, width: 75, height: 75)
                                .frame(width: 50, height: 50)
                                .cornerRadius(5)
                                .padding(.trailing, 5)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .lineLimit(1)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            //TODO: Add action menu
                            //Ref issue #21
                            print("Menu")
                        }) {
                            Image(systemName: "ellipsis")
                        }
                        .padding(.trailing, 5)
                    }
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
}
