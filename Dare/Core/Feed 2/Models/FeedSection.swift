//
//  FeedSection.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import Foundation

enum FeedSection {
    case closeFriends
    case forYou

    var headerTitle: String {
        switch self {
        case .closeFriends:
            return "Close friends"
        case .forYou:
            return "For you"
        }
    }
}
