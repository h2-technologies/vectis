//
//  LibraryArtistView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/5/25.
//
import SwiftUI
import MusicKit

struct ArtistRow: View {
    let artist: Artist
    var body: some View {
        HStack {
            if let artwork = artist.artwork {
                ArtworkImage(artwork, width: 50, height: 50)
                    .frame(width: 50, height: 50)
                    .cornerRadius(30)
                    .padding(.trailing, 10)
            }
            Text(artist.name)
                .lineLimit(2)
                .font(.body)
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 2.5)
        .foregroundStyle(.white)
    }
}

struct ArtistSection: Identifiable {
    let id: String
    let artists: [Artist]
}

struct LibraryArtistView: View {
    
    @State var artists: [Artist] = []
    @State private var isLoading = false
    
    private var groupedArists: [(key: String, value: [Artist])] {
        let groups = Dictionary(grouping: artists) { artist in
            String(artist.name.prefix(1)).uppercased()
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
    
    var body: some View {
        let groupedSections: [ArtistSection] = groupedArists.map { ArtistSection(id: $0.key, artists: $0.value) }
        ScrollView {
            LazyVStack(alignment: .leading) {
                Text("Artists")
                    .font(.title)
                    .fontWeight(.bold)
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else {
                    ForEach(groupedSections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.id)
                                .font(.headline)
                                .padding(.top, 12)
                            ForEach(section.artists.indices, id: \.self) { idx in
                                let artist = section.artists[idx]
                                NavigationLink(destination: ArtistView(artist: artist)) {
                                    ArtistRow(artist: artist)
                                }
                                if idx < section.artists.count - 1 {
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(Color.gray)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            if artists.isEmpty {
                await loadArtists()
            }
        }
        .padding(.leading, 15)
    }
    
    @MainActor
    func loadArtists() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = MusicLibraryRequest<Artist>()
            let response = try await request.response()
            artists = Array(response.items)
            
        } catch {
            print("Error loading artists: \(error)")
            return
        }
        
        artists = artists.sorted(by: { $0.name < $1.name })
        
        
    }
}
