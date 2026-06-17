//
//  CreateGroupViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

class CreateGroupViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var description: String = ""
    @Published var emoji: String = ""
    @Published var isPublic: Bool = true
    @Published var isSaving = false

    private let groupService = GroupService()

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSaving
    }

    func create(completion: @escaping (DareGroup?) -> Void) {
        guard canSubmit else { completion(nil); return }
        isSaving = true
        groupService.createGroup(
            name: name,
            description: description.isEmpty ? nil : description,
            emoji: emoji.isEmpty ? nil : emoji,
            isPublic: isPublic
        ) { [weak self] group in
            DispatchQueue.main.async {
                self?.isSaving = false
                completion(group)
            }
        }
    }
}
