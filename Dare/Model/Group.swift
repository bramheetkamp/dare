//
//  Group.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import FirebaseFirestore

/// A small group people can join to chase a shared goal together (see the product vision:
/// "Goals can be collective — friends or a local small group supporting each other").
///
/// Named `DareGroup` to avoid clashing with SwiftUI's `Group` view.
struct DareGroup: Identifiable, Decodable, Equatable, Hashable {
    @DocumentID var id: String?
    let name: String
    /// Lowercased name for case-insensitive prefix search.
    let nameLower: String
    let timestamp: Timestamp
    let createdBy: String

    var description: String?
    var emoji: String?
    var isPublic: Bool?
    var memberCount: Int?

    // MARK: Client-side state (not persisted on the group document)
    var isMember: Bool?
}

extension DareGroup {
    var displayEmoji: String { emoji ?? "👥" }
    var members: Int { memberCount ?? 0 }
    var publiclyVisible: Bool { isPublic ?? true }
}
