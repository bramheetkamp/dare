//
//  AuthErrorMapper.swift
//  Dare
//
//  Pure, Firebase-free translation from NSError codes to user-friendly copy.
//  Firebase Auth errors arrive as NSErrors in domain "FIRAuthErrorDomain" with
//  well-defined integer codes — we match on those without importing FirebaseAuth,
//  so this file is 100 % unit-testable without FirebaseApp.configure().
//

import Foundation

enum AuthErrorMapper {

    // MARK: - Firebase Auth error domain

    /// The NSError domain used by Firebase Auth. Checked before interpreting the code.
    static let domain = "FIRAuthErrorDomain"

    // MARK: - Known error codes

    /// Raw Firebase Auth NSError code values (from FirebaseAuth/Sources/Public/FirebaseAuth/FIRAuthErrors.h).
    /// Using raw integers instead of `AuthErrorCode` keeps this file Firebase-SDK-free.
    private enum Code: Int {
        case invalidCredential   = 17004
        case userDisabled        = 17005
        case emailAlreadyInUse   = 17007
        case invalidEmail        = 17008
        case wrongPassword       = 17009
        case tooManyRequests     = 17010
        case userNotFound        = 17011
        case requiresRecentLogin = 17014
        case networkError        = 17020
        case weakPassword        = 17026
    }

    // MARK: - Public interface

    /// Returns a short, user-friendly message for any auth `Error`.
    ///
    /// Known Firebase Auth codes are mapped to plain-English copy that helps the user
    /// recover (e.g. "tap Forgot Password", "sign up instead"). Any other error —
    /// whether an unmapped Firebase code or a completely different error type — gets
    /// a generic fallback so no internal error copy ever leaks to the UI.
    static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == domain,
              let code = Code(rawValue: nsError.code) else {
            return "Something went wrong. Please try again."
        }
        switch code {
        case .invalidEmail:
            return "That doesn't look like a valid email address."
        case .wrongPassword:
            return "Wrong password. Try again or tap Forgot Password."
        case .userNotFound:
            return "No account found for that email. Check the spelling or sign up."
        case .emailAlreadyInUse:
            return "That email is already registered. Try signing in instead."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .networkError:
            return "No internet connection. Check your connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please wait a few minutes and try again."
        case .userDisabled:
            return "This account has been disabled. Contact support if this is a mistake."
        case .requiresRecentLogin:
            return "Please sign out and sign back in to continue."
        case .invalidCredential:
            return "Incorrect email or password. Please try again."
        }
    }
}
