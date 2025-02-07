//
//  ErrorPopupView.swift
//  Dare
//
//  Created by Bram Heetkamp on 07/11/2024.
//

import SwiftUI

struct ErrorPopupView: View {
    let title: String
    let message: String
    let buttonTitle: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    isPresented = false
                }) {
                    Text(buttonTitle)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).edgesIgnoringSafeArea(.all))
        .opacity(isPresented ? 1 : 0)
        .animation(.easeInOut, value: isPresented)
    }
}
