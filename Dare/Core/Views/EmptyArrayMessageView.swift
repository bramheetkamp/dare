//
//  EmptyArrayMessageView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct EmptyArrayMessageView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(Color("headerText"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
