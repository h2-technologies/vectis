//
//  HomeView.swift
//  vectis
//
//  Created by Samuel Valencia on 7/2/25.
//

import MusicKit
import SwiftUI

struct HomeView: View {
	@State var data: MusicItemCollection<MusicPersonalRecommendation> = []
	@State private var isLoading: Bool = false
	
	@EnvironmentObject private var appMusicPlayer: AppMusicPlayer
	@EnvironmentObject private var libraryManager: LibraryManager
	
	// Top picks (personal recommendations) - store simple titles to avoid tight coupling
	@State private var topPickTitles: [String] = []
	@State private var isLoadingTopPicks: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					Text("Home")
						.font(.title)
						.fontWeight(.bold)
						.padding(.bottom, 15)
					
					if (isLoading) {
						ProgressView().padding()
					} else {
						ForEach(Array(data.enumerated()), id: \.element.id) { index, recommendation in
							Text(recommendation.title ?? "")
								.font(.headline)
								.padding(.bottom, 5)
							
							ScrollView(.horizontal) {
								HStack {
									ForEach(Array(recommendation.items.enumerated()), id: \.element.id) { index, item in
										HomeCard(item)
										
									}
								}
							}
						}
					}
				}
				.padding(.leading, 15)
			}
		}
		.task {
			// Load recently played and top picks once on appear (if not already loaded)
			if data.isEmpty {
				await loadData()
			}
		}
	}
	
	@MainActor
	func loadData() async {
		isLoading = true
		defer { isLoading = false }
		
		do {
			let response = try await MusicPersonalRecommendationsRequest().response()
			
			data = response.recommendations
			
		} catch {
			print("Failed to load data: \(error)")
		}
	}
	
}

struct HomeCard: View {
	@EnvironmentObject private var appMusicPlayer: AppMusicPlayer
	@State var item: MusicItemCollection<MusicPersonalRecommendation.Item>.Element
	
	init(_ item: MusicItemCollection<MusicPersonalRecommendation.Item>.Element) {
		self.item = item
	}
	
	var body: some View {
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
			
		case .station(let station):
			VStack(alignment: .leading) {
				ArtworkImage(station.artwork!, width: 170, height: 170).cornerRadius(10)
				
				if station.name.count > 20 {
					Text(station.name.prefix(20) + "...")
						.font(.subheadline)
						.lineLimit(1)
						.foregroundStyle(.white)
				} else {
					Text(station.name)
						.font(.subheadline)
						.lineLimit(1)
						.foregroundStyle(.white)
				}
				Text("Radio Station")
					.font(.caption)
					.foregroundStyle(.gray)
			}.onTapGesture {
				Task {
					appMusicPlayer.enqueueStation(station)
					await appMusicPlayer.play()
				}
				
				
			}
			
		default:
			EmptyView()
		}
	}
}

#Preview {
	HomeView()
}
