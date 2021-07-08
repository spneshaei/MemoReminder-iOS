//
//  Comment.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/8/21.
//

import Foundation

class Comment: Identifiable, Codable {
    var id: String
    
    var senderUsername = ""
    var contents = ""
    var numberOfLikes = 0
    
    init(id: String) {
        self.id = id
    }
    
    convenience init() {
        self.init(id: UUID().uuidString)
    }
}
