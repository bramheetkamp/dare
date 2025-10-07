//
//  ProfileHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("primaryButton")
                .frame(height: 200 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 16) {
                    KFImage(URL(string: viewModel.user?.avatarUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 54, height: 54)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.user?.fullname ?? "")
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(Color.white)
                        
                        Text("@\(viewModel.user?.username ?? "")")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.top, safeAreaTopPadding())
                
                HStack(spacing: 24) {
                    HStack {
                        Text("\(viewModel.user?.followersCount ?? 0) Followers")
                    }
                    HStack {
                        Text("\(viewModel.user?.followingCount ?? 0) Following")
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.white)
                .bold()
                .padding(.top, 4)
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
            
            // Edit profile/follow button
            HStack(spacing: 12) {
                InteractiveButtonStack(
                    action: {
                        if ((viewModel.user?.isCurrentUser) != nil) {
                            guard let userId = viewModel.user?.id else { return }
                            router.navigate(to: .profileSettings(userId: userId))
                        } else {
                            viewModel.followOrUnfollowUser()
                        }
                    },
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: Color("secondaryButton")
                ) {
                    HStack {
                        Text(viewModel.actionButtonTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 20)
            .offset(y: 20)
        }
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}
