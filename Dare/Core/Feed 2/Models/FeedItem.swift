//
//  FeedItem.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct FeedItem: Identifiable {
    let id = UUID()
    let section: FeedSection
    let title: String
    let subtitle: String
    let background: Color
}
