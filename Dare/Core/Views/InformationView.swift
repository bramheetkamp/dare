//
//  InformationView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct InformationView: View {
    let information: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
                .font(.subheadline)
            Text(information)
                .font(.subheadline)
            Spacer()
        }
        .foregroundStyle(.headerText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
