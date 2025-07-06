//
//  LibraryButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/5/25.
//

import SwiftUI

struct LibraryCategoryButton: View {
    var buttonText: String
    var buttonImage: String
    
    init(_ buttonText: String, buttonImage: String? = nil) {
        self.buttonText = buttonText
        self.buttonImage = buttonImage ?? ""
    }
    
    var body: some View {
        VStack (alignment: .center) {
            HStack {
                Image(systemName: buttonImage)
                Text(buttonText)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.bottom, 2.5)
            
            Rectangle().frame(width: 365, height: 1)
                .padding(.bottom)
        }
    }
}


#Preview() {
    LibraryCategoryButton("Playlists", buttonImage: "music.note.list")
}
