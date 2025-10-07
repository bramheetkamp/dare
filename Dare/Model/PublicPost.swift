//
//  PublicPost.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import FirebaseFirestore

struct PublicPost: Identifiable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    let caption: String
    let challengeId: String?
    let timestamp: Timestamp
    let timestampUpdate: Timestamp
    let location: String
    let uid: String
    
    var likes: Int
    var imageUrl: String?
    var videoUrl: String?
    var mediaAspectRatio: Float?
    
    var challenge: Challenge?
    var user: User?
    var didLike: Bool? = false
}

