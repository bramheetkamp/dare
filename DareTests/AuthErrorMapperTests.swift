//
//  AuthErrorMapperTests.swift
//  DareTests
//
//  Pure tests for AuthErrorMapper — no Firebase import needed; NSErrors are constructed
//  directly from the integer code values documented in FIRAuthErrors.h.
//

import Testing
import Foundation
@testable import Dare

struct AuthErrorMapperTests {

    // MARK: - Helpers

    private func firebaseError(_ code: Int) -> Error {
        NSError(domain: "FIRAuthErrorDomain", code: code, userInfo: nil)
    }

    private func unknownFirebaseError() -> Error {
        NSError(domain: "FIRAuthErrorDomain", code: 99999, userInfo: nil)
    }

    private func nonFirebaseError() -> Error {
        NSError(domain: "com.apple.URLError", code: -1009, userInfo: nil)
    }

    // MARK: - Known Firebase Auth codes

    @Test func invalidEmail_returnsValidationMessage() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17008))
        #expect(msg.lowercased().contains("email"))
        #expect(msg.lowercased().contains("valid"))
    }

    @Test func wrongPassword_mentionsForgotPassword() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17009))
        #expect(msg.contains("Forgot Password"))
    }

    @Test func userNotFound_suggestsSignUp() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17011))
        #expect(msg.lowercased().contains("sign up"))
    }

    @Test func emailAlreadyInUse_suggestsSignIn() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17007))
        #expect(msg.lowercased().contains("signing in"))
    }

    @Test func weakPassword_statesMinimumLength() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17026))
        #expect(msg.contains("6 characters"))
    }

    @Test func networkError_mentionsConnection() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17020))
        let lower = msg.lowercased()
        #expect(lower.contains("internet") || lower.contains("connection"))
    }

    @Test func tooManyRequests_advisesWaiting() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17010))
        let lower = msg.lowercased()
        #expect(lower.contains("wait") || lower.contains("minutes"))
    }

    @Test func userDisabled_mentionsSupport() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17005))
        let lower = msg.lowercased()
        #expect(lower.contains("disabled") || lower.contains("support"))
    }

    @Test func requiresRecentLogin_suggestsSignOut() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17014))
        #expect(msg.lowercased().contains("sign out"))
    }

    @Test func invalidCredential_isGenericLoginError() {
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17004))
        let lower = msg.lowercased()
        #expect(lower.contains("incorrect") || lower.contains("password"))
    }

    // MARK: - Fallback behaviour

    @Test func unknownFirebaseCode_returnsGenericMessage() {
        let msg = AuthErrorMapper.friendlyMessage(for: unknownFirebaseError())
        #expect(msg.lowercased().contains("went wrong"))
    }

    @Test func nonFirebaseDomain_returnsGenericMessage() {
        let msg = AuthErrorMapper.friendlyMessage(for: nonFirebaseError())
        #expect(msg.lowercased().contains("went wrong"))
    }

    // MARK: - Domain constant

    @Test func domainConstantMatchesFIRAuthErrorDomain() {
        #expect(AuthErrorMapper.domain == "FIRAuthErrorDomain")
    }

    // MARK: - No PII leakage

    @Test func noMessageContainsRawErrorDescription() {
        let firebaseInternalMessage = "The password is invalid or the user does not have a password."
        let msg = AuthErrorMapper.friendlyMessage(for: firebaseError(17009))
        #expect(!msg.contains(firebaseInternalMessage))
    }
}
