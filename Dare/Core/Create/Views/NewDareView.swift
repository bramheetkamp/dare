//
//  NewDareView.swift
//  Dare
//
//  Created by Bram Heetkamp on 29/10/24.
//

import SwiftUI
import Kingfisher

struct NewDareView: View {
    @State private var caption = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel = UploadPostViewModel()
    @State private var showPopup = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    // Info Section
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .padding()
                        Spacer()
                        Text("This challenge is public so everyone can see this")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .background(Color("cell"))
                    .cornerRadius(5)
                    .padding(10)

                    // Challenge Section
                    Text("What would you like to do?")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(Color("headerText"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $caption)
                            .padding(10)
                            .background(Color("cell"))
                            .foregroundColor(Color("headerText"))
                            .frame(height: 200)
                            .cornerRadius(5)

                        if caption.isEmpty {
                            Text("Finish a puzzle of a 1000 pieces")
                                .foregroundColor(Color("headerText"))
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(0)

                    // Submission Section
                    Text("Submission")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(Color("headerText"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)

                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .onTapGesture {
                                    isImagePickerPresented = true
                                }
                                .padding(.top)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color("cell").opacity(0.3))
                                    .frame(width: 200, height: 200)

                                Text("Tap to add an image")
                                    .foregroundColor(Color("headerText"))
                                    .bold()
                            }
                            .onTapGesture {
                                isImagePickerPresented = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing])

                    // Send Button
                    Button {
                        viewModel.uploadPost(withCaption: caption, image: selectedImage)
                        showPopup = true

                        NotificationCenter.default.post(name: .newPostUploaded, object: nil)
                    } label: {
                        Text("Send and dare")
                            .padding()
                            .fontWeight(.black)
                            .background(Color("primaryButton"))
                            .foregroundColor(Color("headerText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()

                    Spacer()
                }
                .padding(.top)
            }

            // Success Popup
            if showPopup {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Sent, see feed.")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showPopup = false
                                }
                            }
                    }
                }
            }

            // Custom Image Picker
            if isImagePickerPresented {
                CustomImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
            }
        }
    }
}

extension Notification.Name {
    static let newPostUploaded = Notification.Name("newPostUploaded")
}
