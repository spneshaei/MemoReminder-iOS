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
    var contents = ""
    var numberOfLikes = 0
    var hasCurrentUserLiked = false
    
    init(id: Int) {
        self.id = id
    }
}
