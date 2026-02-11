//
//  VideoPlayerView.swift
//  Dare
//
//  Created by Bram Heetkamp on 31/10/2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let isVisible: Bool
    @Binding var currentPlayerID: String?
    let postID: String
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        guard let player = uiViewController.player else { return }
        
        if isVisible && currentPlayerID != postID {
            currentPlayerID = postID
            player.play()
        } else if !isVisible && currentPlayerID == postID {
            player.pause()
            currentPlayerID = nil
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        uiViewController.player?.pause()
        uiViewController.player = nil
    }
}
