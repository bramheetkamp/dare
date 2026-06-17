//
//  GroupDetailViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

class GroupDetailViewModel: ObservableObject {

    @Published var group: DareGroup?
    @Published var isLoading = true
    @Published var isUpdatingMembership = false

    let groupId: String
    private let groupService = GroupService()

    init(groupId: String) {
        self.groupId = groupId
    }

    func load() {
        groupService.fetchGroup(groupId) { [weak self] fetched in
            guard let self = self else { return }
            guard var fetched = fetched else { self.isLoading = false; return }
            self.groupService.isMember(of: self.groupId) { isMember in
                fetched.isMember = isMember
                self.group = fetched
                self.isLoading = false
            }
        }
    }
}
