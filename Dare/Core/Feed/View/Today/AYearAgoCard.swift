//
//  AYearAgoCard.swift
//  Dare
//
//  A gentle "you, a year ago" strip on the Today screen. Quietly hides itself when there's
//  nothing to resurface, so it never nags — it's a pleasant surprise, not an obligation.
//

import SwiftUI
import Kingfisher

struct AYearAgoCard: View {
    let memories: [PublicPost]
    let onTap: (PublicPost) -> Void

    var body: some View {
        if !memories.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(Color("dareGold"))
                    Text("A year ago")
                        .font(Style.Typography.sectionTitle)
                        .foregroundColor(Color("headerText"))
                    Spacer()
                    Text("look how far you've come")
                        .font(.caption)
                        .foregroundColor(Color("detailText"))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(memories) { memory in
                            MemoryThumb(post: memory)
                                .onTapGesture { onTap(memory) }
                        }
                    }
                }
            }
            .padding(16)
            .background(Color("cell"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

private struct MemoryThumb: View {
    let post: PublicPost

    private var note: String {
        if let title = post.title, !title.isEmpty { return title }
        if let caption = post.caption, !caption.isEmpty { return caption }
        return post.challenge?.challenge ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                if let first = post.imageUrls?.first, let url = URL(string: first) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [Color("primaryButton").opacity(0.7), Color("dareBlue")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    if let emoji = post.challenge?.emojis?.first {
                        Text(emoji).font(.system(size: 34))
                    }
                }
            }
            .frame(width: 110, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(note)
                .font(.caption2)
                .foregroundColor(Color("detailText"))
                .lineLimit(1)
                .frame(width: 110, alignment: .leading)
        }
    }
}
