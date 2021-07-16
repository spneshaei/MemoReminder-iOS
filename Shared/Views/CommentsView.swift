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
    
    // TODO: Unlike a comment?
    func likeComment(comment: Comment) async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.likeComment(comment: comment, globalData: globalData)
            main {
                comment.numberOfLikes += 1
                comment.hasCurrentUserLiked = true // TODO: Toggle? (before adding unlike, not needed)
                showActivityIndicatorView = false
            }
        } catch {
            main {
                showingLikeErrorAlert = true
                showActivityIndicatorView = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            List(memory.comments) { comment in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(comment.senderFirstName) wrote:")
                            .bold()
                        Text(comment.contents)
                    }
                    Spacer()
                    Label("\(comment.numberOfLikes)", systemImage: comment.hasCurrentUserLiked ? "heart.fill" : "heart")
                        .onTapGesture {
                            print("")
                        }
                        
                }
            }
            .alert("Error in liking the comment. Please try again", isPresented: $showingLikeErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationBarTitle(Text("Comments"))
            
            ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .equalizer)
                .frame(width: 100.0, height: 100.0)
                .foregroundColor(.orange)
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(memory: Memory.sample)
    }
}
