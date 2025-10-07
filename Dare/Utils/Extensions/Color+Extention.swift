//
//  ColorExtention.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

extension Color {
    static func valid(named name: String?) -> Color {
        let trimmed = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .black }
        
        #if os(iOS) || os(tvOS) || os(watchOS)
        if let uiColor = UIColor(named: trimmed) {
            return Color(uiColor)
        }
        #endif
        
        if let sysColor = initOptional(name: trimmed) {
            return sysColor
        }
        
        return .black
    }
    
    fileprivate static func initOptional(name: String) -> Color? {
        switch name.lowercased() {
        case "black": return .black
        case "white": return .white
        case "gray": return .gray
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "primary": return .primary
        case "secondary": return .secondary
        default: return nil
        }
    }
}
