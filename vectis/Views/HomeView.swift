//
//  HomeView.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI
import MusicKit

struct HomeView: View {
    @State var items: [RecentlyPlayedMusicItem] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Home")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 15)
                    
                    if isLoading {
                        ProgressView().padding()
                    } else {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                                    switch item {
                                    case .album(let album):
                                        VStack(alignment: .leading) {
                                            ArtworkImage(album.artwork!, width: 125, height: 125).cornerRadius(10)
                                                
                                            Text(album.title)
                                            Text(album.artistName).font(.caption) //TODO: Set to gray
                                        }
                                       
                                    case .playlist(let playlist):
                                        Text(playlist.name)
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 15)
            }
        }.task {
            if items.isEmpty {
                await loadRecent()
            }
        }
    }
    
    @MainActor
    func loadRecent() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let recentFetch = MusicRecentlyPlayedRequest<RecentlyPlayedMusicItem>().response()
            let recentResponse = try await recentFetch
            
            print("Recent Items: \(recentResponse.items)")
            items = Array(recentResponse.items)
            
        } catch {
            print("Failed to load recent playlists: \(error)")
        }
    }
}

#Preview {
    HomeView()
}
