//
//  GroupSearchView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

struct GroupSearchView: View {

    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = GroupSearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                CustomSearchBar(text: $viewModel.searchTerm, isFocused: _isSearchFocused)
                    .onChange(of: viewModel.searchTerm) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            viewModel.search()
                        }
                    }

                createButton

                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .onAppear { viewModel.loadMyGroups() }
        .withStandardPageStyle(title: "Groups", extendView: false)
    }

    private var createButton: some View {
        InteractiveButton(
            action: { router.navigate(to: .createGroup) },
            backgroundColor: Color("cell"),
            cornerRadius: Style.CornerRadius.small,
            padding: 12,
            scaleEffect: true
        ) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("primaryButton"))
                Text("Create a group")
                    .font(Style.Typography.bodyStrong)
                    .foregroundColor(Color("headerText"))
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.hasQuery {
            if viewModel.isLoading && viewModel.results.isEmpty {
                ProgressView().frame(maxWidth: .infinity).padding(.top, 24)
            } else if viewModel.results.isEmpty {
                EmptyArrayMessageView(message: "No groups found. Why not create one?")
            } else {
                groupList(viewModel.results)
            }
        } else if !viewModel.myGroups.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeaderLabelView(text: "Your groups")
                groupList(viewModel.myGroups)
            }
        } else {
            EmptyArrayMessageView(message: "Search for a group or create your own.")
        }
    }

    private func groupList(_ groups: [DareGroup]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(groups) { group in
                GroupRowView(group: group)
            }
        }
    }
}
