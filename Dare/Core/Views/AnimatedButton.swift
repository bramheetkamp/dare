//
//  AnimatedButton.swift
//  Dare
//
//  Created by Bram Heetkamp on 11/06/2025.
//

import SwiftUI

struct AnimatedButton: View {
    let action: () -> Void
    let label: String
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat

    @State private var isPressed = false
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Text(label)
                .fontWeight(.black)
                .foregroundColor(isEnabled ? foregroundColor : .gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? backgroundColor : Color.gray.opacity(0.3))
                .cornerRadius(cornerRadius)
                .scaleEffect(isPressed ? 0.95 : 1.0)
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
