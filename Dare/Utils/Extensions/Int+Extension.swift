//
//  Int+Extension.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/02/2026.
//

import Foundation

extension Int {

    // Formats large numbers like:
    // 999 -> "999"
    // 1000 -> "1k"
    // 1200 -> "1.2k"
    // 123000 -> "123k"
    // 1200000 -> "1.2m"
    // 1000000 -> "1m"
    func toAbbreviatedCount() -> String {
        let absNumber = abs(Double(self))
        let sign = self < 0 ? "-" : ""

        switch absNumber {
        case 0..<1000:
            return "\(self)"

        case 1000..<1_000_000:
            return sign + formatAbbreviation(absNumber / 1000, suffix: "k")

        case 1_000_000..<1_000_000_000:
            return sign + formatAbbreviation(absNumber / 1_000_000, suffix: "m")

        default:
            return sign + formatAbbreviation(absNumber / 1_000_000_000, suffix: "b")
        }
    }

    private func formatAbbreviation(_ value: Double, suffix: String) -> String {
        // If it's basically an integer (e.g. 123.0), show no decimals
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))\(suffix)"
        }

        // Otherwise show 1 decimal (e.g. 1.2k)
        let formatted = String(format: "%.1f", value)

        // Remove trailing .0 just in case
        let cleaned = formatted.replacingOccurrences(of: ".0", with: "")
        return "\(cleaned)\(suffix)"
    }
}
