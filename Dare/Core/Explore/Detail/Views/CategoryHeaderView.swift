//
//  CategoryHeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 16/06/2025.
//

import SwiftUI
import Kingfisher

struct CategoryHeaderView: View {
    
    @ObservedObject var viewModel: CategoryDetailViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.valid(named: viewModel.challengeCategory?.backgroundColor)
                .frame(height: 200 + safeAreaTopPadding())
                .cornerRadius(Style.CornerRadius.small, corners: [.bottomLeft, .bottomRight])
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.challengeCategory?.title ?? "")
                            .font(.title2).fontWeight(.black)
                            .foregroundColor(Color.white)
                    }
                }
                .padding(.top, safeAreaTopPadding())
            }
            .padding(.leading, 16)
            .padding(.bottom, 16)
        }
    }
    
    func safeAreaTopPadding() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}


