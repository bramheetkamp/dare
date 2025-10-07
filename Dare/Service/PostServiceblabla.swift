//
//  PostServiceblabla.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation

struct PostServiceblabla {
    
    // MARK: - Upload
    
    func uploadPost(challengeId: String, caption: String, location: String?, image: UIImage?, videoUrl: URL?, challengeType: String?, date: Date?, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        if let videoUrl = videoUrl {
            let filename = UUID().uuidString + ".mp4"
            let storageRef = Storage.storage().reference().child("post_videos/\(filename)")
            
            compressVideo(inputURL: videoUrl) { compressedUrl in
                guard let compressedUrl = compressedUrl else {
                    completion(false)
                    return
                }
                
                guard let thumbnailImage = self.generateThumbnail(from: compressedUrl),
                      let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.5) else {
                    completion(false)
                    return
                }
                
                let thumbnailRef = Storage.storage().reference().child("post_images/\(UUID().uuidString).jpg")
                thumbnailRef.putData(thumbnailData, metadata: nil) { _, error in
                    if let error = error {
                        print("Thumbnail upload failed: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    thumbnailRef.downloadURL { thumbnailUrl, _ in
                        storageRef.putFile(from: compressedUrl, metadata: nil) { _, error in
                            if let error = error {
                                print("Video upload failed: \(error.localizedDescription)")
                                completion(false)
                                return
                            }
                            
                            let videoAspectRatio = Float(thumbnailImage.size.width / thumbnailImage.size.height)
                            
                            storageRef.downloadURL { videoUrl, _ in
                                self.savePostToFirestore(
                                    uid: uid,
                                    challengeId: challengeId,
                                    caption: caption,
                                    location: location,
                                    imageUrl: thumbnailUrl?.absoluteString ?? "",
                                    videoUrl: videoUrl?.absoluteString ?? "",
                                    date: date,
                                    mediaAspectRatio: videoAspectRatio,
                                    completion: completion
                                )
                            }
                        }
                    }
                }
            }
            return
        }
        
        
        if let image = image {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                completion(false)
                return
            }
            
            let filename = UUID().uuidString
            let storageRef = Storage.storage().reference().child("post_images/\(filename)")
            
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("DEBUG: Failed to upload image with error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("DEBUG: Failed to get image URL with error: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    guard let imageDownloadUrl = url?.absoluteString else { return }
                    let aspectRatio = Float(image.size.width / image.size.height)
                    
                    self.savePostToFirestore(uid: uid, challengeId: challengeId, caption: caption, location: location, imageUrl: imageDownloadUrl, videoUrl: nil, date: date, mediaAspectRatio: aspectRatio, completion: completion)
                }
            }
            return
        }
        
        // If no image or video provided, just save the post data
        self.savePostToFirestore(uid: uid, challengeId: challengeId, caption: caption, location: location, imageUrl: nil, videoUrl: nil, date: date, mediaAspectRatio: nil, completion: completion)
    }
    
    
    // MARK: - Firestore Saving
    
    private func savePostToFirestore(uid: String, challengeId: String, caption: String, location: String?, imageUrl: String?, videoUrl: String? = nil, date: Date?, mediaAspectRatio: Float?, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "uid": uid,
            "caption": caption.trimmingCharacters(in: .whitespaces),
            "challengeId": challengeId,
            "timestamp": Timestamp(date: Date()),
            "timestampUpdate": Timestamp(date: date ?? Date()),
            "location": location?.trimmingCharacters(in: .whitespaces) ?? "",
            "likes": 0,
            "imageUrl": imageUrl ?? "",
            "videoUrl": videoUrl ?? "",
            "mediaAspectRatio": mediaAspectRatio
        ]
        
        Firestore.firestore().collection("posts").addDocument(data: data) { error in
            if let error = error {
                print("DEBUG: Failed to save post to Firestore with error: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    // MARK: - Fetching
    
    func fetchPosts(limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }
            
            var posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
            let group = DispatchGroup()
            
            for (index, post) in posts.enumerated() {
                // Ensure the post has a challengeId property
                guard let challengeId = post.challengeId else { continue }
                group.enter()
                
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    posts[index].challenge = challenge
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(posts, snapshot.documents.last)
            }
            
        }
    }
    
    func fetchPosts(uid: String?, limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let uid = uid {
            query = query.whereField("uid", isEqualTo: uid)
        }
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }
            
            var posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
            let group = DispatchGroup()
            
            for (index, post) in posts.enumerated() {
                // Ensure the post has a challengeId property
                guard let challengeId = post.challengeId else { continue }
                group.enter()
                
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    posts[index].challenge = challenge
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(posts, snapshot.documents.last)
            }
        }
    }
    
    func fetchPosts(challengeId: String?, limit: Int, lastDocument: DocumentSnapshot?, completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void) {
        var query = Firestore.firestore().collection("posts")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
        
        if let challengeId = challengeId {
            query = query.whereField("challengeId", isEqualTo: challengeId)
        }
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            guard let snapshot = snapshot else {
                print("No snapshot found")
                completion([], nil)
                return
            }
            
            var posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
            let group = DispatchGroup()
            
            for (index, post) in posts.enumerated() {
                // Ensure the post has a challengeId property
                guard let challengeId = post.challengeId else { continue }
                group.enter()
                
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    posts[index].challenge = challenge
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(posts, snapshot.documents.last)
            }
        }
    }

    func fetchFeedPosts(
        followingUserIds: [String],
        limit: Int,
        lastDocument: DocumentSnapshot?,
        completion: @escaping ([PublicPost], DocumentSnapshot?) -> Void
    ) {
        let batchSize = 10
        let batches = stride(from: 0, to: followingUserIds.count, by: batchSize).map {
            Array(followingUserIds[$0..<min($0 + batchSize, followingUserIds.count)])
        }
        
        let group = DispatchGroup()
        var allPosts: [PublicPost] = []
        var allDocuments: [QueryDocumentSnapshot] = []
        var fetchError: Error?
        
        for batch in batches {
            group.enter()
            var query = Firestore.firestore().collection("posts")
                .whereField("uid", in: batch)
                .order(by: "timestamp", descending: true)
                .limit(to: limit)
            
            if let lastDocument = lastDocument, batch == batches.first {
                query = query.start(afterDocument: lastDocument)
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    fetchError = error
                } else if let snapshot = snapshot {
                    allDocuments.append(contentsOf: snapshot.documents)
                    let posts = snapshot.documents.compactMap { try? $0.data(as: PublicPost.self) }
                    allPosts.append(contentsOf: posts)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                print("Error fetching feed posts: \(error.localizedDescription)")
                completion([], nil)
                return
            }
            
            let sortedPosts = allPosts.sorted { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            let limitedPosts = Array(sortedPosts.prefix(limit))
            
            let challengeGroup = DispatchGroup()
            var postsWithChallenges = limitedPosts
            for (index, post) in postsWithChallenges.enumerated() {
                guard let challengeId = post.challengeId else { continue }
                challengeGroup.enter()
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    postsWithChallenges[index].challenge = challenge
                    challengeGroup.leave()
                }
            }
            
            challengeGroup.notify(queue: .main) {
                let lastDoc = allDocuments.sorted { doc1, doc2 in
                    let ts1 = doc1.get("timestamp") as? Timestamp ?? Timestamp(date: Date.distantPast)
                    let ts2 = doc2.get("timestamp") as? Timestamp ?? Timestamp(date: Date.distantPast)
                    return ts1.dateValue() > ts2.dateValue()
                }.prefix(limit).last
                completion(postsWithChallenges, lastDoc)
            }
        }
    }

    
    func fetchPost(_ postId: String, completion: @escaping (PublicPost?) -> Void) {
        Firestore.firestore().collection("posts").document(postId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("No snapshot found")
                completion(nil)
                return
            }
            
            do {
                var post = try snapshot.data(as: PublicPost.self)
                guard let challengeId = post.challengeId else {
                    completion(post)
                    return
                }
                
                ChallengeService().fetchChallenge(challengeId: challengeId) { challenge in
                    post.challenge = challenge
                    completion(post)
                }
            } catch {
                print("Error decoding post: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    
    // MARK: - Utilities
    
    private func compressVideo(inputURL: URL, completion: @escaping (URL?) -> Void) {
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        let asset = AVAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            completion(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(outputURL)
            default:
                completion(nil)
            }
        }
    }
    
    func generateThumbnail(from videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension PostService {
    
    // MARK: - Likes
    
    // MARK: Like a Post
    func likePost(_ post: PublicPost, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        let postRef = Firestore.firestore().collection("posts").document(postId)
        let postLikesRef = postRef.collection("likes").document(uid)
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes").document(postId)
        
        let batch = Firestore.firestore().batch()
        batch.updateData(["likes": post.likes + 1], forDocument: postRef)
        batch.setData(["timestamp": Timestamp(date: Date())], forDocument: postLikesRef)
        batch.setData(["timestamp": Timestamp(date: Date())], forDocument: userLikesRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("DEBUG: Failed to like post with error \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully liked post.")
                completion()
            }
        }
    }
    
    // MARK: Unlike a Post
    func unlikePost(_ post: PublicPost, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        let postRef = Firestore.firestore().collection("posts").document(postId)
        let postLikesRef = postRef.collection("likes").document(uid)
        let userLikesRef = Firestore.firestore().collection("users").document(uid).collection("user-likes").document(postId)
        
        let batch = Firestore.firestore().batch()
        batch.updateData(["likes": max(post.likes - 1, 0)], forDocument: postRef)
        batch.deleteDocument(postLikesRef)
        batch.deleteDocument(userLikesRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("DEBUG: Failed to unlike post with error \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully unliked post.")
                completion()
            }
        }
    }
    
    // MARK: Check if User Liked Post
    func checkIsUserLikedPost(_ post: PublicPost, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("likes")
            .document(uid)
            .getDocument { snapshot, _ in
                guard let snapshot = snapshot else { return }
                completion(snapshot.exists)
            }
    }
}
