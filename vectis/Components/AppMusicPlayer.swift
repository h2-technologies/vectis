//
//  AppMusicPlayer.swift
//  vectis
//
//  Created by Samuel Valencia on 8/29/25.
//

import Foundation
import MusicKit

class AppMusicPlayer: ObservableObject {
    private let musicPlayer = ApplicationMusicPlayer.shared
    
    func play(song: Song) async {
        do {
            try await musicPlayer.queue.insert(song, position: .afterCurrentEntry)
            try await musicPlayer.play()
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
}
