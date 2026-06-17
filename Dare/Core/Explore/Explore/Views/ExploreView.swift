//
//  ExploreView.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/06/2025.
//

import SwiftUI

struct ExploreView: View {
    
    @StateObject private var viewModel = ExploreViewModel()
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    discoveryEntry(icon: "magnifyingglass", title: "Search people", destination: .searchPeople)
                    discoveryEntry(icon: "person.2.fill", title: "Find friends from contacts", destination: .contactsFriends)
                    discoveryEntry(icon: "person.3.fill", title: "Groups", destination: .searchGroups)

                    HeaderLabelView(text: "All categories")
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ],
                        spacing: 10
                    ) {
                        ForEach(viewModel.categories) { category in
                            CategoryRow(category: category)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .padding(0)
    }

    private func discoveryEntry(icon: String, title: String, destination: AppDestination) -> some View {
        InteractiveButton(
            action: { router.navigate(to: destination) },
            backgroundColor: Color("cell"),
            cornerRadius: Style.CornerRadius.small,
            padding: 12,
            scaleEffect: true
        ) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(Color("detailText"))
                Text(title)
                    .font(Style.Typography.body)
                    .foregroundColor(Color("detailText"))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("detailText"))
            }
        }
    }
}
