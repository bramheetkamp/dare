//
//  PhoneNumberHasher.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import Foundation
import CryptoKit

/// Turns a raw phone number into a stable, privacy-preserving token used to match a device's
/// contacts against Dare users — we never store or send the actual number, only its hash.
///
/// Matching only works when both sides normalize identically, so normalization is deliberately
/// simple and lossy-but-consistent: strip everything except digits and a leading `+`, then apply
/// a best-effort default country code for local-format numbers.
enum PhoneNumberHasher {

    /// Default country dialing code applied to numbers that have no `+` prefix.
    /// NL (+31) matches the app's current locale; revisit when the audience broadens.
    static let defaultCountryCode = "31"

    /// Normalizes to a rough E.164 form (`+<countrycode><number>`), or returns nil if the input
    /// can't be a phone number (too few digits).
    static func normalize(_ raw: String, defaultCountryCode: String = defaultCountryCode) -> String? {
        let hasPlus = raw.contains("+")
        var digits = raw.filter { $0.isNumber }
        guard digits.count >= 6 else { return nil }

        if hasPlus {
            // Already international, e.g. "+31 6 1234 5678" → "+31612345678".
            return "+\(digits)"
        }

        // Some users save numbers as "0031..." — a leading "00" is the international prefix.
        // Check this before the trunk-zero rule below, or "00" collapses to a stray "0".
        if digits.hasPrefix("00") {
            return "+\(digits.dropFirst(2))"
        }
        // Local format. Drop a trunk "0" (common in NL/EU) and prepend the default country code.
        if digits.hasPrefix("0") {
            digits.removeFirst()
        }
        return "+\(defaultCountryCode)\(digits)"
    }

    /// SHA-256 hex digest of the normalized number, or nil if the input isn't a usable number.
    static func hash(_ raw: String, defaultCountryCode: String = defaultCountryCode) -> String? {
        guard let normalized = normalize(raw, defaultCountryCode: defaultCountryCode) else { return nil }
        let digest = SHA256.hash(data: Data(normalized.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Hashes many raw numbers, de-duplicated. Useful for the contacts sweep.
    static func hashes<S: Sequence>(_ rawNumbers: S) -> Set<String> where S.Element == String {
        Set(rawNumbers.compactMap { hash($0) })
    }
}
