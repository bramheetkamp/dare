//
//  ProfileHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var usersStore: UsersStore
    
    private let userId: String
    var user: User? {
        usersStore.user(withId: userId)
    }
    
    // MARK: - Initialization
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color("primaryButton")
                .frame(height: 280 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    KFImage(URL(string: user?.avatarUrl ?? ""))
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 54, height: 54)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user?.fullname ?? "")
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(Color.white)
                        
                        Text("@\(user?.username ?? "")")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.top, safeAreaTopPadding())
                
                if user?.description != nil {
                    Text(user?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    HStack {
                        Text("\(user?.followersCount ?? 0) Followers")
                    }
                    HStack {
                        Text("\(user?.followingCount ?? 0) Following")
                    }
                }
                .font(.subheadline)
                .foregroundColor(Color.white)
                .bold()
                
                InteractiveButtonStack(
                    action: handleButton,
                    cornerRadius: Style.CornerRadius.small,
                    backgroundColor: Color("secondaryButton")
                ) {
                    HStack {
                        Text(actionButtonTitle)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private func handleButton() {
        if user?.isCurrentUser == true {
            router.navigate(to: .profileSettings(userId: userId))
        } else {
            if user?.isFollowing ?? false {
                usersStore.unfollowFriend(userId: userId) {
                    print("unfollowed")
                }
            } else {
                usersStore.followFriend(userId: userId) {
                    print("followed")
                }
            }
        }
    }
    
    var actionButtonTitle: String {
        guard let user = user else { return "" }
        return user.isCurrentUser ? "Settings" : (user.isFollowing ?? false ? "Unfollow" : "Follow")
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}
