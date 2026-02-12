//
//  HeaderView.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .foregroundStyle(.white)
                .fontWeight(.heavy)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: title)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
            Spacer()
            
            HStack(spacing: 4) {
                Text("7")
                    .font(.headline)
                    .foregroundColor(.white)

                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 44)
    }
}
