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
        VStack {
            ArtworkImage(playlist.artwork!, width: 150)
                .frame(width: 150, height: 150)
                .padding(.bottom)
            
            Text(playlist.name)
                .bold()
            
            Text("Updated \(RelativeDateTimeFormatter().localizedString(for: playlist.lastModifiedDate!, relativeTo: Date()))")
                .font(.caption)
                .foregroundStyle(Color.gray)
            
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
        }
        
        Rectangle().frame(width:300, height: 1)
            .foregroundStyle(.gray)
            .padding(.top, 5)
        
        if (playlist.tracks == nil) {
            Text("Loading tracks")
        } else {
            VStack {
                ForEach(playlist.tracks!) { track in
                    //TODO: Implement song view
                    HStack {
                        //TODO: implement star for favorites
                        ArtworkImage(track.artwork!, width: 75)
                            .frame(width: 75, height: 75)
                            .cornerRadius(5)
                            .padding(.trailing, 10)
                        
                        Text(track.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom, 2.5)
                    .foregroundStyle(.white)
                }
            }
            .onAppear() {
                print("Running onAppear")
                Task {
                    print("Running load task")
                    try await loadPlaylistTracks(self.playlist)
                }
            }
        }
        
        
        
        Spacer()
    }
    
    @MainActor
    func loadPlaylistTracks(_ pl: MusicItemCollection<Playlist>.Element) async throws {
        //Troubleshoot
        print(await MusicAuthorization.request())
        self.playlist = try await pl.with([.tracks])
    }
}
