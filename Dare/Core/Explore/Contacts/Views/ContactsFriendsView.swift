//
//  ContactsFriendsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

struct ContactsFriendsView: View {

    @EnvironmentObject private var recentSearches: RecentSearchesStore
    @StateObject private var viewModel = ContactsFriendsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch viewModel.phase {
                case .intro:
                    intro
                case .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.top, 40)
                case .denied:
                    denied
                case .loaded:
                    results
                }
            }
            .padding(16)
        }
        .withStandardPageStyle(title: "Find friends", extendView: false)
    }

    private var intro: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 56))
                .foregroundColor(Color("primaryButton"))
            Text("Find friends from your contacts")
                .font(Style.Typography.cardTitle)
                .foregroundColor(Color("headerText"))
                .multilineTextAlignment(.center)
            Text("We match your contacts to Dare accounts on your device. Your phone numbers are never uploaded — only a private one-way hash is used to find matches.")
                .font(Style.Typography.secondary)
                .foregroundColor(Color("detailText"))
                .multilineTextAlignment(.center)

            InteractiveButton(
                action: { viewModel.start() },
                backgroundColor: Color("primaryButton"),
                cornerRadius: Style.CornerRadius.small,
                padding: 16,
                scaleEffect: true
            ) {
                HStack {
                    Spacer()
                    Text("Continue")
                        .font(Style.Typography.button)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    private var denied: some View {
        VStack(spacing: 12) {
            Text("Contacts access is off")
                .font(Style.Typography.cardTitle)
                .foregroundColor(Color("headerText"))
            Text("Enable Contacts access for Dare in Settings to find friends this way.")
                .font(Style.Typography.secondary)
                .foregroundColor(Color("detailText"))
                .multilineTextAlignment(.center)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .font(Style.Typography.bodyStrong)
                    .foregroundColor(Color("primaryButton"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    @ViewBuilder
    private var results: some View {
        if viewModel.matches.isEmpty {
            EmptyArrayMessageView(message: "None of your contacts are on Dare yet.")
        } else {
            HeaderLabelView(text: "From your contacts")
            UserListView(
                users: viewModel.matches,
                onSelect: { user in if let id = user.id { recentSearches.record(id) } }
            )
        }
    }
}
