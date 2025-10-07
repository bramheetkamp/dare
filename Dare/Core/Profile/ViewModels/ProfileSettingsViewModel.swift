//
//  ProfileSettingsViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 06/07/2025.
//

import FirebaseAuth

class ProfileSettingsViewModel: ObservableObject {
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
}
