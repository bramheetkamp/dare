//
//  CustomButton.swift
//  Dare
//
//  Created by Bram Heetkamp on 11/06/2025.
//

import SwiftUI

struct FloatingButton: View {
    let action: () -> Void
    let iconName: String
    let label: String
    let backgroundColor: Color
    let foregroundColor: Color

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(foregroundColor)
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(foregroundColor)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 16)
            .background(backgroundColor)
            .cornerRadius(Style.CornerRadius.small)
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
