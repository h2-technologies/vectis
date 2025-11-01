//
//  HexToColor.swift
//  vectis
//
//  Created by Samuel Valencia on 10/31/25.
//
import SwiftUI

func HexToColor (hex: String) -> Color {
    let red = hex.prefix(2)
    let green = hex.dropFirst(2).prefix(2)
    let blue = hex.dropFirst(4).prefix(2)
    
    ForEach(0..<3) { idx in }
}
