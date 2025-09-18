//
//  LibraryPlaylistButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistButton: View {
    var name: String
    var artwork: Artwork
    
    init(_ name: String, _ artwork: Artwork) {
        self.name = name
        self.artwork = artwork
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            ArtworkImage(artwork, width: 175, height: 175)
                .frame(width: 175, height: 175)
                .cornerRadius(5)
            
            Text(name)
                .font(.subheadline)
                .padding(.leading, 2.5)
                .lineLimit(1)
            
            Text("")
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 2.5)
        }
        
    }
}
