//
//  KeyboardResponder.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/11/2024.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    @Published var keyboardHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { notification in
                self.isKeyboardVisible = true
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                self.isKeyboardVisible = false
                self.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}
