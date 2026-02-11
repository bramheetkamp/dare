//
//  CreateChallengeViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

class CreateChallengeViewModel: ObservableObject {
    
    let service = ChallengeService()
    
    func createChallenge(title: String, description: String, emojis: [String], completion: @escaping (Challenge?) -> Void) {
        service.postChallenge(challenge: title, caption: description, emojis: emojis) { challenge in
            completion(challenge)
        }
    }

}
