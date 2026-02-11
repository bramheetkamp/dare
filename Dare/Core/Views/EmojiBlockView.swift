//
//  EmojiBlockView.swift
//  Dare
//
//  Created by Bram Heetkamp on 20/10/2025.
//

import SwiftUI

struct EmojiBlock: View {
    var emoji: String?
    var showDeleteButton: Bool = false
    var onDelete: () -> Void = {}
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                    .fill(Color.cell)
                    .frame(width: 80, height: 80)
                
                Text(emoji ?? "+")
                    .font(.system(size: 40))
                    .foregroundColor(emoji == nil ? .primaryButton : .primary)
                
                if showDeleteButton {
                    Button(action: {
                        onDelete()
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                            .background(Color.white.clipShape(Circle()))
                            .font(.system(size: 20))
                            .offset(x: 8, y: -8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
