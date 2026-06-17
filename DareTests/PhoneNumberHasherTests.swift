//
//  PhoneNumberHasherTests.swift
//  DareTests
//
//  Pure normalization/hashing tests — no Firebase required.
//

import Testing
import Foundation
@testable import Dare

struct PhoneNumberHasherTests {

    // MARK: - Normalization

    @Test func keepsInternationalNumberAndStripsFormatting() {
        #expect(PhoneNumberHasher.normalize("+31 6 1234 5678") == "+31612345678")
    }

    @Test func addsDefaultCountryCodeAndDropsTrunkZero() {
        // Local NL format "06..." → +31 6...
        #expect(PhoneNumberHasher.normalize("06 12345678", defaultCountryCode: "31") == "+31612345678")
    }

    @Test func treatsDoubleZeroAsInternationalPrefix() {
        #expect(PhoneNumberHasher.normalize("0031612345678") == "+31612345678")
    }

    @Test func rejectsTooShortInput() {
        #expect(PhoneNumberHasher.normalize("123") == nil)
        #expect(PhoneNumberHasher.hash("123") == nil)
    }

    // MARK: - Hashing

    @Test func sameNumberDifferentFormatsHashEqual() {
        let a = PhoneNumberHasher.hash("+31 6 1234 5678")
        let b = PhoneNumberHasher.hash("06-12345678", defaultCountryCode: "31")
        #expect(a != nil)
        #expect(a == b)
    }

    @Test func differentNumbersHashDifferently() {
        #expect(PhoneNumberHasher.hash("+31612345678") != PhoneNumberHasher.hash("+31698765432"))
    }

    @Test func hashIsHexSha256Length() throws {
        let hash = try #require(PhoneNumberHasher.hash("+31612345678"))
        #expect(hash.count == 64)
        #expect(hash.allSatisfy { $0.isHexDigit })
    }

    @Test func hashesDeduplicates() {
        let result = PhoneNumberHasher.hashes(["+31612345678", "06 12345678", "123"])
        // First two normalize to the same number; the short one is dropped.
        #expect(result.count == 1)
    }
}
