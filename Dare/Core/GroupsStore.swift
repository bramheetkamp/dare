//
//  GroupsStore.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import Foundation

/// In-memory cache of groups, keyed by id — mirrors `UsersStore` / `ChallengesStore`.
/// Owns join/leave so membership state stays consistent wherever a group is shown.
final class GroupsStore: ObservableObject {

    @Published private(set) var groups: [DareGroup] = []

    private let groupService = GroupService()

    func insertOrUpdate(_ newGroups: [DareGroup]) {
        for group in newGroups {
            guard group.id != nil else { continue }
            if let index = groups.firstIndex(where: { $0.id == group.id }) {
                groups[index] = group
            } else {
                groups.append(group)
            }
        }
    }

    func group(withId id: String) -> DareGroup? {
        groups.first(where: { $0.id == id })
    }

    func join(groupId: String, completion: (() -> Void)? = nil) {
        groupService.joinGroup(groupId) { [weak self] success in
            guard success else { completion?(); return }
            self?.applyMembership(groupId: groupId, isMember: true, delta: 1)
            completion?()
        }
    }

    func leave(groupId: String, completion: (() -> Void)? = nil) {
        groupService.leaveGroup(groupId) { [weak self] success in
            guard success else { completion?(); return }
            self?.applyMembership(groupId: groupId, isMember: false, delta: -1)
            completion?()
        }
    }

    private func applyMembership(groupId: String, isMember: Bool, delta: Int) {
        guard let index = groups.firstIndex(where: { $0.id == groupId }) else { return }
        var updated = groups[index]
        updated.isMember = isMember
        updated.memberCount = max(0, (updated.memberCount ?? 0) + delta)
        groups[index] = updated
    }
}
