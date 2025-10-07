//
//  ProfileStatsView.swift
//  Dare
//
//  Created by Bram Heetkamp on 28/01/2025.
//

import SwiftUI

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.title2)
                .foregroundColor(Color("headerText"))
                .bold()
            Text(title)
                .font(.headline)
                .foregroundColor(Color("detailText"))
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cell"))
        .cornerRadius(Style.CornerRadius.small)
    }
}

struct ProfileStatsView: View {
    let stats: [(title: String, value: String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderLabelView(text: "Stats")
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(stats, id: \.title) { stat in
                    StatItem(title: stat.title, value: stat.value)
                }
            }
        }
    }
}
