//
//  PostUploadService.swift
//  Dare
//
//  Created by Bram Heetkamp on 03/10/2025.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import AVFoundation
import FirebaseFirestore

struct PostUploadService {
    private let storage = Storage.storage()
    private let auth = Auth.auth()
    private let postService = PostService()
    private let db = Firestore.firestore()

    private func postImagesRef(filename: String) -> StorageReference {
        return storage.reference().child("post_images/\(filename)")
    }

    private func postVideosRef(filename: String) -> StorageReference {
        return storage.reference().child("post_videos/\(filename)")
    }
    
    func savePostWithMediaArrays(
        challengeId: String,
        title: String?,
        caption: String,
        location: String?,
        imageUrls: [String],
        videoUrls: [String],
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else {
            completion(nil)
            return
        }
        
        let data: [String: Any] = [
            "uid": uid,
            "title": title?.trimmingCharacters(in: .whitespaces) ?? "",
            "caption": caption.trimmingCharacters(in: .whitespaces),
            "challengeId": challengeId,
            "timestamp": Timestamp(date: Date()),
            "timestampUpdate": Timestamp(date: date ?? Date()),
            "location": location?.trimmingCharacters(in: .whitespaces) ?? "",
            "likes": 0,
            "imageUrls": imageUrls,
            "videoUrls": videoUrls
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: data) { error in
            if let error = error {
                print("Failed to save post to Firestore: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let ref = ref else {
                completion(nil)
                return
            }
            
            ref.getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch new post: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(nil)
                    return
                }
                do {
                    let post = try snapshot.data(as: PublicPost.self)
                    completion(post)
                } catch {
                    print("Failed to decode new post: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
    }
    
    func uploadSingleImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let storageRef = postImagesRef(filename: filename)
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Image upload failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get image download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url?.absoluteString)
            }
        }
    }

    func uploadSingleVideo(videoUrl: URL, completion: @escaping (String?) -> Void) {
        compressVideo(inputURL: videoUrl) { compressedUrl in
            guard let compressedUrl = compressedUrl else {
                completion(nil)
                return
            }
            let videoFilename = UUID().uuidString + ".mp4"
            let videoRef = self.postVideosRef(filename: videoFilename)
            videoRef.putFile(from: compressedUrl, metadata: nil) { _, error in
                if let error = error {
                    print("Video upload failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                videoRef.downloadURL { url, error in
                    if let error = error {
                        print("Video download URL error: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }
                    completion(url?.absoluteString)
                }
            }
        }
    }

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

}
