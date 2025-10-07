//
//  UserRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct UserRowView: View {
    @ObservedObject var viewModel: UserRowViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Button {
            guard let userId = viewModel.user.id, !userId.isEmpty else { return }
            router.navigate(to: .profile(userId: userId))
        } label: {
            HStack(spacing: 12) {
                KFImage(URL(string: viewModel.user.avatarUrl))
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(viewModel.user.username)")
                        .font(.subheadline).bold()
                        .foregroundColor(Color("headerText"))
                    Text(viewModel.user.id == Auth.auth().currentUser?.uid ? "You" : ("@\(viewModel.user.username)"))
                        .font(.subheadline)
                        .foregroundColor(Color("detailText"))
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("cell"))
            .cornerRadius(Style.CornerRadius.small)
        }
    }
}
