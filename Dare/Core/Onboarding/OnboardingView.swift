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

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "flame.fill",
            tint: .orange,
            title: "Welcome to Dare",
            body: "Dare is where friends challenge each other to do something real. Take on a dare, prove it, and dare them back."
        ),
        OnboardingPage(
            systemImage: "bolt.heart.fill",
            tint: Color("primaryButton"),
            title: "Take on challenges",
            body: "Browse challenges from people you follow, pick one that scares you a little, and post your photo or video answer."
        ),
        OnboardingPage(
            systemImage: "person.2.fill",
            tint: .blue,
            title: "A close circle, not a feed to scroll forever",
            body: "Dare is built around the people you actually know. Follow friends, react, and keep each other going — quality over endless scrolling."
        ),
        OnboardingPage(
            systemImage: "star.fill",
            tint: Color("dareGold"),
            title: "Build your streak",
            body: "Show up daily to grow your streak, earn points, and level up. Miss a day and the flame resets — so keep coming back."
        )
    ]

    private var isLastPage: Bool { index == pages.count - 1 }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Log in", action: onFinish)
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
                    onFinish()
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
