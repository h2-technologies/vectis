//
//  View.swift
//  vectis
//
//  Created by Samuel Valencia on 10/31/25.
//

import SwiftUI

struct CornerRadiusViewModifier: ViewModifier {
    let radius: Double
    
    func body(content: Content) -> some View {
        content.clipShape(.rect(cornerRadius: radius))
    }
}

extension View {
    func cornerRadius(_ radius: Double) -> some View {
        modifier(CornerRadiusViewModifier(radius: radius))
    }
}
