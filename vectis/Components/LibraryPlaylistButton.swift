//
//  LibraryPlaylistButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/6/25.
//

import SwiftUI
import MusicKit

struct LibraryPlaylistButton: View {
    
    var label: String
    var artwork: Artwork?
    var last: Bool
    
    init(_ label: String, _ artwork: Artwork? = nil, last: Bool = false) {
        self.label = label
        self.artwork = artwork
        self.last = last
    }
    
    var body: some View {
        HStack {
            //TODO: implement star for favorites
            if artwork == nil {
                Rectangle()
                    .frame(width: 75, height: 75)
                    .cornerRadius(5)
                    .padding(.trailing, 10)
            } else {
                ArtworkImage(artwork!, width: 75)
                    .frame(width: 75, height: 75)
                    .cornerRadius(5)
                    .padding(.trailing, 10)
            }
            
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 2.5)
        
        if !last {
            Rectangle().frame(width: 365, height: 1).foregroundStyle(Color.gray)
        }
    }
}

#Preview {
    LibraryPlaylistButton("Preview 1")
}
