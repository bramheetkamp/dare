//
//  UserListSkeletonView.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/06/2025.
//

import SwiftUI

struct UserListSkeletonView: View {
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                UserRowSkeleton()
            }
        }
    }
}

struct UserRowSkeleton: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonView(shape: .circle)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                SkeletonView()
                    .frame(width: 120, height: 16)
                SkeletonView()
                    .frame(width: 80, height: 14)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
