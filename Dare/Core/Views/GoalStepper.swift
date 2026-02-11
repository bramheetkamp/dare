//
//  GoalStepper.swift
//  Dare
//
//  Created by Bram Heetkamp on 27/10/2025.
//

import SwiftUI

struct GoalStepper: View {
    @Binding var goal: Int
    let min: Int
    let max: Int
    
    var body: some View {
        HStack {
            Button(action: {
                if goal > min { goal -= 1 }
            }) {
                Image(systemName: "minus.circle")
                    .font(.title2)
                    .foregroundStyle(.primaryButton)
            }
            .disabled(goal <= min)
            .padding(.trailing, 8)
            
            Spacer()
            
            Text("\(goal)")
                .font(.headline)
                .frame(minWidth: 40)
                .foregroundColor(.headerText)
            
            Spacer()
            
            Button(action: {
                if goal < max { goal += 1 }
            }) {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundStyle(.primaryButton)
            }
            .disabled(goal >= max)
            .padding(.leading, 8)
        }
        .padding(12)
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
}
