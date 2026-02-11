//
//  CustomSearchBar.swift
//
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct CustomSearchBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("detailText"))
            TextField("Search...", text: $text)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .focused($isFocused)
        }
        .padding(10)
        .background(Color("cell"))
        .background(Color("cell"))
        .foregroundColor(Color("headerText"))
        .cornerRadius(Style.CornerRadius.small)
    }
}

struct CustomSearchBarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                    .stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct CustomSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomSearchBar(text: .constant(""))
    }
}
