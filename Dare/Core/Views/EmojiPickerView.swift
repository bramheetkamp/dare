//
//  EmojiPickerView.swift
//  Dare
//
//  Created by Bram Heetkamp on 20/10/2025.
//

import SwiftUI

struct EmojiPickerView: View {
    let emojis: [String]
    let selectedIndex: Int
    let onSelect: (String) -> Void
    let onCancel: () -> Void
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: {
                                onSelect(emoji)
                            }) {
                                Text(emoji)
                                    .font(.system(size: 40))
                                    .frame(width: geometry.size.width / 6, height: geometry.size.width / 6)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select an emoji")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

