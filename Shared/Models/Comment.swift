//
//  Comment.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class Comment: Identifiable, Codable {
    var id: Int
    
    var senderUsername = ""
    var senderFirstName = ""
    var senderLastName = ""
    var contents = ""
    var numberOfLikes = 0
    var hasCurrentUserLiked = false
    
    init(id: Int) {
        self.id = id
    }
    
    static var sample: Comment {
        let comment = Comment(id: 0)
        comment.senderUsername = "seyyedparsa"
        comment.senderFirstName = "Seyed Parsa"
        comment.senderLastName = "Neshaei"
        comment.contents = "What a great memory!"
        comment.numberOfLikes = 2
        comment.hasCurrentUserLiked = false
        return comment
    }
}
