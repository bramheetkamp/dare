//
//  LoadingIndicatorView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct LoadingIndicatorView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ProgressView()
                    .padding()
                    .transition(.opacity)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
