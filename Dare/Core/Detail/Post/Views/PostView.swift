//
//  PostView.swift
//  Dare
//
//  Created by Bram Heetkamp on 05/10/2025.
//

import SwiftUI
import FirebaseAuth

struct PostView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject private var postsStore: PostsStore
    
    @State private var selectedFilter: PostDetailFilter = .all
    
    private let postId: String
    
    // MARK: - Initialization
    
    init(postId: String) {
        self.postId = postId
    }

    var body: some View {
        PostDetailView(postId: postId, postsStore: postsStore, selectedFilter: $selectedFilter)
    }
}

