//
//  RegistrationView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    
    @State private var isSelectingPhoto = false
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, username, fullname, password
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                AuthHeaderView(title1: "Get started,", title2: "Create your account")
                
                VStack(spacing: 40) {
                    CustomInputField(
                        imageName: "envelope",
                        placeholderText: "Email",
                        textCase: .lowercase,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        text: $email
                    )
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .username
                    }
                    
                    CustomInputField(
                        imageName: "person",
                        placeholderText: "Username",
                        textCase: .lowercase,
                        keyboardType: .default,
                        textContentType: .username,
                        text: $username
                    )
                    .focused($focusedField, equals: .username)
                    .onSubmit {
                        focusedField = .fullname
                    }
                    
                    CustomInputField(
                        imageName: "person",
                        placeholderText: "Full name",
                        textContentType: .name,
                        textInputAutoCapital: .words,
                        text: $fullname
                    )
                    .focused($focusedField, equals: .fullname)
                    .onSubmit {
                        focusedField = .password
                    }
                    
                    CustomInputField(
                        imageName: "lock",
                        placeholderText: "Password",
                        textContentType: .newPassword,
                        isSecureField: true,
                        text: $password
                    )
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        signUp()
                    }
                }
                .padding(32)
                
                Button {
                    signUp()
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 340, height: 50)
                        .background(Color("primaryButton"))
                        .clipShape(Capsule())
                        .padding()
                }
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)
                
                Spacer()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("Already have an account?")
                            .font(.footnote)
                        
                        Text("Sign In")
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 32)
                .foregroundColor(Color("primaryButton"))
            }
        }
        .withStandardPageStyle(extendView: false)
        .navigationDestination(isPresented: $isSelectingPhoto) {
            ProfilePhotoSelectorView()
        }
    }
    
    private func signUp() {
        if email.isEmpty
            || password.isEmpty
            || fullname.isEmpty
            || username.isEmpty {
            errorMessage = "Please fill in all the fields."
            showErrorPopup = true
        } else {
            viewModel.register(
                withEmail: email,
                password: password,
                fullname: fullname,
                username: username
            )
        }
    }
}
