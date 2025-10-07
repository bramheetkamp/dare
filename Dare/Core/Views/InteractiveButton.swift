//
//  InteractiveButton.swift
//  Dare
//
//  Created by Bram Heetkamp on 11/06/2025.
//

import SwiftUI

struct InteractiveButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: Content
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    let scaleEffect: Bool

    @State private var isPressed = false

    init(
        action: @escaping () -> Void,
        backgroundColor: Color = Color("cell"),
        cornerRadius: CGFloat = Style.CornerRadius.small,
        padding: CGFloat = 10,
        scaleEffect: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.scaleEffect = scaleEffect
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .scaleEffect(scaleEffect && isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { isPressing in
            withAnimation {
                isPressed = isPressing
            }
        }, perform: {})
    }
}
