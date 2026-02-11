//
//  Challenge.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import FirebaseFirestore

struct Challenge: Identifiable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    let challenge: String
    let caption: String
    let timestamp: Timestamp
    let uid: String
    let categoryId: String?
    
    var updates: Int?
    var imageUrl: String?
    var emojis: [String]?
    
    var user: User?
}
