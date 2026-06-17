//
//  OnboardingView.swift
//  Dare
//
//  First-run explanation of what Dare is and why to come back. Shown before the login screen
//  for users who haven't seen it yet (gated by @AppStorage("hasSeenOnboarding") in ContentView).
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let tint: Color
    let title: String
    let body: String
}

struct OnboardingView: View {
    /// Called when the user finishes onboarding (taps "Get started" or "Log in").
    var onFinish: () -> Void

    @State private var index = 0
    @State private var showNotificationPriming = false
    @Environment(\.trackAnalyticsEvent) private var track

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "sparkles",
            tint: Color("primaryButton"),
            title: "A lowkey window into what drives you",
            body: "Dare is a calm place to see what your people are into — and to track who you're becoming. Just a quick pic and a short note."
        ),
        OnboardingPage(
            systemImage: "figure.climbing",
            tint: .orange,
            title: "Chase what you're becoming",
            body: "Pick a journey — learn to bake, get your first pull-up, build a chair — and post small updates as you go. Progress over perfection."
        ),
        OnboardingPage(
            systemImage: "person.2.fill",
            tint: .blue,
            title: "A small circle that keeps it real",
            body: "No like-counts, no endless scroll, no strangers in your space — just a few people who actually see you and keep you honest."
        ),
        OnboardingPage(
            systemImage: "clock.arrow.circlepath",
            tint: Color("dareGold"),
            title: "See how far you've come",
            body: "Keep a weekly rhythm to grow your streak, and look back at what drove you a year ago. The record of your becoming."
        )
    ]

    private var isLastPage: Bool { index == pages.count - 1 }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Log in") {
                    track(.onboardingCompleted)
                    onFinish()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color("primaryButton"))
                .padding()
                .opacity(isLastPage ? 0 : 1)
                .disabled(isLastPage)
            }

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { offset, page in
                    pageView(page).tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: index)

            Button {
                if isLastPage {
                    track(.onboardingCompleted)
                    showNotificationPriming = true
                } else {
                    withAnimation { index += 1 }
                }
            } label: {
                Text(isLastPage ? "Get started" : "Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("primaryButton"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .sheet(isPresented: $showNotificationPriming) {
                NotificationPermissionView {
                    showNotificationPriming = false
                    onFinish()
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .trackScreen(.onboarding)
        .onAppear {
            track(.onboardingStarted)
            track(.onboardingPageViewed(index: 0))
        }
        .onChange(of: index) { _, newIndex in
            track(.onboardingPageViewed(index: newIndex))
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: page.systemImage)
                .font(.system(size: 84))
                .foregroundColor(page.tint)
                .padding(40)
                .background(page.tint.opacity(0.12))
                .clipShape(Circle())

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
