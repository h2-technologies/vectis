//
//  HexToColor.swift
//  vectis
//
//  Created by Samuel Valencia on 10/31/25.
//

import SwiftUI

func HexToColor (_ hex: String) -> Color {
    
    var hex = hex
    
    hex.replace("#", with: "")
    
    var colors: [String] = []
    var colorInts: [Int] = []
    
    colors.append(String(hex.prefix(2)))
    colors.append(String(hex.dropFirst(2).prefix(2)))
    colors.append(String(hex.dropFirst(4).prefix(2)))
    
    for i in 0...2 {
        let first = String(colors[i].prefix(1)).lowercased()
        var firstInt = 0
        let second = String(colors[i].dropFirst(1)).lowercased()
        var secondInt = 0
        
        if (first.contains(where: { ["a", "b", "c", "d", "e", "f"].contains($0) })) {
            switch first {
            case "a": firstInt = 10
            case "b": firstInt = 11
            case "c": firstInt = 12
            case "d": firstInt = 13
            case "e": firstInt = 14
            case "f": firstInt = 15
            default: break
            }
        } else {
            firstInt = Int(first)!
        }
        
        firstInt *= 16
        
        if (second.contains(where: { ["a", "b", "c", "d", "e", "f"].contains($0) })) {
            switch second {
            case "a": secondInt = 10
            case "b": secondInt = 11
            case "c": secondInt = 12
            case "d": secondInt = 13
            case "e": secondInt = 14
            case "f": secondInt = 15
            default: break
            }
        } else {
            secondInt = Int(second)!
        }
        
        colorInts.append(firstInt + secondInt)
    }
    
    return Color(red: Double(colorInts[0]) / 255.0, green: Double(colorInts[1]) / 255.0, blue: Double(colorInts[2]) / 255.0)
}
