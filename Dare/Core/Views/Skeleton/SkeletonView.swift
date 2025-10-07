//
//  SkeletonView.swift
//  Dare
//
//  Created by Bram Heetkamp on 19/06/2025.
//

import SwiftUI

struct SkeletonView: View {
    enum Shape {
        case rectangle
        case circle
        case rounded(cornerRadius: CGFloat)
    }
    
    var shape: Shape = .rectangle
    var opacity: Double = 0.25
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            switch shape {
            case .circle:
                Circle()
                    .fill(Color.gray.opacity(opacity))
                    .frame(width: size.width, height: size.height)
            case .rectangle:
                Rectangle()
                    .fill(Color.gray.opacity(opacity))
                    .frame(width: size.width, height: size.height)
            case .rounded(let cornerRadius):
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(opacity))
                    .frame(width: size.width, height: size.height)
            }
        }
        .modifier(ShimmerEffect())
    }
}

struct ShimmerView<Content: View>: View {
    @State private var phase: CGFloat = 0
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .modifier(AnimatedMask(phase: phase))
            .animation(
                Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                value: phase
            )
            .onAppear { phase = 1 }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        ShimmerView {
            content
        }
    }
}

struct AnimatedMask: AnimatableModifier {
    var phase: CGFloat = 0
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black, location: phase),
                        .init(color: .black.opacity(0.3), location: phase + 0.1),
                        .init(color: .black, location: phase + 0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
