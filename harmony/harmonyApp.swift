//
//  harmonyApp.swift
//  harmony
//
//  Created by Samuel Valencia on 7/2/25.
//

import SwiftUI

@main
struct harmonyApp: App {
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
                
            }
            Tab("Search", systemImage: "magnifyingglass") {
                
            }
        }
    }
}

#Preview {
    MainView()
}
