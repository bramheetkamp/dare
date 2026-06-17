//
//  ProfileSettingsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 06/07/2025.
//

import SwiftUI
import Kingfisher

struct ProfileSettingsView: View {

    let userId: String
    @StateObject var viewModel: ProfileSettingsViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel

    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system

    @State private var showImagePicker = false
    @State private var pickedImage: UIImage?

    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: ProfileSettingsViewModel(userId: userId))
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                photoSection

                if let user = authViewModel.currentUser {
                    ProfileStatsView(stats: [
                        ("Points", "\(user.totalPoints)"),
                        ("Day streak", "\(user.streak) 🔥"),
                        ("Best streak", "\(user.bestStreak)"),
                        ("Level", "\(user.level)")
                    ])
                }

                appearanceSection

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
        .sheet(isPresented: $showImagePicker, onDismiss: uploadPickedImage) {
            ImagePicker(selectedImage: $pickedImage)
        }
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            KFImage(URL(string: authViewModel.currentUser?.avatarUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color("primaryButton"), lineWidth: 3))

            Button("Change photo") { showImagePicker = true }
                .font(Style.Typography.bodyStrong)
                .foregroundColor(Color("primaryButton"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func uploadPickedImage() {
        guard let pickedImage else { return }
        authViewModel.uploadProfileImage(pickedImage)
        self.pickedImage = nil
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appearance")
                .font(Style.Typography.sectionTitle)
                .foregroundColor(.headerText)

            Picker("Appearance", selection: $appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Label(mode.label, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cell)
        .clipShape(RoundedRectangle(cornerRadius: Style.CornerRadius.small))
    }

}
