//
//  HomeView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/2/25.
//

import MusicKit
import SwiftUI

struct HomeView: View {
  @State var recentlyPlayedItems: [RecentlyPlayedMusicItem] = []
  @State private var isLoading: Bool = false

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
            VStack(alignment: .leading) {
              Text("Recently Played")
                .font(.headline)
                .padding(.bottom, 5)

              ScrollView(.horizontal) {
                HStack {
                  ForEach(Array(recentlyPlayedItems.enumerated()), id: \.element.id) { index, item in
                    switch item {
                    case .album(let album):
											NavigationLink(destination: AlbumView(album)) {
												VStack(alignment: .leading) {
													ArtworkImage(album.artwork!, width: 170, height: 170).cornerRadius(10)

													if album.title.count > 20 {
														Text(album.title.prefix(20) + "...")
															.font(.subheadline)
															.lineLimit(1)
															.foregroundStyle(.white)
													} else {
														Text(album.title)
															.font(.subheadline)
															.lineLimit(1)
															.foregroundStyle(.white)
													}

													Text(album.artistName)
														.font(.caption)
														.foregroundStyle(.gray)
												}
											}
                    case .playlist(let playlist):
											NavigationLink(destination: PlaylistView(playlist)) {
												VStack(alignment: .leading) {
													if playlist.artwork != nil {
														ArtworkImage(playlist.artwork!, width: 170, height: 170).cornerRadius(10)
													}
													
													Text(playlist.name)
														.font(.subheadline)
														.lineLimit(1)
														.foregroundStyle(.white)
													
													Text(playlist.curatorName ?? "")
														.font(.caption)
														.foregroundStyle(.gray)
													
												}
											}
                    default:
                      EmptyView()
                    }
                  }
                }.padding(.bottom, 20)
              }
            }
						
						VStack(alignment: .leading) {
							Text("Recently Added")
								.font(.headline)
								.padding(.bottom, 5)
							
							ScrollView(.horizontal) {
								HStack {
									
								}
							}
						}
          }
        }
        .padding(.leading, 15)
      }
    }.task {
      if recentlyPlayedItems.isEmpty {
        await loadRecentlyPlayed()
      }
    }
  }

  @MainActor
  func loadRecentlyPlayed() async {
    isLoading = true
    defer { isLoading = false }

    do {
      async let recentFetch = MusicRecentlyPlayedRequest<RecentlyPlayedMusicItem>().response()
      let recentResponse = try await recentFetch

      recentlyPlayedItems = Array(recentResponse.items)

    } catch {
      print("Failed to load recent playlists: \(error)")
    }
		
		
  }
	
}

#Preview {
  HomeView()
}
