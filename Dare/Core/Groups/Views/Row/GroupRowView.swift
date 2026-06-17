//
//  GroupRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 17/06/2026.
//

import SwiftUI

struct GroupRowView: View {
    let group: DareGroup
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Button {
            guard let id = group.id else { return }
            router.navigate(to: .groupDetail(groupId: id))
        } label: {
            HStack(spacing: 12) {
                Text(group.displayEmoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color("innerCell"))
                    .clipShape(RoundedRectangle(cornerRadius: Style.CornerRadius.small))

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(Style.Typography.bodyStrong)
                        .foregroundColor(Color("headerText"))
                    Text(memberLabel)
                        .font(Style.Typography.secondary)
                        .foregroundColor(Color("detailText"))
                }
                Spacer()
                if group.isMember == true {
                    Text("Joined")
                        .font(Style.Typography.caption)
                        .foregroundColor(Color("dareGreen"))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("cell"))
            .cornerRadius(Style.CornerRadius.small)
        }
    }

    private var memberLabel: String {
        let count = group.members
        return count == 1 ? "1 member" : "\(count) members"
    }
}
