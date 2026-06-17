//
//  UserListView.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/06/2025.
//

import SwiftUI

struct UserListView: View {
    var users: [User]
    var onUserAppear: (User) -> Void = { _ in }
    var onUserUpdated: ((User) -> Void)?
    var onSelect: ((User) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(users, id: \.id) { user in
                UserRowView(
                    viewModel: UserRowViewModel(
                        user: user,
                        onUserUpdated: { updatedUser in
                            onUserUpdated?(updatedUser)
                        }),
                    onSelect: { onSelect?(user) }
                )
                .onAppear {
                    onUserAppear(user)
                }
            }
        }
    }
}

