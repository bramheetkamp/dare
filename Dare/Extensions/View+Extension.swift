//
//  UIView+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 30/10/2024.
//

import SwiftUI

extension View {
    func customBackButton() -> some View {
        self.modifier(CustomBackButtonModifier())
    }
}
