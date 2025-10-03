//
//  LibraryAlbumView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI
import MusicKit

struct LibraryAlbumView: View {
    @State var albums: [Album]
    
    private var groupedAlbums: [(key: String, value: [Album])] {
        let groups = Dictionary(grouping: albums) { album in
            String(album.artistName.prefix(1)).uppercased()
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
    
    init(_ albums: [Album]) {
        self.albums = albums.sorted(by: { $0.artistName < $1.artistName} )
    }
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Text("Albums")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(groupedAlbums, id: \.key) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.key)
                            .font(.headline)
                            .padding(.top, 12)
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(section.value, id: \.id) { album in
                                NavigationLink(destination: AlbumView(album)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let artwork = album.artwork {
                                            ArtworkImage(artwork, width: 175, height: 175)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 175, height: 175)
                                                .cornerRadius(8)
                                        } else {
                                            Color.gray.opacity(0.2)
                                                .frame(width: 175, height: 175)
                                                .cornerRadius(8)
                                        }
                                        Text(album.title)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                            .foregroundStyle(.white)
                                        Text(album.artistName)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
