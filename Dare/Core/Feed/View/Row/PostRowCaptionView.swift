//
//  PostRowCaptionView.swift
//  Dare
//
//  Created by Bram Heetkamp on 15/06/2025.
//

import SwiftUI

struct PostRowCaptionView: View {
    
    @EnvironmentObject private var postsStore: PostsStore
    
    var postId: String
    var post: PublicPost? {
        postsStore.post(withId: postId)
    }
    
    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool = false
    
    init(postId: String) {
        self.postId = postId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let post = post {
                let combinedText = buildCombinedText(
                    title: post.title,
                    caption: post.caption
                )
                
                if !combinedText.isEmpty {
                    ExpandableOneLineText(
                        text: combinedText,
                        isExpanded: $isExpanded,
                        isTruncated: $isTruncated
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func buildCombinedText(title: String?, caption: String?) -> String {
        let cleanTitle = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCaption = (caption ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanTitle.isEmpty { return cleanCaption }
        if cleanCaption.isEmpty { return cleanTitle }
        
        // You can change the separator if you want:
        return "\(cleanTitle) — \(cleanCaption)"
    }
}

private struct ExpandableOneLineText: View {
    
    let text: String
    
    @Binding var isExpanded: Bool
    @Binding var isTruncated: Bool
    
    private let animation = Animation.spring(response: 0.35, dampingFraction: 0.9)
    
    @State private var oneLineHeight: CGFloat = .zero
    @State private var fullHeight: CGFloat = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Color("headerText"))
                .multilineTextAlignment(.leading)
                .lineLimit(isExpanded ? nil : 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    guard isTruncated else { return }
                    withAnimation(animation) {
                        isExpanded.toggle()
                    }
                }
                .animation(animation, value: isExpanded)
                .background(
                    measurementLayer
                )
            
            if isTruncated {
                Button {
                    withAnimation(animation) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show less" : "Show more")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("detailText"))
                }
                .buttonStyle(.plain)
            }
        }
        .onChange(of: oneLineHeight) { _ in updateTruncation() }
        .onChange(of: fullHeight) { _ in updateTruncation() }
        .onChange(of: text) { _ in
            oneLineHeight = .zero
            fullHeight = .zero
        }
    }
    
    private var measurementLayer: some View {
        VStack {
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { oneLineHeight = geo.size.height }
                            .onChange(of: geo.size.height) { oneLineHeight = $0 }
                    }
                )
                .hidden()
            
            Text(text)
                .font(.subheadline)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { fullHeight = geo.size.height }
                            .onChange(of: geo.size.height) { fullHeight = $0 }
                    }
                )
                .hidden()
        }
    }
    
    private func updateTruncation() {
        // If full height is bigger than one-line height -> it overflows.
        if oneLineHeight > 0 && fullHeight > 0 {
            isTruncated = fullHeight > oneLineHeight + 0.5
        }
    }
}
