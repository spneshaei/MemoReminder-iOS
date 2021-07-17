//
//  CommentCell.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

struct CommentCell: View {
    @EnvironmentObject var globalData: GlobalData
    var comment: Comment
    @State var numberOfLikes = 0
    @State var hasCurrentUserLiked = false
    @Binding var showActivityIndicatorView: Bool
    @Binding var showingLikeErrorAlert: Bool
    @ObservedObject var viewModel: CommentsViewModel
    
    init(comment: Comment, showActivityIndicatorView: Binding<Bool>, viewModel: CommentsViewModel, showingLikeErrorAlert: Binding<Bool>) {
        self.comment = comment
        self.numberOfLikes = comment.numberOfLikes
        self.hasCurrentUserLiked = comment.hasCurrentUserLiked
        self._showActivityIndicatorView = showActivityIndicatorView
        self.viewModel = viewModel
        self._showingLikeErrorAlert = showingLikeErrorAlert
    }
    
    func likeComment(comment: Comment) async {
        do {
            main { showActivityIndicatorView = true }
            try await viewModel.likeComment(comment: comment, globalData: globalData)
            main {
                comment.numberOfLikes += 1
                numberOfLikes += 1
                comment.hasCurrentUserLiked = true
                hasCurrentUserLiked = true
                showActivityIndicatorView = false
            }
        } catch {
            main {
                showActivityIndicatorView = false
                showingLikeErrorAlert = true
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(comment.senderFirstName) wrote:")
                    .bold()
                Text(comment.contents)
            }
            Spacer()
            Label("\(numberOfLikes)", systemImage: hasCurrentUserLiked ? "heart.fill" : "heart")
                .onTapGesture {
                    if !hasCurrentUserLiked {
                        async { await likeComment(comment: comment) }
                    }
                }
                .padding()
        }
    }
}

struct CommentCell_Previews: PreviewProvider {
    static var previews: some View {
        CommentCell(comment: Comment.sample, showActivityIndicatorView: .constant(false), viewModel: .sample, showingLikeErrorAlert: .constant(false))
            .environmentObject(GlobalData.sample)
    }
}
