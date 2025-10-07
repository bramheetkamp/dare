//
//  ProfileSettingsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 06/07/2025.
//

import SwiftUI

struct ProfileSettingsView: View {
    
    let userId: String
    @StateObject var viewModel: ProfileSettingsViewModel
    
    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: ProfileSettingsViewModel(userId: userId))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ProfileStatsView(stats: [
                    ("Challenges", "45"),
                    ("Finished", "30"),
                    ("Updates", "15"),
                    ("Rank", "12 🏆")
                ])
                
                InteractiveButton(
                    action: {
                        do {
                            try viewModel.logout()
                        } catch {
                            print("Failed to logout: \(error)")
                        }
                    },
                    backgroundColor: .secondaryButton,
                    cornerRadius: Style.CornerRadius.small,
                    padding: 16,
                    scaleEffect: true
                ) {
                    HStack {
                        Text("Log out")
                            .font(.system(size: Style.FontSize.medium, weight: .semibold))
                            .foregroundColor(Color.white)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: Style.FontSize.medium, weight: .bold))
                            .foregroundColor(Color.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)
        }
        .withStandardPageStyle(title: "Settings", extendView: false)
    }
    
}
