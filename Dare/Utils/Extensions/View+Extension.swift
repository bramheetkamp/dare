//
//  View+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 30/10/2024.
//

import SwiftUI

extension View {
    func withCustomNavigationBar() -> some View {
        self.modifier(NavigationBarModifier())
    }
}
