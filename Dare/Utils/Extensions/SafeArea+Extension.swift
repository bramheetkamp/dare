//
//  SafeArea+Extension.swift
//  Dare
//
//  Single source of truth for the safe-area insets used by the app's sticky
//  footers/headers. Replaces ~11 duplicated `safeArea*Padding()` helpers that each
//  reached for the deprecated `UIApplication.shared.windows`.
//

import SwiftUI

extension UIWindow {
    /// The active key window via the non-deprecated scene API.
    static var activeKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

extension View {
    func safeAreaBottomPadding() -> CGFloat {
        UIWindow.activeKeyWindow?.safeAreaInsets.bottom ?? 0
    }

    func safeAreaTopPadding() -> CGFloat {
        UIWindow.activeKeyWindow?.safeAreaInsets.top ?? 0
    }
}
