import SwiftUI

struct CommentsView: View {
    @ObservedObject var viewModel: CommentsViewModel
    let post: Post
    
    init(post: Post) {
        self.viewModel = CommentsViewModel(post: post)
        self.post = post
    }
    
    var body: some View {
        VStack {
            // Display existing comments
            List(viewModel.comments) { comment in
                VStack(alignment: .leading) {
                    Text(comment.user?.fullname ?? "-")
                        .font(.headline)
                        .foregroundColor(Color("headerText"))
                    Text(comment.text)
                        .font(.subheadline)
                        .foregroundColor(Color("bodyText"))
                    Text(timeAgoSinceDate(comment.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .background(Color("background"))
                .padding(.vertical, 8)
            }
            
            HStack {
                TextField("Add a comment...", text: $viewModel.newCommentText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    viewModel.addComment(text: viewModel.newCommentText)
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.headline)
                        .padding(.trailing)
                        .foregroundColor(Color("primaryButton"))
                }
                .disabled(viewModel.newCommentText.isEmpty)
            }
            .padding(.top)
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .customBackButton()
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("dareGreen"), Color("dareBlue")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    
    func timeAgoSinceDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let currentDate = Date()
        let interval = currentDate.timeIntervalSince(date)
        
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days) days ago"
        } else if hours > 0 {
            return "\(hours) hours ago"
        } else if minutes > 0 {
            return "\(minutes) minutes ago"
        } else {
            return "Just now"
        }
    }
}
