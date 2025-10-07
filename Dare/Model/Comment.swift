//
//  Comment.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/11/2024.
//

import FirebaseFirestore

struct Comment: Identifiable, Decodable {
    @DocumentID var id: String?
    var uid: String
    var text: String
    var timestamp: Timestamp
    
    var user: User?
    
    var createdAt: Date {
        return timestamp.dateValue()
    }
}
