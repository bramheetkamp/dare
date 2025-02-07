//
//  CommentsViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 10/11/2024.
//


import SwiftUI

class CommentsViewModel: ObservableObject {
    @Published var comments = [Comment]()
    @Published var newCommentText: String = ""
    let commentService = CommentService()
    let userService = UserService()
    let post: Post
    
    init(post: Post) {
        self.post = post
        self.fetchComments()
    }
    
    func addComment(text: String) {
        guard let postId = post.id else { return }
        commentService.addComment(postId: postId, text: text, completion: { success in
            if success {
                self.newCommentText = ""
            } else {
                //show error
            }
        })
    }
    
    func fetchComments() {
        guard let postId = post.id else { return }
        commentService.fetchComments(postId: postId) { comments in
            self.comments = comments
            
            for index in 0 ..< comments.count {
                let uid = comments[index].uid
                
                self.userService.fetchUser(withUid: uid) { user in
                    self.comments[index].user = user
                }
            }
        }
    }
}
