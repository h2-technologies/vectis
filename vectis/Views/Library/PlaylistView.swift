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
                    
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .frame(height: 40)
                    .foregroundStyle(.pink)
                }
                .frame(width: 150, alignment: .center)
                .background(Color(red: 80/255, green: 90/255, blue: 90/255))
                .cornerRadius(20)
                
                
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                    }
                    .frame(height: 40)
                    .foregroundStyle(.pink)
                }
                .frame(width: 150, alignment: .center)
                .background(Color(red: 80/255, green: 90/255, blue: 90/255))
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
                        HStack {
                            //TODO: implement star for favorites
                            if let trackArtwork = track.artwork {
                                ArtworkImage(trackArtwork, width: 75)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                                    .padding(.trailing, 5)
                            }
                            
                            
                            VStack(alignment: .leading) {
                                Text(track.title)
                                    
                                Text(track.artistName)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.trailing)
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
            print("Fetching playlist tracks")
            do {
                self.playlist = try await playlist.with(.tracks)
                print("Playlist tracks fetched")
            } catch {
                print("Error fetching playlist tracks: \(error)")
            }
        }
    }
    
}
