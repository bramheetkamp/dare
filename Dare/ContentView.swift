//
//  ContentView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/2024.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            switch viewModel.authState {
            case .loading:
                ProgressView()
                    .scaleEffect(2)
                
            case .authenticated:
                mainInterfaceView
                
            case .unauthenticated:
                authInterfaceView
            }
        }
        .animation(.default, value: viewModel.authState)
    }
}

extension ContentView {
    var authInterfaceView: some View {
        NavigationStack(path: $router.navigationPath) {
            LoginView()
                .navigationDestination(for: AppDestination.self) { destination in
                    ViewFactory.view(for: destination, router: router)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer()
                            Image("dareLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 32)
                            Spacer()
                        }
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { destination in
            ViewFactory.view(for: destination, router: router)
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { destination in
            ViewFactory.view(for: destination, router: router)
        }
    }
    
    var mainInterfaceView: some View {
        NavigationStack(path: $router.navigationPath) {
            MainTabView(selectedIndex: $router.selectedTabIndex)
                .navigationDestination(for: AppDestination.self) { destination in
                    ViewFactory.view(for: destination, router: router)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("")
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Spacer()
                            Image("dareLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 32)
                            Spacer()
                        }
                    }
                    
                    if router.selectedTabIndex == 0 {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                router.present(sheet: .createChallenge)
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
        }
        .sheet(item: $router.presentedSheet) { destination in
            ViewFactory.view(for: destination, router: router)
        }
        .fullScreenCover(item: $router.presentedFullScreenCover) { destination in
            ViewFactory.view(for: destination, router: router)
        }
    }
}

