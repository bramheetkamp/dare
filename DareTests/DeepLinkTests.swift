//
//  DeepLinkTests.swift
//  DareTests
//
//  Pure parsing tests for AppDestination.from(url:) — no Firebase required.
//

import Testing
import Foundation
@testable import Dare

struct DeepLinkTests {

    @Test func parsesChallengeWithId() throws {
        let url = try #require(URL(string: "dare://challenge?id=abc123"))
        #expect(AppDestination.from(url: url) == .challengeDetail(challengeId: "abc123"))
    }

    @Test func parsesPostWithId() throws {
        let url = try #require(URL(string: "dare://post?id=p1"))
        #expect(AppDestination.from(url: url) == .postDetail(postId: "p1"))
    }

    @Test func parsesProfileWithId() throws {
        let url = try #require(URL(string: "dare://profile?id=user_9"))
        #expect(AppDestination.from(url: url) == .profile(userId: "user_9"))
    }

    @Test func parsesTabRouteWithoutId() throws {
        let url = try #require(URL(string: "dare://home"))
        #expect(AppDestination.from(url: url) == .home)
    }

    @Test func parsesCreateChallenge() throws {
        let url = try #require(URL(string: "dare://createChallenge"))
        #expect(AppDestination.from(url: url) == .createChallenge)
    }

    @Test func missingIdReturnsNil() throws {
        let url = try #require(URL(string: "dare://challenge"))
        #expect(AppDestination.from(url: url) == nil)
    }

    @Test func unknownSchemeReturnsNil() throws {
        let url = try #require(URL(string: "ftp://challenge?id=1"))
        #expect(AppDestination.from(url: url) == nil)
    }

    @Test func unknownRouteReturnsNil() throws {
        let url = try #require(URL(string: "dare://nonsense?id=1"))
        #expect(AppDestination.from(url: url) == nil)
    }

    @Test func acceptsPathStyleRoute() throws {
        let url = try #require(URL(string: "dare://open/post?id=z9"))
        #expect(AppDestination.from(url: url) == .postDetail(postId: "z9"))
    }

    @Test func parsesGroupWithId() throws {
        let url = try #require(URL(string: "dare://group?id=g42"))
        #expect(AppDestination.from(url: url) == .groupDetail(groupId: "g42"))
    }

    @Test func parsesSearchGroups() throws {
        let url = try #require(URL(string: "dare://searchGroups"))
        #expect(AppDestination.from(url: url) == .searchGroups)
    }

    @Test func parsesContactsFriends() throws {
        let url = try #require(URL(string: "dare://contactsFriends"))
        #expect(AppDestination.from(url: url) == .contactsFriends)
    }
}
