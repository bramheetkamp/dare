//
//  DateExtensionTests.swift
//  DareTests
//
//  Pure tests for Date.timeAgoSinceDate().
//

import Testing
import Foundation
@testable import Dare

struct DateExtensionTests {

    @Test func justNowForCurrentTime() {
        #expect(Date().timeAgoSinceDate() == "Just now")
    }

    @Test func minutesAgo() {
        let date = Date().addingTimeInterval(-5 * 60)
        #expect(date.timeAgoSinceDate() == "5 minutes ago")
    }

    @Test func oneHourAgoIsSingular() {
        let date = Date().addingTimeInterval(-60 * 60)
        #expect(date.timeAgoSinceDate() == "1 hour ago")
    }

    @Test func daysAgo() {
        let date = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        #expect(date.timeAgoSinceDate() == "3 days ago")
    }

    @Test func oneYearAgoIsSingular() {
        let date = Date().addingTimeInterval(-366 * 24 * 60 * 60)
        #expect(date.timeAgoSinceDate() == "1 year ago")
    }
}
