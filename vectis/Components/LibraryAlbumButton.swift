//
//  LibraryAlbumButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryAlbumButton: View {
    var album: String
    var artist: String
    var artwork: Artwork

    init(_ album: String, _ artist: String, _ artwork: Artwork) {
        self.album = album
        self.artist = artist
        self.artwork = artwork
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            ArtworkImage(artwork, width: 175, height: 175)
                .frame(width: 175, height: 175)
                .cornerRadius(5)
            
            Text(album)
                .font(.subheadline)
                .padding(.leading, 2.5)
                .lineLimit(1)
                .foregroundStyle(.white)
            
            Text(artist)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 2.5)
        }
        
    }
}
