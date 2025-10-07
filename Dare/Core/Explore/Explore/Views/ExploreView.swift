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
                    InteractiveButton(
                        action: {
                            router.navigate(to: .searchPeople)
                        },
                        backgroundColor: Color("cell"),
                        cornerRadius: Style.CornerRadius.small,
                        padding: 10,
                        scaleEffect: true
                    ) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color("detailText"))
                            Text("Search people")
                                .foregroundColor(Color("detailText"))
                            Spacer()
                        }
                    }

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
}
