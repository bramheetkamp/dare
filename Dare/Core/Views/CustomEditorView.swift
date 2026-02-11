//
//  CustomTextEditor.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2025.
//

import SwiftUI

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var value: String
    var focus: FocusState<Field?>.Binding
    var focusField: Field
    
    var body: some View {
        ZStack {
            TextEditor(text: $value)
                .foregroundStyle(Color.headerText)
                .frame(minHeight: 150)
                .focused(focus, equals: focusField)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .submitLabel(.next)
            
            if value.isEmpty {
                VStack {
                    HStack {
                        Text(placeholder)
                            .foregroundStyle(Color.headerText)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .opacity(0.3)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
}
