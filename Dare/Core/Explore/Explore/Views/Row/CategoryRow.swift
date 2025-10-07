//
//  CategoryRow.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

struct CategoryRow: View {
    let category: ChallengeCategory
    @State private var isPressed = false
    @EnvironmentObject private var router: AppRouter

    var validIconName: String {
        let icon = category.icon.trimmingCharacters(in: .whitespacesAndNewlines)
        if !icon.isEmpty, UIImage(systemName: icon) != nil {
            return icon
        }
        return "circle"
    }

    var body: some View {
        Button(action: {
            guard let categoryId = category.id else { return }
            router.navigate(to: .challengeCategory(categoryId: categoryId))
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: validIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .foregroundColor(.white)
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(category.subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .background(Color.valid(named: category.backgroundColor))
            .cornerRadius(Style.CornerRadius.big)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.4), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { isPressing in
                withAnimation {
                    isPressed = isPressing
                }
            },
            perform: {})
    }
}
