//
//  CommentsViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/11/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CommentsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var comments = [Comment]()
    @Published var newCommentText: String = ""
    @Published var isLoading = false
    @Published var hasMoreComments = true

    private var lastDocument: DocumentSnapshot?
    private let pageSize = 10

    let commentService = CommentService()
    let userService = UserService()

    let postId: String

    // MARK: - Lifecycle
    
    init(postId: String) {
        self.postId = postId
    }

    // MARK: - Methods
    
    func addComment(text: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let newComment = Comment(
            id: UUID().uuidString,
            uid: userId,
            text: text,
            timestamp: Timestamp(date: Date()),
            user: User(username: "", fullname: "You", profileImageUrl: nil, email: "", timestamp: Timestamp(), location: "", description: "")
        )

        commentService.addComment(postId: postId, text: text) { [weak self] success in
            guard let self = self else { return }
            if success {
                Task { @MainActor in
                    self.comments.insert(newComment, at: 0)
                    self.newCommentText = ""
                }
            }
        }
    }
    
    func fetchComments() {
        guard !isLoading else { return }

        isLoading = true

        commentService.fetchComments(postId: postId, limit: pageSize, lastDocument: lastDocument) { [weak self] newComments, lastDoc in
            guard let self = self else { return }
            
            // Handle empty fetch early and reset loading state
            guard !newComments.isEmpty else {
                Task { @MainActor in
                    self.hasMoreComments = false
                    self.isLoading = false
                }
                return
            }

            var updatedComments = [Comment?](repeating: nil, count: newComments.count)
            let group = DispatchGroup()

            for (index, comment) in newComments.enumerated() {
                group.enter()
                self.userService.fetchUser(withUid: comment.uid) { user in
                    var commentWithUser = comment
                    commentWithUser.user = user
                    updatedComments[index] = commentWithUser
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.comments.append(contentsOf: updatedComments.compactMap { $0 })
                self.lastDocument = lastDoc
                self.isLoading = false
            }
        }
    }
    
    func resetPagination() {
        comments.removeAll()
        lastDocument = nil
        hasMoreComments = true
        isLoading = false
    }
}
