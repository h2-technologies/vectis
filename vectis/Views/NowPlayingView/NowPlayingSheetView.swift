//
//  NowPlayingView.swift
//  vectis
//
//  Created by Samuel Valencia on 11/2/25.
//

import SwiftUI
import MusicKit

struct NowPlayingSheetView: View {

    @State private var selectedTab: NowPlayingTab = .none

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {

                NowPlayingView().tag(NowPlayingTab.none)

                Text("Lyrics View").tag(NowPlayingTab.lyrics)

                Text("Airplay View").tag(NowPlayingTab.airplay)

                Text("Queue View").tag(NowPlayingTab.queue)
            }

            //MARK: Custom tab bar
            HStack(spacing: 90) {
                ForEach(NowPlayingTab.visibleCases, id:\.self) { tab in
                    Button {
                        withAnimation(.spring()) {
                            if selectedTab == tab {
                                selectedTab = .none
                            } else {
                                selectedTab = tab
                            }
                        }
                    }
                    label: {
                        VStack(spacing: 6) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 22, weight: .regular))
                                
                        }
                    }
                    .foregroundColor(tab == .lyrics ? HexToColor("#3B3B3B") : .gray)
                    .disabled(tab == .lyrics)
                }
            }
            .padding(.vertical, 12)
            .background(Capsule().fill(Color(.systemBackground)))
            .padding(.bottom, 10)

        }.background(Color(.gray))
    }


    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

}

enum NowPlayingTab: String, CaseIterable {
    case none
    case lyrics = "quote.bubble"
    case airplay = "airplay.audio"
    case queue = "list.bullet"

    var title: String {
        self.rawValue.capitalized
    }

    static var visibleCases: [NowPlayingTab] {
        return [.lyrics, .airplay, .queue]
    }
}


#Preview {
    NowPlayingSheetView()
}
