//
//  ArtistView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/5/25.
//
import MusicKit
import SwiftUI

struct ArtistView: View {
    
    @State var artist: Artist
    
    @EnvironmentObject private var appMusicPlayer: AppMusicPlayer
    
    init(_ artist: Artist) {
        self.artist = artist
    }
    
    var body: some View {
        ScrollView {
            Text("Artist View")
        }
    }
}
