//
//  ChallengeEditorView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

struct ChallengeEditorView: View {
    let placeholder: String
    @Binding var value: String
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.cell.cornerRadius(Style.CornerRadius.small))

                if value.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $value)
                    .modifier(CustomTextEditor())
                    .focused($isFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .opacity(value.isEmpty ? 0.85 : 1)
                    .multilineTextAlignment(.leading)
            }
        }
        .font(.title3)
        .foregroundColor(Color("headerText"))
        .fontWeight(.black)
    }
}
