//
//  CreateGroupView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

struct CreateGroupView: View {

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var groupsStore: GroupsStore
    @StateObject private var viewModel = CreateGroupViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                field(title: "Emoji") {
                    TextField("👥", text: $viewModel.emoji)
                        .onChange(of: viewModel.emoji) {
                            // Keep a single emoji/character.
                            if viewModel.emoji.count > 1 {
                                viewModel.emoji = String(viewModel.emoji.suffix(1))
                            }
                        }
                }

                field(title: "Name") {
                    TextField("e.g. Sourdough Sunday", text: $viewModel.name)
                }

                field(title: "Description") {
                    TextField("What's this group about?", text: $viewModel.description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Toggle(isOn: $viewModel.isPublic) {
                    Text("Public group")
                        .font(Style.Typography.body)
                        .foregroundColor(Color("headerText"))
                }
                .tint(Color("primaryButton"))

                InteractiveButton(
                    action: submit,
                    backgroundColor: Color("primaryButton"),
                    cornerRadius: Style.CornerRadius.small,
                    padding: 16,
                    scaleEffect: true
                ) {
                    HStack {
                        Spacer()
                        if viewModel.isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create group")
                                .font(Style.Typography.button)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .opacity(viewModel.canSubmit ? 1 : 0.5)
                .disabled(!viewModel.canSubmit)
            }
            .padding(16)
        }
        .withStandardPageStyle(title: "New group", extendView: false)
    }

    private func field<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Style.Typography.caption)
                .foregroundColor(Color("detailText"))
            content()
                .font(Style.Typography.body)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("cell"))
                .foregroundColor(Color("headerText"))
                .cornerRadius(Style.CornerRadius.small)
        }
    }

    private func submit() {
        viewModel.create { group in
            guard let group else { return }
            groupsStore.insertOrUpdate([group])
            router.navigateBack()
        }
    }
}
