import SwiftUI

struct CustomNavigationBarModifier: ViewModifier {
    let title: String?
    let showBackButton: Bool

    @Environment(\.presentationMode) private var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Title (centered)
                if let title = title {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(Color("headerText"))
                    }
                }
                // Back button
                if showBackButton {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("headerText"))
                        }
                    }
                }
            }
    }
}
