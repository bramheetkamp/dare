//
//  ContactsService.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import Contacts

/// Reads the device address book so we can match contacts to Dare users.
/// Only phone numbers are read, and they're hashed (see `PhoneNumberHasher`) before leaving the
/// device — raw numbers are never uploaded.
struct ContactsService {

    var authorizationStatus: CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    func requestAccess(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { granted, error in
            if let error = error { print("DEBUG: contacts access error: \(error.localizedDescription)") }
            DispatchQueue.main.async { completion(granted) }
        }
    }

    /// Enumerates all contacts and returns their phone numbers as raw strings (de-duplicated).
    func fetchPhoneNumbers(completion: @escaping ([String]) -> Void) {
        let store = CNContactStore()
        DispatchQueue.global(qos: .userInitiated).async {
            var numbers = Set<String>()
            let keys = [CNContactPhoneNumbersKey as CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    for phone in contact.phoneNumbers {
                        numbers.insert(phone.value.stringValue)
                    }
                }
            } catch {
                print("DEBUG: contacts enumeration failed: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { completion(Array(numbers)) }
        }
    }
}
