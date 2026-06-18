//
//  QuickPostViewTests.swift
//  DareTests
//
//  Tests for the pure QuickPostValidator predicate — no Firebase, no SwiftUI.
//

import Testing
@testable import Dare

struct QuickPostViewTests {

    // MARK: - canPost

    @Test func canPost_requiresBothNoteAndImage() {
        #expect(!QuickPostValidator.canPost(note: "", hasImage: false))
        #expect(!QuickPostValidator.canPost(note: "morning bake 🥐", hasImage: false))
        #expect(!QuickPostValidator.canPost(note: "", hasImage: true))
    }

    @Test func canPost_trueWhenNoteAndImage() {
        #expect(QuickPostValidator.canPost(note: "first clean pull-up", hasImage: true))
    }

    @Test func canPost_whitespaceOnlyNoteIsRejected() {
        #expect(!QuickPostValidator.canPost(note: "   ", hasImage: true))
        #expect(!QuickPostValidator.canPost(note: "\t\n", hasImage: true))
    }

    @Test func canPost_noteTrimmedBeforeCheck() {
        #expect(QuickPostValidator.canPost(note: "  solid session  ", hasImage: true))
    }
}
