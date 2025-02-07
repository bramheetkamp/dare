//
//  UploadPostViewModel.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

class UploadPostViewModel: ObservableObject {
    @Published var didUploadPost = false
    let service = PostService()
    
    func uploadPost(withCaption caption: String, image: UIImage?) {
        service.uploadPost(caption: caption, image: image) { success in
            if success {
                DispatchQueue.main.async {
                    self.didUploadPost = true
                }
            } else {
                print("DEBUG: Failed to upload post")
            }
        }
    }
}
