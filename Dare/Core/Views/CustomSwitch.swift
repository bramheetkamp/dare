//
//  CustomSwitch.swift
//  Dare
//
//  Created by Bram Heetkamp on 27/10/2025.
//

import SwiftUI

struct CustomSwitch: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                Text(title)
                    .foregroundStyle(.headerText)
            }
            .labelsHidden()
            .toggleStyle(SymbolToggleStyle(systemImage: "lock", activeColor: .primaryButton))
        }
        .padding(12)
        .background(Color.cell)
        .cornerRadius(Style.CornerRadius.small)
    }
}


struct SymbolToggleStyle: ToggleStyle {

    var systemImage: String = "lock"
    var activeColor: Color = .primaryButton

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .foregroundStyle(.headerText)

            Spacer()

            RoundedRectangle(cornerRadius: 30)
                .fill(configuration.isOn ? activeColor : Color(.systemGray5))
                .overlay {
                    Circle()
                        .fill(.white)
                        .padding(3)
                        .overlay {
                            Image(systemName: systemImage)
                                .foregroundColor(configuration.isOn ? activeColor : Color(.systemGray5))
                        }
                        .offset(x: configuration.isOn ? 10 : -10)

                }
                .frame(width: 50, height: 32)
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
