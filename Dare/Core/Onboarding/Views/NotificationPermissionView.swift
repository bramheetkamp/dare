//
//  NotificationPermissionView.swift
//  Dare
//
//  Pre-permission priming screen shown at the end of onboarding, before the iOS system
//  dialog. Explaining value before asking for permission significantly boosts opt-in rate.
//

import SwiftUI

struct NotificationPermissionView: View {

    /// Called when the user makes their choice (either yes or not now).
    var onDone: () -> Void

    @State private var isRequesting = false
    private let notificationService = NotificationService()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            iconSection

            Spacer()

            textSection
                .padding(.horizontal, 32)

            Spacer()

            buttonSection
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .background(Color("background"))
    }

    // MARK: - Subviews

    private var iconSection: some View {
        Image(systemName: "bell.badge.fill")
            .font(.system(size: 80))
            .foregroundColor(Color("primaryButton"))
            .padding(40)
            .background(Color("primaryButton").opacity(0.12))
            .clipShape(Circle())
    }

    private var textSection: some View {
        VStack(spacing: 14) {
            Text("A gentle weekly nudge")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(Color("headerText"))

            Text("Once a week — never more — we'll remind you to share a quick goal update and keep your streak alive. Your phone, your terms.")
                .font(.body)
                .foregroundColor(Color("detailText"))
                .multilineTextAlignment(.center)
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button {
                Task { await allowTapped() }
            } label: {
                Group {
                    if isRequesting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Yes, nudge me weekly")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color("primaryButton"))
                .clipShape(Capsule())
            }
            .disabled(isRequesting)

            Button("Not now") {
                onDone()
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(Color("detailText"))
        }
    }

    // MARK: - Actions

    private func allowTapped() async {
        isRequesting = true
        let granted = await notificationService.requestPermission()
        if granted {
            notificationService.scheduleWeeklyRitual()
        }
        isRequesting = false
        onDone()
    }
}

#Preview {
    NotificationPermissionView(onDone: {})
}
