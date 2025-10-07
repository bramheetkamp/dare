//
//  HeaderLabelView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/01/2025.
//

import SwiftUI

struct HeaderLabelView: View {
    var text: String
    var size: Font = .title
    var fontWeight: Font.Weight = .black
    var alignment: Alignment = .leading
    
    var body: some View {
        Text(text)
            .font(size)
            .foregroundColor(Color("headerText"))
            .fontWeight(fontWeight)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
