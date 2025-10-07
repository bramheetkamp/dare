//
//  FilterView.swift
//  Dare
//
//  Created by Bram Heetkamp on 01/02/2025.
//

import SwiftUI

struct FilterView<Filter: RawRepresentable & CaseIterable & Hashable>: View where Filter.AllCases: RandomAccessCollection, Filter.RawValue == String {
    @Binding var selectedFilter: Filter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Filter.allCases, id: \.self) { filter in
                    InteractiveButtonStack(
                        action: {
                            selectedFilter = filter
                        },
                        cornerRadius: Style.CornerRadius.small,
                        backgroundColor: selectedFilter == filter ? Color("primaryButton") : Color("secondaryButton")
                    ) {
                        HStack {
                            Text(filter.rawValue)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(.white)
                                .contentShape(Rectangle())
                        }
                    }
                    .zIndex(1)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
}
