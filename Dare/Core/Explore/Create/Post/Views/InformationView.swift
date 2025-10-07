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
        HStack {
            Image(systemName: "info.circle.fill")
                .padding()
            Spacer()
            Text(information)
                .font(.subheadline)
                .foregroundColor(Color("headerText"))
                .padding()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}
