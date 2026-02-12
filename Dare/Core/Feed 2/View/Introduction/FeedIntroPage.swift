//
//  FeedIntroPage.swift
//  Dare
//
//  Created by Bram Heetkamp on 12/02/2026.
//

import SwiftUI

struct FeedIntroPage: View {
    let blocks: [FeedIntroItem]

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(blocks) { block in
                        RoundedRectangle(cornerRadius: 14)
                            .fill(block.color)
                            .frame(width: 200, height: 300)
                            .overlay(alignment: .bottomLeading) {
                                VStack {
                                    Text(block.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                        .padding(.horizontal, 20)
                                        .padding(.bottom, 4)
                                    Button {
                                        // TODO: handle action
                                    } label: {
                                        Text("Check in")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(.white)
                                            .foregroundStyle(.black)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 24)
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }

            Spacer()
        }
        .background(
            LinearGradient(colors: [.purple, .black], startPoint: .top, endPoint: .bottom)
        )
        .ignoresSafeArea()
    }
}
