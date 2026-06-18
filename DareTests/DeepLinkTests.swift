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

    // MARK: - shareURL round-trips

    @Test func shareURLPostRoundTrips() throws {
        let url = try #require(AppDestination.postDetail(postId: "p1").shareURL)
        #expect(AppDestination.from(url: url) == .postDetail(postId: "p1"))
    }

    @Test func shareURLChallengeRoundTrips() throws {
        let url = try #require(AppDestination.challengeDetail(challengeId: "c99").shareURL)
        #expect(AppDestination.from(url: url) == .challengeDetail(challengeId: "c99"))
    }

    @Test func shareURLProfileRoundTrips() throws {
        let url = try #require(AppDestination.profile(userId: "u42").shareURL)
        #expect(AppDestination.from(url: url) == .profile(userId: "u42"))
    }

    @Test func shareURLGroupRoundTrips() throws {
        let url = try #require(AppDestination.groupDetail(groupId: "g7").shareURL)
        #expect(AppDestination.from(url: url) == .groupDetail(groupId: "g7"))
    }

    @Test func shareURLLocketPostResolvesToPostDestination() throws {
        let url = try #require(AppDestination.locketPost(postId: "lp5").shareURL)
        // locketPost shares via the post route, so it round-trips to postDetail
        #expect(AppDestination.from(url: url) == .postDetail(postId: "lp5"))
    }

    @Test func shareURLHomeIsNil() {
        #expect(AppDestination.home.shareURL == nil)
    }

    @Test func shareURLExploreIsNil() {
        #expect(AppDestination.explore.shareURL == nil)
    }

    @Test func shareURLCreateChallengeIsNil() {
        #expect(AppDestination.createChallenge.shareURL == nil)
    }
}
