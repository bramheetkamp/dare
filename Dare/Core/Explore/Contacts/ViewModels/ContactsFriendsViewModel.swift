//
//  ContactsFriendsViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI
import Contacts
import FirebaseAuth

class ContactsFriendsViewModel: ObservableObject {

    enum Phase: Equatable {
        case intro          // ask the user to start
        case loading        // requesting access / matching
        case denied         // access refused → point to Settings
        case loaded         // finished; `matches` holds the result
    }

    @Published var phase: Phase = .intro
    @Published var matches: [User] = []

    private let contactsService = ContactsService()
    private let userService = UserService()

    func start() {
        phase = .loading

        if contactsService.authorizationStatus == .denied || contactsService.authorizationStatus == .restricted {
            phase = .denied
            return
        }

        contactsService.requestAccess { [weak self] granted in
            guard let self = self else { return }
            guard granted else { self.phase = .denied; return }
            self.matchContacts()
        }
    }

    private func matchContacts() {
        contactsService.fetchPhoneNumbers { [weak self] rawNumbers in
            guard let self = self else { return }
            let hashes = Array(PhoneNumberHasher.hashes(rawNumbers))
            guard !hashes.isEmpty else {
                self.matches = []
                self.phase = .loaded
                return
            }
            self.userService.findUsers(byPhoneHashes: hashes) { users in
                let currentUid = Auth.auth().currentUser?.uid
                self.matches = users.filter { $0.id != currentUid }
                self.phase = .loaded
            }
        }
    }
}
