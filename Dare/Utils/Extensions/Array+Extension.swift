//
//  Array+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
