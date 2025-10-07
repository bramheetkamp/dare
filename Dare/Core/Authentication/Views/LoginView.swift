//
//  LoginView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showErrorPopup = false
    @State private var errorMessage = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject private var router: AppRouter
    
    @FocusState private var focusedField: Field?
    enum Field {
        case email, password
    }
    
    var body: some View {
        VStack {
            AuthHeaderView(title1: "Hello,", title2: "welcome back")
            
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
                    focusedField = .password
                }
                
                CustomInputField(
                    imageName: "lock",
                    placeholderText: "Password",
                    textCase: .lowercase,
                    keyboardType: .default,
                    textContentType: .password,
                    isSecureField: true,
                    text: $password
                )
                .focused($focusedField, equals: .password)
                .onSubmit {
                    login()
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 44)
            
            Button {
                router.navigate(to: .registration)
            } label: {
                HStack {
                    Spacer()
                    Text("Forgot Password?")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("primaryButton"))
                        .padding(.top)
                        .padding(.trailing, 24)
                }
            }
            
            Button {
                login()
            } label: {
                Text("Sign In")
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
                router.navigate(to: .registration)
            } label: {
                HStack {
                    Text("Don't have an account?")
                        .font(.footnote)
                    
                    Text("Sign Up")
                        .font(.footnote)
                        .fontWeight(.semibold)
                }
            }
            .padding(.bottom, 32)
            .foregroundColor(Color("primaryButton"))
        }
        .onTapGesture {
            focusedField = nil
        }
        .overlay(
            ErrorPopupView(title: "Login Failed", message: errorMessage, buttonTitle: "Got it", isPresented: $showErrorPopup)
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func login() {
        
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all the fields."
            showErrorPopup = true
        } else {
            viewModel.login(
                withEmail: email,
                password: password
            ) { error in
                errorMessage = error
                showErrorPopup = true
            }
        }
    }
}
