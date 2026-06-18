//
//  EvictionPolicy.swift
//  Dare
//

import Foundation

/// A max-size eviction policy for in-memory stores.
///
/// When the number of cached entries exceeds `maxSize`, the oldest entries
/// (those at the front of the array, reflecting insertion order) are dropped
/// so that the store never grows beyond a predictable ceiling.
///
/// All logic is pure and free of any Firebase or SwiftUI dependency, making it
/// straightforward to unit-test in isolation.
struct EvictionPolicy {
    let maxSize: Int

    /// Returns `items` trimmed to at most `maxSize` entries, removing entries
    /// from the front (oldest-insertion order) when the limit is exceeded.
    /// Returns an empty array when `maxSize` is zero.
    func apply<T>(to items: [T]) -> [T] {
        guard maxSize > 0 else { return [] }
        guard items.count > maxSize else { return items }
        return Array(items.suffix(maxSize))
    }
}
