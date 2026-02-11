//
//  ChallengeInputView.swift
//  Dare
//
//  Created by Bram Heetkamp on 13/06/2025.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    var limit: Int?
    @Binding var value: String
    var focus: FocusState<Field?>.Binding?
    var focusField: Field?
    
    var body: some View {
        HStack {
            TextField(placeholder, text: limitText($value, to: limit))
                .padding(12)
                .background(Color("cell"))
                .cornerRadius(Style.CornerRadius.small)
                .submitLabel(.next)
                .ifLet(focus, focusField) { view, focus, field in
                    view.focused(focus, equals: field)
                }
                .foregroundColor(Color("headerText"))
            
            if let limit = limit {
                Text("\(value.count)/\(limit)")
                    .font(.footnote.monospacedDigit())
                    .foregroundColor(value.count >= limit ? .red : .secondary)
                    .frame(width: textWidth(for: limit), alignment: .trailing)
                    .padding(.leading, 8)
            }
        }
    }
    
    private func limitText(_ text: Binding<String>, to limit: Int?) -> Binding<String> {
        Binding(
            get: {
                text.wrappedValue
            },
            set: { newValue in
                if let limit = limit {
                    if newValue.count > limit {
                        text.wrappedValue = String(newValue.prefix(limit))
                    } else {
                        text.wrappedValue = newValue
                    }
                } else {
                    text.wrappedValue = newValue
                }
            }
        )
    }
    
    private func textWidth(for limit: Int) -> CGFloat {
        let digits = String(limit).count
        return CGFloat(22 + (digits * 10))
    }
}
