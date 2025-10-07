//
//  UserRowViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/06/2025.
//

import Foundation

class UserRowViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var user: User
    
    var onUserUpdated: ((User) -> Void)?

    // MARK: - Lifecycle
    
    init(user: User, onUserUpdated: ((User) -> Void)? = nil) {
        self.user = user
        self.onUserUpdated = onUserUpdated
    }
    
    deinit {
        print("UserRowViewModel has been deintialized")
    }
    
    // MARK: - Methods
    
}

