//
//  ClapAnimationView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/01/2025.
//

import SwiftUI
import UIKit

struct ClapAnimationView: View {
    @State private var showEmojis = true
    @State private var emojis: [UUID] = []
    var dismissAction: (() -> Void)?
    
    let animationDuration: TimeInterval = 3.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HeaderLabelView(text: "You dared yourself!")
                HeaderLabelView(text: "Your friends can support your challenge and you have a new goal! 🎉", size: .title3, fontWeight: .bold)
                
                Button(action: {
                    dismissAction?()
                }) {
                    Text("Continue")
                        .fontWeight(.black)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color("primaryButton"))
                        .cornerRadius(5)
                }
                .padding(.top, 40)
                .frame(maxWidth: .infinity)
            }
            .zIndex(1)
            .padding(.horizontal, 20)
            
            if showEmojis {
                ForEach(emojis, id: \.self) { id in
                    FallingEmojiView(emoji: "👏")
                }
            }
        }
        .onAppear {
            startFallingEmojis()
        }
    }
    
    private func startFallingEmojis() {
        emojis = (0..<30).map { _ in UUID() }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation {
                showEmojis = false
            }
        }
    }
}

struct FallingEmojiView: View {
    let emoji: String
    @State private var position: CGFloat = -100
    @State private var opacity: Double = 1.0
    let size: CGFloat = CGFloat.random(in: 40...90)
    let delay: Double = Double.random(in: 0...1.0)
    let hapticType: UIImpactFeedbackGenerator.FeedbackStyle = Bool.random() ? .light : .heavy
    
    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            .position(x: CGFloat.random(in: 10...UIScreen.main.bounds.width - 10), y: position)
            .opacity(opacity)
            .onAppear {
                HapticManager.shared.triggerHaptic(style: hapticType, delay: delay)
                withAnimation(Animation.linear(duration: 2.5).delay(delay)) {
                    position = UIScreen.main.bounds.height + 10
                    opacity = 0
                }
            }
    }
}

class HapticManager {
    static let shared = HapticManager()
    
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle, delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
}
