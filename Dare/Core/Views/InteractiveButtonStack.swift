//
//  InteractiveButtonStack.swift
//  Dare
//
//  Created by Bram Heetkamp on 11/06/2025.
//

import SwiftUI

struct InteractiveButtonStack<Content: View>: View {
    let action: () -> Void
    let content: Content
    let cornerRadius: CGFloat
    let backgroundColor: Color?
    
    @State private var isPressed = false
    
    init(action: @escaping () -> Void, cornerRadius: CGFloat = 8, backgroundColor: Color? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                if let backgroundColor = backgroundColor {
                    content
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isPressed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(backgroundColor)
                        )
                } else {
                    content
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isPressed)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { isPressing in
            withAnimation {
                isPressed = isPressing
            }
        }, perform: {})
    }
}
