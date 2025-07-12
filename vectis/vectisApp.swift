//
//  harmonyApp.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI
import MusicKit

@main
struct vectisApp: App {
    
    init() {
        Task.detached {
            let authorization = await MusicAuthorization.request()
            if authorization == .denied {
                //TODO: Alert user to denied
            }
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Radio", systemImage: "antenna.radiowaves.left.and.right") {
                
            }
            Tab("Library", systemImage: "play.square.stack") {
                LibraryView()
            }
            Tab("Search", systemImage: "magnifyingglass") {
                
            }
        }
    }
}

#Preview {
    MainView()
}
