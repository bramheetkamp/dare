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

    func uploadPost(
        challengeId: String,
        caption: String,
        location: String?,
        image: UIImage?,
        videoUrl: URL?,
        challengeType: String?,
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else {
            completion(nil)
            return
        }

        if let videoUrl = videoUrl {
            uploadVideoPost(uid: uid, challengeId: challengeId, caption: caption, location: location, videoUrl: videoUrl, date: date, completion: completion)
            return
        }

        if let image = image {
            uploadImagePost(uid: uid, challengeId: challengeId, caption: caption, location: location, image: image, date: date, completion: completion)
            return
        }

        // No media post
        savePostToFirestore(uid: uid, challengeId: challengeId, caption: caption, location: location, imageUrl: nil, videoUrl: nil, date: date, mediaAspectRatio: nil, completion: completion)
    }

    private func uploadVideoPost(
        uid: String,
        challengeId: String,
        caption: String,
        location: String?,
        videoUrl: URL,
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
        compressVideo(inputURL: videoUrl) { compressedUrl in
            guard let compressedUrl = compressedUrl else {
                completion(nil)
                return
            }

            guard let thumbnailImage = self.generateThumbnail(from: compressedUrl),
                  let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.5) else {
                completion(nil)
                return
            }

            let videoFilename = UUID().uuidString + ".mp4"
            let videoRef = self.postVideosRef(filename: videoFilename)

            let thumbnailFilename = UUID().uuidString + ".jpg"
            let thumbnailRef = self.postImagesRef(filename: thumbnailFilename)

            thumbnailRef.putData(thumbnailData, metadata: nil) { _, error in
                if let error = error {
                    print("Thumbnail upload failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                thumbnailRef.downloadURL { thumbnailUrl, error in
                    if let error = error {
                        print("Thumbnail download URL error: \(error.localizedDescription)")
                        completion(nil)
                        return
                    }

                    videoRef.putFile(from: compressedUrl, metadata: nil) { _, error in
                        if let error = error {
                            print("Video upload failed: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }

                        videoRef.downloadURL { videoUrl, error in
                            if let error = error {
                                print("Video download URL error: \(error.localizedDescription)")
                                completion(nil)
                                return
                            }

                            let aspectRatio = Float(thumbnailImage.size.width / thumbnailImage.size.height)
                            self.savePostToFirestore(uid: uid, challengeId: challengeId, caption: caption, location: location, imageUrl: thumbnailUrl?.absoluteString, videoUrl: videoUrl?.absoluteString, date: date, mediaAspectRatio: aspectRatio, completion: completion)
                        }
                    }
                }
            }
        }
    }

    private func uploadImagePost(
        uid: String,
        challengeId: String,
        caption: String,
        location: String?,
        image: UIImage,
        date: Date?,
        completion: @escaping (PublicPost?) -> Void
    ) {
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

                guard let imageUrl = url?.absoluteString else {
                    completion(nil)
                    return
                }

                let aspectRatio = Float(image.size.width / image.size.height)

                self.savePostToFirestore(uid: uid, challengeId: challengeId, caption: caption, location: location, imageUrl: imageUrl, videoUrl: nil, date: date, mediaAspectRatio: aspectRatio, completion: completion)
            }
        }
    }

    private func savePostToFirestore(uid: String, challengeId: String, caption: String, location: String?, imageUrl: String?, videoUrl: String? = nil, date: Date?, mediaAspectRatio: Float?, completion: @escaping (PublicPost?) -> Void) {
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
            "mediaAspectRatio": mediaAspectRatio as Any
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: data) { error in
            if let error = error {
                print("DEBUG: Failed to save post to Firestore with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let ref = ref else {
                completion(nil)
                return
            }
            ref.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch new post: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(nil)
                    return
                }
                do {
                    var post = try snapshot.data(as: PublicPost.self)
                    // Optionally, you could fetch the challenge object here as well.
                    completion(post)
                } catch {
                    print("DEBUG: Failed to decode new post: \(error.localizedDescription)")
                    completion(nil)
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
