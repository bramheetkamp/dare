//
//  EmojiSquareView.swift
//  Dare
//
//  Created by Bram Heetkamp on 31/10/2025.
//

import SwiftUI

struct EmojiDisplaySquare: View {
    
    let emojis: [String?]
    let size: CGFloat
    var showBackground: Bool = false
    
    @Namespace private var emojiAnimationNamespace
    
    var body: some View {
        let filteredEmojis = emojis.compactMap { $0 }
        
        ZStack {
            RoundedRectangle(cornerRadius: Style.CornerRadius.small)
                .frame(width: size, height: size)
                .foregroundStyle(showBackground ? .cell : .clear)
            
            switch filteredEmojis.count {
            case 1:
                Text(filteredEmojis[0])
                    .font(.system(size: size * 0.6))
                    .matchedGeometryEffect(id: "emoji1", in: emojiAnimationNamespace)
                    .frame(width: size, height: size, alignment: .center)
                    .transition(.opacity)
                    .padding(8)
            case 2:
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    
                    Text(filteredEmojis[0])
                        .font(.system(size: size * 0.4))
                        .matchedGeometryEffect(id: "emoji1", in: emojiAnimationNamespace)
                        .position(x: width * 0.3, y: height * 0.3)
                    Text(filteredEmojis[1])
                        .font(.system(size: size * 0.4))
                        .matchedGeometryEffect(id: "emoji2", in: emojiAnimationNamespace)
                        .position(x: width * 0.7, y: height * 0.7)
                }
                .transition(.opacity)
                .padding(8)
            case 3:
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    
                    Text(filteredEmojis[0])
                        .font(.system(size: size * 0.4))
                        .matchedGeometryEffect(id: "emoji1", in: emojiAnimationNamespace)
                        .position(x: width * 0.28, y: height * 0.3)
                    Text(filteredEmojis[1])
                        .font(.system(size: size * 0.4))
                        .matchedGeometryEffect(id: "emoji2", in: emojiAnimationNamespace)
                        .position(x: width * 0.72, y: height * 0.3)
                    Text(filteredEmojis[2])
                        .font(.system(size: size * 0.4))
                        .matchedGeometryEffect(id: "emoji3", in: emojiAnimationNamespace)
                        .position(x: width * 0.5, y: height * 0.75)
                }
                .transition(.opacity)
                .padding(8)
            default:
                EmptyView()
            }
        }
        .background(.clear)
        .frame(width: size, height: size)
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.6), value: filteredEmojis)
    }
}
