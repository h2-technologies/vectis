//
//  LibraryPlaylistButton.swift
//  harmony
//
//  Created by Samuel Valencia on 7/6/25.
//

import SwiftUI

struct LibraryPlaylistButton: View {
    
    var label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    var body: some View {
        HStack {
            //TODO: implement star for favorites
            Rectangle()
                .frame(width: 75, height: 75)
                .cornerRadius(5)
                .padding(.trailing, 10)
            Text(label)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.leading)
        .padding(.trailing)
        .padding(.bottom, 2.5)
        
        Rectangle().frame(width: 365, height: 1)
        
    }
}

#Preview {
    LibraryPlaylistButton("Preview 1")
}
