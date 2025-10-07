//
//  View+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 30/10/2024.
//

import SwiftUI

extension View {
    
    /// Attach a custom navigation bar with title and optional back button.
    /// - Parameters:
    ///   - title: The title for the navigation bar (centered). Default is nil.
    ///   - showBackButton: Whether to show a back button. Default is true.
    func withCustomNavigationBar(title: String? = nil, showBackButton: Bool = true) -> some View {
        self.modifier(CustomNavigationBarModifier(title: title, showBackButton: showBackButton))
    }
    
    @ViewBuilder
    func ignoresSafeAreaTop(if condition: Bool) -> some View {
        if condition {
            self.ignoresSafeArea(edges: .top)
        } else {
            self
        }
    }
    
    func withStandardPageStyle(
        title: String? = nil,
        showBackButton: Bool = true,
        horizontalPadding: CGFloat = 0,
        backgroundColor: Color = Color("background"),
        extendView: Bool = true
    ) -> some View {
        self
            .withCustomNavigationBar(title: title, showBackButton: showBackButton)
            .navigationBarBackButtonHidden()
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(backgroundColor)
            .padding(.horizontal, horizontalPadding)
            .ignoresSafeAreaTop(if: extendView)
    }

    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
}
