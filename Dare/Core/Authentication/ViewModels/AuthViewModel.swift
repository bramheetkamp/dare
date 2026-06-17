//
//  AuthViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import Combine
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

extension AuthViewModel {
    var currentUser: Dare.User? {
        if case let .authenticated(appUser) = authState {
            return appUser
        }
        return nil
    }
}

class AuthViewModel: ObservableObject {
    
    enum AuthState: Equatable {
        case loading
        case authenticated(Dare.User)
        case unauthenticated
    }
    
    @Published var authState: AuthState = .loading
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    private let service = UserService()
    private let gamificationService = GamificationService()
    
    // MARK: - Lifecycle
    
    init() {
        setupAuthListener()
    }
    
    deinit {
        print("AuthViewModel has been deinitialized")
    }
    
    // MARK: - Authentication (Login/Register)
    
    func login(withEmail email: String, password: String, onFailure: ((String) -> Void)? = nil) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                onFailure?(error.localizedDescription)
                print("DEBUG: Failed to login with error \(error.localizedDescription)")
                return
            }

            guard let self = self else { return }
            guard let uid = result?.user.uid else { return }
            self.service.fetchUser(withUid: uid) { appUser in
                DispatchQueue.main.async {
                    if let appUser {
                        self.authState = .authenticated(appUser)
                    } else {
                        self.authState = .unauthenticated
                    }
                }
            }

            print("DEBUG: User logged in successfully")
        }
    }
    
    func register(withEmail email: String, password: String, fullname: String, username: String, onFailure: ((String) -> Void)? = nil) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                onFailure?(error.localizedDescription)
                print("DEBUG: Failed to register with error \(error.localizedDescription)")
                return
            }
            
            guard let self = self else { return }
            guard let authUser = result?.user else { return }
            let userData: [String: Any] = [
                "email": email,
                "username": username.lowercased(),
                "fullname": fullname,
                "uid": authUser.uid,
                // Ensure this exists to satisfy Dare.User Decodable requirements
                "timestamp": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("users")
                .document(authUser.uid)
                .setData(userData) { _ in
                    self.service.fetchUser(withUid: authUser.uid) { appUser in
                        DispatchQueue.main.async {
                            if let appUser {
                                self.authState = .authenticated(appUser)
                            } else {
                                self.authState = .unauthenticated
                            }
                        }
                    }
                }
        }
    }
    
    /// Sends a Firebase password-reset email. Reports success/failure so the UI can confirm.
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Gamification

    /// Call once per app open: advances the daily streak/points on a new calendar day and
    /// refreshes the cached user so the UI reflects the change.
    func recordDailyActivity() {
        guard let uid = currentUser?.id else { return }
        gamificationService.recordDailyActivity(uid: uid) { [weak self] _ in
            self?.refreshCurrentUser()
        }
    }

    /// Re-fetches the signed-in user's document and republishes it.
    func refreshCurrentUser() {
        guard let uid = currentUser?.id else { return }
        service.fetchUser(withUid: uid) { [weak self] appUser in
            guard let appUser else { return }
            DispatchQueue.main.async {
                self?.authState = .authenticated(appUser)
            }
        }
    }

    // MARK: - User Management

    func uploadProfileImage(_ image: UIImage, completion: (() -> Void)? = nil) {
        guard let uid = currentUser?.id else { return }

        ImageUploader.uploadImage(image: image) { [weak self] profileImageUrl in
            Firestore.firestore().collection("users")
                .document(uid)
                .updateData(["profileImageUrl": profileImageUrl]) { _ in
                    self?.refreshCurrentUser()
                    completion?()
                }
        }
    }
    
    // MARK: - Logout
    
    private func setupAuthListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, authUser in
            guard let self else { return }
            
            if let authUser = authUser {
                service.fetchUser(withUid: authUser.uid) { appUser in
                    DispatchQueue.main.async {
                        if let appUser {
                            self.authState = .authenticated(appUser)
                        } else {
                            self.authState = .unauthenticated
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.authState = .unauthenticated
                }
            }
        }
    }
}
