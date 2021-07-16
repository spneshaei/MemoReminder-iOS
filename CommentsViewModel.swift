//
//  CommentsViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

class CommentsViewModel: ObservableObject {
    var isSample = false
    
    func likeComment(comment: Comment, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "comment": comment.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "comment-like/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    static var sample: CommentsViewModel {
        let viewModel = CommentsViewModel()
        viewModel.isSample = true
        return viewModel
    }
}
