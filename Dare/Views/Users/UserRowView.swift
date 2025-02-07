//
//  UserRowView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: user.avatarUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(user.username)")
                    .font(.subheadline).bold()
                    .foregroundColor(Color("headerText"))
                Text(user.fullname)
                    .font(.subheadline)
                    .foregroundColor(Color("detailText"))
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct UserRowView_Previews: PreviewProvider {
    static var previews: some View {
        UserRowView(user: User(id: NSUUID().uuidString,
                               username: "sergeydeveloper",
                               fullname: "Sergey Developer",
                               profileImageUrl: "",
                               email: "sergey.developer@gmail.com"))
    }
}
