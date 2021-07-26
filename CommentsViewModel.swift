//
//  CommentsViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI

class CommentsViewModel: ObservableObject {
    var isSample = false
    
    enum CommentSubmissionError: Error {
        case error
    }
    
    /// submitNewComment
    /// - Parameters:
    ///   - text: text
    ///   - memory: memory
    ///   - globalData: globalData
    /// - Throws: error
    /// - Returns: ID of the registered comment
    func submitNewComment(text: String, on memory: Memory, globalData: GlobalData) async throws -> Int {
        guard !isSample else { throw CommentSubmissionError.error }
        let body: JSON = [
            "post": memory.id,
            "text": text
        ]
        guard let bodyString = body.rawString() else { throw CommentSubmissionError.error }
        let resultString = try await Rester.rest(endPoint: "comment/", body: bodyString, method: .post, globalData: globalData)
        return JSON(parseJSON: resultString)["id"].intValue
    }
    
    func likeComment(comment: Comment, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "comment": comment.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "comment-like/", body: bodyString, method: .post, globalData: globalData)
    }
    
    static var sample: CommentsViewModel {
        let viewModel = CommentsViewModel()
        viewModel.isSample = true
        return viewModel
    }
}
