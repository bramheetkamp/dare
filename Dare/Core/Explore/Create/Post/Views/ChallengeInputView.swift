//
//  ChallengeInputView.swift
//  Dare
//
//  Created by Bram Heetkamp on 13/06/2025.
//

import SwiftUI

struct ChallengeInputView: View {
    let placeholder: String
    @Binding var value: String
    var focus: FocusState<Field?>.Binding
    var focusField: Field

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField(placeholder, text: $value)
                .focused(focus, equals: focusField)
                .textFieldStyle(CustomTextField())
                .submitLabel(.next)
        }
        .font(.title3)
        .foregroundColor(Color("headerText"))
        .fontWeight(.black)
    }
}
