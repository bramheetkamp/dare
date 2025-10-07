//
//  CustomTextEditor.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct CustomTextEditor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color("headerText"))
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .cornerRadius(Style.CornerRadius.small)
            .frame(minHeight: 150)
    }
}
