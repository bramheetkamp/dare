//
//  ProfilePinnedView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/01/2025.
//

import SwiftUI

struct ProfilePinnedView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Pinned")
            
            ForEach(viewModel.challenges.prefix(3)) { challenge in
                ChallengeRowView(challenge: challenge)
            }
        }
    }
}
