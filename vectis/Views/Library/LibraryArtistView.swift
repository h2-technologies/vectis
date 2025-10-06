//
//  LibraryArtistView.swift
//  vectis
//
//  Created by Samuel Valencia on 10/5/25.
//
import SwiftUI
import MusicKit

struct LibraryArtistView: View {
    
    @State var artists: [Artist] = []
    
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
        ScrollView {
            VStack(alignment: .leading) {
                Text("Artists")
                    .font(.title)
                    .fontWeight(.bold)
                ForEach(groupedArists, id: \.key) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.key)
                            .font(.headline)
                            .padding(.top, 12)
                        
                        ForEach(section.value, id: \.id) { artist in
                            NavigationLink(destination: ArtistView(artist)) {
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
                            
                            if section.value.last != artist {
                                Rectangle().frame(width: 365, height: 1).foregroundStyle(Color.gray)
                            }
                        }
                    }
                }
            }
            
        }
        .onAppear() {
            Task {
                await loadArtists()
            }
        }
        .padding(.leading, 15)
    }
    
    @MainActor
    func loadArtists() async {
        do {
            let request = MusicLibraryRequest<Artist>()
            let response = try await request.response()
            artists = response.items.compactMap { $0 as Artist }
            
        } catch {
            print("Error loading artists: \(error)")
            return
        }
        
        artists = artists.sorted(by: { $0.name < $1.name })
        
        
    }
}

