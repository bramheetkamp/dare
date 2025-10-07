//
//  CustomTextField.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct CustomTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color("cell"))
            .fontWeight(.bold)
            .cornerRadius(Style.CornerRadius.small)
    }
}
