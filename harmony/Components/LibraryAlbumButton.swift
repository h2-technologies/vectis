//
//  LibraryAlbumButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI

struct LibraryAlbumButton: View {
    var album: String
    var artist: String
    
    init(_ album: String, _ artist: String) {
        self.album = album
        self.artist = artist
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Rectangle()
                .frame(width: 175, height: 175)
                .cornerRadius(5)
            
            Text(album)
                .font(.headline)
                .padding(.leading, 2.5)
            
            Text(artist)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 2.5)
        }
        
    }
}


#Preview() {
    LibraryAlbumButton("Album", "Artist")
}
