//
//  ChallengeCategory.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import FirebaseFirestore

struct ChallengeCategory: Identifiable, Decodable, Hashable, Equatable {
    @DocumentID var id: String?
    let title: String
    let subtitle: String
    let icon: String
    let backgroundColor: String
}
