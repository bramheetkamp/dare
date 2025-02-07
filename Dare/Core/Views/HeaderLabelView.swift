//
//  HeaderLabelView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/01/2025.
//

import SwiftUI

struct HeaderLabelView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.title)
            .foregroundColor(Color("headerText"))
            .fontWeight(.black)
    }
}
