//
//  GroupDetailView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

struct GroupDetailView: View {

    @EnvironmentObject private var groupsStore: GroupsStore
    @StateObject private var viewModel: GroupDetailViewModel

    init(groupId: String) {
        _viewModel = StateObject(wrappedValue: GroupDetailViewModel(groupId: groupId))
    }

    var body: some View {
        ScrollView {
            if let group = viewModel.group {
                VStack(spacing: 20) {
                    header(group)
                    membershipButton(group)
                    if let description = group.description, !description.isEmpty {
                        Text(description)
                            .font(Style.Typography.body)
                            .foregroundColor(Color("headerText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            } else if viewModel.isLoading {
                ProgressView().padding(.top, 40)
            } else {
                EmptyArrayMessageView(message: "This group is no longer available.")
            }
        }
        .onAppear { viewModel.load() }
        .withStandardPageStyle(title: "Group", extendView: false)
    }

    private func header(_ group: DareGroup) -> some View {
        VStack(spacing: 12) {
            Text(group.displayEmoji)
                .font(.system(size: 56))
                .frame(width: 96, height: 96)
                .background(Color("innerCell"))
                .clipShape(RoundedRectangle(cornerRadius: Style.CornerRadius.big))

            Text(group.name)
                .font(Style.Typography.screenTitle)
                .foregroundColor(Color("headerText"))

            Text(group.members == 1 ? "1 member" : "\(group.members) members")
                .font(Style.Typography.secondary)
                .foregroundColor(Color("detailText"))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func membershipButton(_ group: DareGroup) -> some View {
        let isMember = group.isMember == true
        InteractiveButton(
            action: { toggleMembership(group) },
            backgroundColor: isMember ? Color("secondaryButton") : Color("primaryButton"),
            cornerRadius: Style.CornerRadius.small,
            padding: 16,
            scaleEffect: true
        ) {
            HStack {
                Spacer()
                if viewModel.isUpdatingMembership {
                    ProgressView().tint(.white)
                } else {
                    Text(isMember ? "Leave group" : "Join group")
                        .font(Style.Typography.button)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .disabled(viewModel.isUpdatingMembership)
    }

    private func toggleMembership(_ group: DareGroup) {
        guard let id = group.id else { return }
        viewModel.isUpdatingMembership = true
        let isMember = group.isMember == true
        let finish: () -> Void = {
            viewModel.isUpdatingMembership = false
            viewModel.load()
        }
        if isMember {
            groupsStore.leave(groupId: id, completion: finish)
        } else {
            groupsStore.join(groupId: id, completion: finish)
        }
    }
}
