//
//  GroupSearchViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

class GroupSearchViewModel: ObservableObject {

    @Published var searchTerm: String = ""
    @Published var results: [DareGroup] = []
    @Published var myGroups: [DareGroup] = []
    @Published var isLoading = false

    private let groupService = GroupService()

    var hasQuery: Bool {
        !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadMyGroups() {
        groupService.fetchMyGroups { [weak self] groups in
            self?.myGroups = groups
        }
    }

    func search() {
        let term = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            results = []
            isLoading = false
            return
        }
        isLoading = true
        groupService.searchGroups(matching: term) { [weak self] groups in
            guard let self = self else { return }
            // Drop stale responses if the term changed mid-flight.
            guard self.searchTerm.trimmingCharacters(in: .whitespacesAndNewlines) == term else { return }
            // Flag membership using the groups we already know the user belongs to.
            let myIds = Set(self.myGroups.compactMap { $0.id })
            self.results = groups.map { group in
                var g = group
                if let id = g.id, myIds.contains(id) { g.isMember = true }
                return g
            }
            self.isLoading = false
        }
    }
}
