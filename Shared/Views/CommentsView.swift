//
//  CommentsView.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import SwiftUI
import ActivityIndicatorView

struct CommentsView: View {
    @EnvironmentObject var globalData: GlobalData
    
    @StateObject var viewModel = CommentsViewModel()
    
    @State var memory: Memory
    @State var showActivityIndicatorView = false
    @State var showingLikeErrorAlert = false
    @State var commentText = ""
    
    fileprivate func addCommentToMemoryComments(id: Int) {
        let comment = Comment(id: id)
        // TODO: Check for further exploration of comment features
        comment.hasCurrentUserLiked = false
        comment.numberOfLikes = 0
        comment.contents = commentText
        comment.senderUsername = globalData.username
        comment.senderFirstName = globalData.firstName
        comment.senderLastName = globalData.lastName
        memory.comments.append(comment)
    }
    
    func submitNewComment() async {
        do {
            main { showActivityIndicatorView = true }
            let id = try await viewModel.submitNewComment(text: commentText, on: memory, globalData: globalData)
            main {
                addCommentToMemoryComments(id: id)
                commentText = ""
                showActivityIndicatorView = false
            }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLikeErrorAlert = true
            }
        }
    }
    
    // TODO: Refreshing (and also loading here - this one is not good; but refresh is good) comments...?
    
    var body: some View {
        ZStack {
            VStack {
                List(memory.comments) { comment in
                    CommentCell(comment: comment, showActivityIndicatorView: $showActivityIndicatorView, viewModel: viewModel, showingLikeErrorAlert: $showingLikeErrorAlert)
                }
                .alert("Error in liking the comment. Please try again", isPresented: $showingLikeErrorAlert) {
                    Button("OK", role: .cancel) { }
                }
                .navigationBarTitle(Text("Comments"))
                
                // TODO: Fix non syncing of the send button color to the rest of the app!
                HStack(spacing: 5) {
                    TextField("Enter your comment", text: $commentText)
                        .font(.title3)
                    Button(action: {
                        async { await submitNewComment() }
                    }, label: {
                        Text("Send")
                            .padding(.horizontal)
                    })
                        .buttonStyle(AddMemoryButton(colors: [Color(red: 0.70, green: 0.22, blue: 0.22), Color(red: 1, green: 0.32, blue: 0.32)])).clipShape(Capsule())
                }
                .padding()
            }
            //            .navigationBarItems(trailing: Button(action: {
            //
            //            }, label: { Text("Add").bold() }))
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CommentsView(memory: Memory.sample)
        }
    }
}
